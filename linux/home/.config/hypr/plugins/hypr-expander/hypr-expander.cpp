#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/devices/IKeyboard.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/SeatManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

#include <wayland-server-core.h>
#include <xkbcommon/xkbcommon-keysyms.h>

#include <algorithm>
#include <array>
#include <bit>
#include <chrono>
#include <cstdint>
#include <optional>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

inline HANDLE PHANDLE = nullptr;

namespace {
struct Expansion {
    std::string trigger;
    std::string replacement;
};

struct KeyStroke {
    uint32_t keycode;
    xkb_mod_mask_t modifiers;
};

struct PendingExpansion {
    size_t eraseCount;
    std::string replacement;
};

constexpr uint32_t firstPrintableAscii = 0x20;
constexpr uint32_t lastPrintableAscii = 0x7E;
constexpr size_t printableAsciiCount = lastPrintableAscii - firstPrintableAscii + 1;
constexpr xkb_keycode_t xkbKeycodeOffset = 8;

struct KeyStrokeMap {
    std::optional<KeyStroke> backspace;
    std::array<std::optional<KeyStroke>, printableAsciiCount> printable;
};

std::vector<Expansion> expansions;
std::vector<PendingExpansion> pendingExpansions;
std::string recentText;
size_t longestTrigger = 0;
wl_event_source* pendingIdleSource = nullptr;

CHyprSignalListener keyListener;
CHyprSignalListener focusListener;
CHyprSignalListener preReloadListener;

void notifyError(const std::string& message) {
    HyprlandAPI::addNotification(PHANDLE, "hypr-expander: " + message, CHyprColor{1.0F, 0.25F, 0.25F, 1.0F}, 5000);
}

bool isPrintableAscii(const uint32_t character) {
    return character >= firstPrintableAscii && character <= lastPrintableAscii;
}

bool isPrintableAscii(const std::string_view value) {
    return std::ranges::all_of(value, [](const unsigned char character) {
        return isPrintableAscii(character);
    });
}

void discardPendingExpansions() {
    pendingExpansions.clear();
    if (pendingIdleSource == nullptr) {
        return;
    }

    wl_event_source_remove(pendingIdleSource);
    pendingIdleSource = nullptr;
}

void clearInputState() {
    recentText.clear();
    discardPendingExpansions();
}

void clearExpansions() {
    expansions.clear();
    longestTrigger = 0;
    clearInputState();
}

int addExpansion(lua_State* lua) {
    luaL_checktype(lua, 1, LUA_TTABLE);

    lua_getfield(lua, 1, "trigger");
    lua_getfield(lua, 1, "replacement");

    size_t triggerLength = 0;
    size_t replacementLength = 0;
    const char* triggerValue = luaL_checklstring(lua, -2, &triggerLength);
    const char* replacementValue = luaL_checklstring(lua, -1, &replacementLength);

    const std::string_view triggerView(triggerValue, triggerLength);
    const std::string_view replacementView(replacementValue, replacementLength);

    if (triggerView.empty()) {
        lua_pop(lua, 2);
        return luaL_error(lua, "hypr-expander: The trigger cannot be empty.");
    }

    if (!isPrintableAscii(triggerView) || !isPrintableAscii(replacementView)) {
        lua_pop(lua, 2);
        return luaL_error(lua, "hypr-expander: Triggers and replacements must contain printable ASCII characters.");
    }

    std::string trigger(triggerView);
    std::string replacement(replacementView);
    lua_pop(lua, 2);

    const auto existing = std::ranges::find(expansions, trigger, &Expansion::trigger);
    if (existing != expansions.end()) {
        existing->replacement = std::move(replacement);
    } else {
        longestTrigger = std::max(longestTrigger, trigger.size());
        recentText.reserve(longestTrigger);
        expansions.push_back({std::move(trigger), std::move(replacement)});
        std::ranges::sort(expansions, [](const Expansion& left, const Expansion& right) {
            return left.trigger.size() > right.trigger.size();
        });
    }

    recentText.clear();
    return 0;
}

SP<IKeyboard> activePhysicalKeyboard() {
    if (!g_pSeatManager) {
        return nullptr;
    }

    auto keyboard = g_pSeatManager->m_keyboard.lock();
    if (!keyboard || keyboard->isVirtual()) {
        return nullptr;
    }

    return keyboard;
}

void keepSimplestKeyStroke(std::optional<KeyStroke>& best, const KeyStroke& candidate) {
    if (best && std::popcount(best->modifiers) <= std::popcount(candidate.modifiers)) {
        return;
    }

    best = candidate;
}

void recordKeyStroke(KeyStrokeMap& strokes, const xkb_keysym_t symbol, const KeyStroke& candidate) {
    if (symbol == XKB_KEY_BackSpace) {
        keepSimplestKeyStroke(strokes.backspace, candidate);
        return;
    }

    const uint32_t character = xkb_keysym_to_utf32(symbol);
    if (!isPrintableAscii(character)) {
        return;
    }

    auto& best = strokes.printable[character - firstPrintableAscii];
    keepSimplestKeyStroke(best, candidate);
}

KeyStrokeMap buildKeyStrokeMap(xkb_keymap* keymap, const xkb_layout_index_t layout) {
    KeyStrokeMap strokes;
    const xkb_keycode_t minimum = xkb_keymap_min_keycode(keymap);
    const xkb_keycode_t maximum = xkb_keymap_max_keycode(keymap);

    for (xkb_keycode_t keycode = minimum; keycode <= maximum; ++keycode) {
        if (layout >= xkb_keymap_num_layouts_for_key(keymap, keycode)) {
            continue;
        }

        const xkb_level_index_t levels = xkb_keymap_num_levels_for_key(keymap, keycode, layout);
        for (xkb_level_index_t level = 0; level < levels; ++level) {
            const xkb_keysym_t* symbols = nullptr;
            const int symbolCount = xkb_keymap_key_get_syms_by_level(keymap, keycode, layout, level, &symbols);
            if (symbolCount <= 0) {
                continue;
            }

            xkb_mod_mask_t masks[8] = {};
            const size_t maskCount = xkb_keymap_key_get_mods_for_level(keymap, keycode, layout, level, masks, std::size(masks));
            for (size_t maskIndex = 0; maskIndex < maskCount; ++maskIndex) {
                const KeyStroke candidate = {
                    .keycode = static_cast<uint32_t>(keycode - xkbKeycodeOffset),
                    .modifiers = masks[maskIndex],
                };

                for (int symbolIndex = 0; symbolIndex < symbolCount; ++symbolIndex) {
                    recordKeyStroke(strokes, symbols[symbolIndex], candidate);
                }
            }
        }
    }

    return strokes;
}

uint32_t eventTimeMs() {
    using namespace std::chrono;
    return static_cast<uint32_t>(duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count());
}

void sendKeyStroke(CSeatManager& seatManager, const KeyStroke& stroke, const uint32_t timeMs, const uint32_t group) {
    seatManager.sendKeyboardMods(stroke.modifiers, 0, 0, group);
    seatManager.sendKeyboardKey(timeMs, stroke.keycode, WL_KEYBOARD_KEY_STATE_PRESSED);
    seatManager.sendKeyboardKey(timeMs, stroke.keycode, WL_KEYBOARD_KEY_STATE_RELEASED);
}

void injectExpansion(
    CSeatManager& seatManager,
    IKeyboard& keyboard,
    const xkb_layout_index_t layout,
    const KeyStrokeMap& strokes,
    const PendingExpansion& expansion
) {
    if (!strokes.backspace) {
        notifyError("The active keymap has no Backspace key.");
        return;
    }

    std::vector<KeyStroke> replacement;
    replacement.reserve(expansion.replacement.size());
    for (const unsigned char character : expansion.replacement) {
        const auto& stroke = strokes.printable[character - firstPrintableAscii];
        if (!stroke) {
            notifyError("The active keymap cannot type a configured replacement.");
            return;
        }
        replacement.push_back(*stroke);
    }

    const auto originalModifiers = keyboard.m_modifiersState;
    uint32_t timeMs = eventTimeMs();

    for (size_t index = 0; index < expansion.eraseCount; ++index) {
        sendKeyStroke(seatManager, *strokes.backspace, timeMs++, layout);
    }

    for (const KeyStroke& stroke : replacement) {
        sendKeyStroke(seatManager, stroke, timeMs++, layout);
    }

    seatManager.sendKeyboardMods(
        originalModifiers.depressed,
        originalModifiers.latched,
        originalModifiers.locked,
        originalModifiers.group
    );
}

void runPendingExpansions(void*) {
    pendingIdleSource = nullptr;
    auto work = std::move(pendingExpansions);
    pendingExpansions.clear();
    if (work.empty()) {
        return;
    }

    auto keyboard = activePhysicalKeyboard();
    if (!keyboard || keyboard->m_xkbKeymap == nullptr || !g_pSeatManager) {
        return;
    }

    const auto layout = keyboard->getActiveLayoutIndex().value_or(0);
    const KeyStrokeMap strokes = buildKeyStrokeMap(keyboard->m_xkbKeymap, layout);
    if (!strokes.backspace) {
        notifyError("The active keymap has no Backspace key.");
        return;
    }

    for (const auto& expansion : work) {
        injectExpansion(*g_pSeatManager, *keyboard, layout, strokes, expansion);
    }
}

void queueExpansion(const Expansion& expansion) {
    if (!g_pCompositor || g_pCompositor->m_wlEventLoop == nullptr) {
        notifyError("The Hyprland event loop is unavailable.");
        return;
    }

    pendingExpansions.push_back({expansion.trigger.size(), expansion.replacement});
    if (pendingIdleSource != nullptr) {
        return;
    }

    pendingIdleSource = wl_event_loop_add_idle(g_pCompositor->m_wlEventLoop, runPendingExpansions, nullptr);
    if (pendingIdleSource == nullptr) {
        pendingExpansions.clear();
        notifyError("Hyprland did not schedule the expansion.");
    }
}

bool isModifier(const xkb_keysym_t symbol) {
    const bool isCoreModifier = symbol >= XKB_KEY_Shift_L && symbol <= XKB_KEY_Hyper_R;
    if (isCoreModifier) {
        return true;
    }

    switch (symbol) {
        case XKB_KEY_Mode_switch:
        case XKB_KEY_Num_Lock:
        case XKB_KEY_Scroll_Lock:
        case XKB_KEY_ISO_Level3_Shift:
        case XKB_KEY_ISO_Level5_Shift:
            return true;
        default:
            return false;
    }
}

void handleKey(const IKeyboard::SKeyEvent& event, Event::SCallbackInfo&) {
    if (event.state != WL_KEYBOARD_KEY_STATE_PRESSED || expansions.empty()) {
        return;
    }

    auto keyboard = activePhysicalKeyboard();
    if (!keyboard || keyboard->m_xkbState == nullptr) {
        return;
    }

    constexpr uint32_t shortcutModifiers = HL_MODIFIER_CTRL | HL_MODIFIER_ALT | HL_MODIFIER_META;
    if ((keyboard->getModifiers() & shortcutModifiers) != 0) {
        recentText.clear();
        return;
    }

    const xkb_keycode_t keycode = event.keycode + xkbKeycodeOffset;
    const uint32_t character = xkb_state_key_get_utf32(keyboard->m_xkbState, keycode);
    if (!isPrintableAscii(character)) {
        const xkb_keysym_t symbol = xkb_state_key_get_one_sym(keyboard->m_xkbState, keycode);
        if (!isModifier(symbol)) {
            recentText.clear();
        }
        return;
    }

    recentText.push_back(static_cast<char>(character));
    if (recentText.size() > longestTrigger) {
        recentText.erase(0, recentText.size() - longestTrigger);
    }

    for (const auto& expansion : expansions) {
        if (!recentText.ends_with(expansion.trigger)) {
            continue;
        }

        recentText.clear();
        queueExpansion(expansion);
        return;
    }
}
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    if (!HyprlandAPI::addLuaFunction(PHANDLE, "hypr_expander", "add", addExpansion)) {
        throw std::runtime_error("Hyprland did not register hl.plugin.hypr_expander.add.");
    }

    keyListener = Event::bus()->m_events.input.keyboard.key.listen(handleKey);
    focusListener = Event::bus()->m_events.input.keyboard.focus.listen([] {
        clearInputState();
    });
    preReloadListener = Event::bus()->m_events.config.preReload.listen(clearExpansions);

    return {
        "hypr-expander",
        "The plugin expands configured ASCII text triggers.",
        "roly",
        "0.0.1",
    };
}

APICALL EXPORT void PLUGIN_EXIT() {
    keyListener.reset();
    focusListener.reset();
    preReloadListener.reset();
    clearExpansions();
    PHANDLE = nullptr;
}
