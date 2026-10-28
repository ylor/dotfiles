// Text expander. Watches typed characters and replaces a trigger with its
// snippet. Snippets come from hl.plugin.expand.add(trigger, text) in Lua.
#define WLR_USE_UNSTABLE

#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/SeatManager.hpp>
#include <hyprland/src/devices/IKeyboard.hpp>
#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/config/lua/bindings/LuaBindingsInternal.hpp>

#include <xkbcommon/xkbcommon.h>
#include <optional>
#include <unordered_map>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
}

inline HANDLE PHANDLE = nullptr;

static std::unordered_map<std::string, std::string> g_snippets;
static std::string                                  g_typed;

constexpr size_t MAX_TYPED = 128;

struct SKeyStroke {
    xkb_keycode_t  keycode;
    xkb_mod_mask_t mods;
};

static bool isContinuationByte(char c) {
    return (static_cast<unsigned char>(c) & 0xC0) == 0x80;
}

static size_t countChars(const std::string& s) {
    return std::ranges::count_if(s, [](char c) { return !isContinuationByte(c); });
}

static std::u32string decodeUtf8(const std::string& s) {
    std::u32string out;
    size_t         i = 0;
    while (i < s.size()) {
        const unsigned char lead = s[i];
        const int           len  = lead < 0x80 ? 1 : (lead >> 5) == 0x6 ? 2 : (lead >> 4) == 0xE ? 3 : 4;
        char32_t            cp   = len == 1 ? lead : lead & (0x3F >> (len - 1));
        for (int j = 1; j < len && i + j < s.size(); j++)
            cp = (cp << 6) | (s[i + j] & 0x3F);
        out += cp;
        i += len;
    }
    return out;
}

static xkb_keysym_t keysymFor(char32_t cp) {
    if (cp == '\n')
        return XKB_KEY_Return;
    if (cp == '\t')
        return XKB_KEY_Tab;
    return xkb_utf32_to_keysym(cp);
}

// Find a key and modifier combo in the current layout that produces sym.
static std::optional<SKeyStroke> findKey(xkb_keymap* keymap, xkb_layout_index_t layout, xkb_keysym_t sym) {
    const auto last = xkb_keymap_max_keycode(keymap);
    for (auto keycode = xkb_keymap_min_keycode(keymap); keycode <= last; keycode++) {
        const auto levels = xkb_keymap_num_levels_for_key(keymap, keycode, layout);
        for (xkb_level_index_t level = 0; level < levels; level++) {
            const xkb_keysym_t* syms  = nullptr;
            const int           count = xkb_keymap_key_get_syms_by_level(keymap, keycode, layout, level, &syms);
            if (count != 1 || syms[0] != sym)
                continue;

            xkb_mod_mask_t mods      = 0;
            const bool     reachable = xkb_keymap_key_get_mods_for_level(keymap, keycode, layout, level, &mods, 1) > 0;
            if (!reachable && level != 0)
                continue;

            return SKeyStroke{keycode, mods};
        }
    }
    return std::nullopt;
}

// Sends keys straight to the focused client. They skip Hyprland's input
// handling, so they never come back through onKey.
static void replace(SP<IKeyboard> keyboard, uint32_t timeMs, size_t backspaces, const std::string& text) {
    const auto keymap = keyboard->m_xkbKeymap;
    const auto layout = xkb_state_serialize_layout(keyboard->m_xkbState, XKB_STATE_LAYOUT_EFFECTIVE);

    auto tap = [&](const SKeyStroke& key) {
        // Clear locked mods so Caps Lock doesn't flip the case.
        g_pSeatManager->sendKeyboardMods(key.mods, 0, 0, layout);
        g_pSeatManager->sendKeyboardKey(timeMs, key.keycode - 8, WL_KEYBOARD_KEY_STATE_PRESSED);
        g_pSeatManager->sendKeyboardKey(timeMs, key.keycode - 8, WL_KEYBOARD_KEY_STATE_RELEASED);
    };

    if (const auto backspace = findKey(keymap, layout, XKB_KEY_BackSpace)) {
        for (size_t i = 0; i < backspaces; i++)
            tap(*backspace);
    }

    for (const auto cp : decodeUtf8(text)) {
        const auto key = findKey(keymap, layout, keysymFor(cp));
        if (!key) {
            Log::logger->log(Log::WARN, "[expand] no key for U+{:04X} in the current layout", static_cast<uint32_t>(cp));
            continue;
        }
        tap(*key);
    }

    const auto& mods = keyboard->m_modifiersState;
    g_pSeatManager->sendKeyboardMods(mods.depressed, mods.latched, mods.locked, mods.group);
}

