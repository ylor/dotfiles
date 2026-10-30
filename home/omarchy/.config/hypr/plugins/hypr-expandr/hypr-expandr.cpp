// Text expander. Watches typed characters and replaces a trigger with its
// snippet. Snippets come from hl.plugin.expandr.add(trigger, text) in Lua.
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
#include <vector>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
}

inline HANDLE PHANDLE = nullptr;

struct SSnippet {
    std::string               trigger;
    size_t                    backspaces; // trigger chars that already reached the app
    std::vector<xkb_keysym_t> keysyms;
};

struct SKeyStroke {
    xkb_keycode_t  keycode;
    xkb_mod_mask_t mods;
};

static std::vector<SSnippet> g_snippets;
static std::string           g_typed;

constexpr size_t MAX_TYPED = 128;

static bool isContinuationByte(char c) {
    return (static_cast<unsigned char>(c) & 0xC0) == 0x80;
}

static std::vector<xkb_keysym_t> toKeysyms(const std::string& s) {
    std::vector<xkb_keysym_t> out;
    for (size_t i = 0; i < s.size();) {
        const unsigned char lead = s[i];
        const int           len  = lead < 0x80 ? 1 : (lead >> 5) == 0x6 ? 2 : (lead >> 4) == 0xE ? 3 : 4;
        char32_t            cp   = len == 1 ? lead : lead & (0x3F >> (len - 1));
        for (int j = 1; j < len && i + j < s.size(); j++)
            cp = (cp << 6) | (s[i + j] & 0x3F);
        i += len;

        if (cp == '\n')
            out.push_back(XKB_KEY_Return);
        else if (cp == '\t')
            out.push_back(XKB_KEY_Tab);
        else
            out.push_back(xkb_utf32_to_keysym(cp));
    }
    return out;
}

// One pass over the keymap: the first key and modifier combo that produces each keysym.
static std::unordered_map<xkb_keysym_t, SKeyStroke> mapKeys(xkb_keymap* keymap, xkb_layout_index_t layout) {
    std::unordered_map<xkb_keysym_t, SKeyStroke> keys;
    const auto                                   last = xkb_keymap_max_keycode(keymap);
    for (auto keycode = xkb_keymap_min_keycode(keymap); keycode <= last; keycode++) {
        const auto levels = xkb_keymap_num_levels_for_key(keymap, keycode, layout);
        for (xkb_level_index_t level = 0; level < levels; level++) {
            const xkb_keysym_t* syms = nullptr;
            if (xkb_keymap_key_get_syms_by_level(keymap, keycode, layout, level, &syms) != 1)
                continue;

            xkb_mod_mask_t mods      = 0;
            const bool     reachable = xkb_keymap_key_get_mods_for_level(keymap, keycode, layout, level, &mods, 1) > 0;
            if (reachable || level == 0)
                keys.try_emplace(syms[0], SKeyStroke{keycode, mods});
        }
    }
    return keys;
}

// Sends keys straight to the focused client. They skip Hyprland's input
// handling, so they never come back through onKey.
static void replace(SP<IKeyboard> keyboard, uint32_t timeMs, const SSnippet& snippet) {
    const auto layout = xkb_state_serialize_layout(keyboard->m_xkbState, XKB_STATE_LAYOUT_EFFECTIVE);
    const auto keys   = mapKeys(keyboard->m_xkbKeymap, layout);

    std::optional<xkb_mod_mask_t> sentMods;
    auto                          tap = [&](const SKeyStroke& key) {
        if (sentMods != key.mods) {
            // Clear locked mods so Caps Lock doesn't flip the case.
            g_pSeatManager->sendKeyboardMods(key.mods, 0, 0, layout);
            sentMods = key.mods;
        }
        g_pSeatManager->sendKeyboardKey(timeMs, key.keycode - 8, WL_KEYBOARD_KEY_STATE_PRESSED);
        g_pSeatManager->sendKeyboardKey(timeMs, key.keycode - 8, WL_KEYBOARD_KEY_STATE_RELEASED);
    };

    if (const auto backspace = keys.find(XKB_KEY_BackSpace); backspace != keys.end()) {
        for (size_t i = 0; i < snippet.backspaces; i++)
            tap(backspace->second);
    }

    for (const auto sym : snippet.keysyms) {
        const auto key = keys.find(sym);
        if (key == keys.end()) {
            LOG(Log::WARN, "no key for keysym 0x{:x} in the current layout", sym);
            continue;
        }
        tap(key->second);
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
        while (!g_typed.empty()) {
            const char last = g_typed.back();
            g_typed.pop_back();
            if (!isContinuationByte(last))
                break;
        }
        return;
    }

    const bool shortcut = xkb_state_mod_names_are_active(state, XKB_STATE_MODS_EFFECTIVE, XKB_STATE_MATCH_ANY, XKB_MOD_NAME_CTRL, XKB_MOD_NAME_ALT, XKB_MOD_NAME_LOGO, nullptr) > 0;

    char       text[16]  = {};
    const int  length    = shortcut ? 0 : xkb_state_key_get_utf8(state, keycode, text, sizeof(text));
    const bool printable = length > 0 && static_cast<unsigned char>(text[0]) >= 0x20 && text[0] != 0x7F;
    if (!printable) {
        g_typed.clear();
        return;
    }

    g_typed += text;
    if (g_typed.size() > MAX_TYPED)
        g_typed.erase(0, g_typed.size() - MAX_TYPED);

    for (const auto& snippet : g_snippets) {
        if (!g_typed.ends_with(snippet.trigger))
            continue;

        g_typed.clear();
        // Swallow the last trigger key; the earlier ones already reached the app.
        info.cancelled = true;
        replace(keyboard, event.timeMs, snippet);
        return;
    }
}

static int luaAdd(lua_State* L) {
    const std::string trigger = luaL_checkstring(L, 1);
    const std::string text    = luaL_checkstring(L, 2);
    if (trigger.empty())
        return Config::Lua::Bindings::Internal::configError(L, "expandr.add: trigger must not be empty");

    SSnippet snippet{trigger, toKeysyms(trigger).size() - 1, toKeysyms(text)};

    const auto existing = std::ranges::find(g_snippets, trigger, &SSnippet::trigger);
    if (existing != g_snippets.end())
        *existing = std::move(snippet);
    else
        g_snippets.push_back(std::move(snippet));
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
        HyprlandAPI::addNotification(PHANDLE, "[hypr-expandr] Built for a different Hyprland. Rebuild it.", CHyprColor{1.0, 0.2, 0.2, 1.0}, 8000);
        throw std::runtime_error("[hypr-expandr] version mismatch");
    }

    static auto keyListener    = Event::bus()->m_events.input.keyboard.key.listen(onKey);
    static auto reloadListener = Event::bus()->m_events.config.preReload.listen([] { g_snippets.clear(); });
    // Typing after a click or focus change is a new context.
    static auto clickListener = Event::bus()->m_events.input.mouse.button.listen([](const IPointer::SButtonEvent&, Event::SCallbackInfo&) { g_typed.clear(); });
    static auto focusListener = Event::bus()->m_events.input.keyboard.focus.listen([](SP<CWLSurfaceResource>) { g_typed.clear(); });

    HyprlandAPI::addLuaFunction(PHANDLE, "expandr", "add", luaAdd);

    return {"hypr-expandr", "Replaces typed triggers with snippets", "roly", "1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {}
