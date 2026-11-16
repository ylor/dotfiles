-- Text expander: typing a trigger replaces it with the snippet.
-- The plugin source is in plugins/hypr-expandr, built to hypr-expandr.so there.
local dir = os.getenv("HOME") .. "/.config/hypr/plugins/hypr-expandr"
local plugin = dir .. "/hypr-expandr.so"

if io.open(plugin) then
  hl.plugin.load(plugin)
end

-- The plugin has to match the running Hyprland, which only changes at login, so build
-- once per session: rebuild if the source changed or Hyprland was upgraded, then load it
-- by hand, because Hyprland retries a config plugin only when the requested paths
-- change. Only a fresh load prints "ok" and reloads to register the snippets below.
-- Trade-offs of building only at login:
-- - A reload doesn't rebuild. After editing the source mid-session, run make in the
--   plugin dir, then `hyprctl plugin unload` and `hyprctl plugin load` the .so.
-- - After a Hyprland upgrade, the old build loads before the new one is built. If
--   it loads, it runs until the next login, when the new build takes over.
hl.on("hyprland.start", function()
  hl.exec_cmd("make -s -C " .. dir .. "; hyprctl plugin load " .. plugin .. " | grep -qx ok && hyprctl reload")
end)

-- Hyprland loads plugins after the first config pass, then reloads the
-- config, so the function only exists on the second pass.
-- Base64 keeps the address out of plain text in the repo.
local function base64_decode(encoded)
  local pipe = io.popen("printf %s '" .. encoded .. "' | base64 -d")
  local decoded = pipe:read("a")
  pipe:close()
  return decoded
end

if hl.plugin.expandr then
  hl.plugin.expandr.add("@@ ", base64_decode("cm9seXJleWVzQG1lLmNvbQ=="))
end