static bool isModifier(xkb_keysym_t sym) {
    const bool classic = sym >= XKB_KEY_Shift_L && sym <= XKB_KEY_Hyper_R;
    const bool iso     = sym >= XKB_KEY_ISO_Lock && sym <= XKB_KEY_ISO_Last_Group_Lock;
    return classic || iso;
}

static void onKey(const IKeyboard::SKeyEvent& event, Event::SCallbackInfo& info) {
    if (event.state != WL_KEYBOARD_KEY_STATE_PRESSED || g_snippets.empty())
        return;

    // The key event doesn't say which keyboard sent it. The seat keyboard is
    // the last one that typed, which is the one in use.
    const auto keyboard = g_pSeatManager->m_keyboard.lock();
    if (!keyboard || !keyboard->m_xkbState)
        return;

    // Hyprland updates the xkb state after this event, so it still holds the
    // modifiers from before this key.
    const auto state   = keyboard->m_xkbState;
    const auto keycode = event.keycode + 8;
    const auto sym     = xkb_state_key_get_one_sym(state, keycode);

    if (isModifier(sym))
        return;

    if (sym == XKB_KEY_BackSpace) {
        while (!g_typed.empty() && isContinuationByte(g_typed.back()))
            g_typed.pop_back();
        if (!g_typed.empty())
            g_typed.pop_back();
        return;
    }

    const bool ctrl     = xkb_state_mod_name_is_active(state, XKB_MOD_NAME_CTRL, XKB_STATE_MODS_EFFECTIVE) > 0;
    const bool alt      = xkb_state_mod_name_is_active(state, XKB_MOD_NAME_ALT, XKB_STATE_MODS_EFFECTIVE) > 0;
    const bool super    = xkb_state_mod_name_is_active(state, XKB_MOD_NAME_LOGO, XKB_STATE_MODS_EFFECTIVE) > 0;
    const bool shortcut = ctrl || alt || super;

    char      text[16] = {};
    const int length   = xkb_state_key_get_utf8(state, keycode, text, sizeof(text));
    const bool printable = length > 0 && static_cast<unsigned char>(text[0]) >= 0x20 && text[0] != 0x7F;

    if (shortcut || !printable) {
        g_typed.clear();
        return;
    }

    g_typed += text;
    if (g_typed.size() > MAX_TYPED)
        g_typed.erase(0, g_typed.size() - MAX_TYPED);

    for (const auto& [trigger, snippet] : g_snippets) {
        if (!g_typed.ends_with(trigger))
            continue;

        g_typed.clear();
        // Swallow the last trigger key; the earlier ones already reached the app.
        info.cancelled = true;
        replace(keyboard, event.timeMs, countChars(trigger) - 1, snippet);
        return;
    }
}

static int luaAdd(lua_State* L) {
    const char* trigger = luaL_checkstring(L, 1);
    const char* snippet = luaL_checkstring(L, 2);
    if (!*trigger)
        return Config::Lua::Bindings::Internal::configError(L, "expand.add: trigger must not be empty");

    g_snippets[trigger] = snippet;
    return 0;
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string HASH        = __hyprland_api_get_hash();
    const std::string CLIENT_HASH = __hyprland_api_get_client_hash();
    if (HASH != CLIENT_HASH) {
        HyprlandAPI::addNotification(PHANDLE, "[expand] Built for a different Hyprland. Rebuild it.", CHyprColor{1.0, 0.2, 0.2, 1.0}, 8000);
        throw std::runtime_error("[expand] version mismatch");
    }

    static auto keyListener    = Event::bus()->m_events.input.keyboard.key.listen(onKey);
    static auto reloadListener = Event::bus()->m_events.config.preReload.listen([] { g_snippets.clear(); });
    // Typing after a click or focus change is a new context.
    static auto clickListener = Event::bus()->m_events.input.mouse.button.listen([](const IPointer::SButtonEvent&, Event::SCallbackInfo&) { g_typed.clear(); });
    static auto focusListener = Event::bus()->m_events.input.keyboard.focus.listen([](SP<CWLSurfaceResource>) { g_typed.clear(); });

    HyprlandAPI::addLuaFunction(PHANDLE, "expand", "add", luaAdd);

    return {"expand", "Replaces typed triggers with snippets", "roly", "1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {}
