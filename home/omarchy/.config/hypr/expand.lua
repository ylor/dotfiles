-- Text expander: typing a trigger replaces it with the snippet.
-- The plugin source is in plugins/expand; setup builds expand.so there.
local plugin = os.getenv("HOME") .. "/.config/hypr/plugins/expand/expand.so"

if io.open(plugin) then
  hl.plugin.load(plugin)
end

-- Hyprland loads plugins after the first config pass, then reloads the
-- config, so the function only exists on the second pass.
-- Base64 keeps the address out of plain text in the repo.
local function base64_decode(encoded)
  local pipe = io.popen("printf %s '" .. encoded .. "' | base64 -d")
  local decoded = pipe:read("a")
  pipe:close()
  return decoded
end

if hl.plugin.expand then
  hl.plugin.expand.add("@@ ", base64_decode("cm9seXJleWVzQG1lLmNvbQ=="))
end
