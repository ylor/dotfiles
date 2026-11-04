-- TODO: Remove this file, and its require in hyprland.lua, once these PRs are
-- merged and installed (check Omarchy's default/hypr/monitor-workspaces.lua):
--   https://github.com/omacom/omarchy/pull/16349 (fixes issue #16328)
--
-- Workaround for omacom/omarchy#16328.
--
-- When a monitor drops out and returns, Hyprland parks it on an empty
-- placeholder workspace under the lowest free number, usually 1. Omarchy's
-- reconcile() then can't give the returning workspaces their old numbers back
-- and shifts them to the next free slots, so every window lands one workspace
-- lower. Move such placeholders out of the way before reconcile() runs.

local workspaces = o.workspaces
local reconcile = workspaces.reconcile

local MERGED_FILE = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
  .. "/omarchy/monitors/workspaces-merged"

-- Original ids of workspaces that were merged into another monitor's block.
local function merged_origins()
  local origins = {}
  local file = io.open(MERGED_FILE, "r")
  if not file then return origins end

  for line in file:lines() do
    local origin = line:match("^%d+\t(%d+)\t")
    if origin then origins[#origins + 1] = tonumber(origin) end
  end

  file:close()
  return origins
end

local function vacate_placeholders()
  for _, origin in ipairs(merged_origins()) do
    local workspace = hl.get_workspace(origin)
    if workspace and not workspace.special and (workspace.windows or 0) == 0 then
      local spare = 1000 + origin
      if not hl.get_workspace(spare) then
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(origin), id = spare }))
      end
    end
  end
end

workspaces.reconcile = function(added, gone)
  if added then vacate_placeholders() end
  return reconcile(added, gone)
end
