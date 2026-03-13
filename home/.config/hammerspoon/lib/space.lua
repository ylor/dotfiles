---@diagnostic disable-next-line: undefined-global
local hs = hs

local spaceMenu = hs.menubar.new()

local function getSpaceInfo()
    local spaces = hs.spaces.spacesForScreen("Main")
    local active = hs.spaces.activeSpaceOnScreen("Main")
    return hs.fnutils.indexOf(spaces, active), #spaces
end

local function updateMenu()
    local index, total = getSpaceInfo()
    local dots = string.rep("○", index - 1) .. "◉" .. string.rep("○", total - index)
    spaceMenu:setTitle(dots)
end

spaceMenu:setClickCallback(hs.openConsole)
updateMenu()

SpaceWatcherForSpaces = hs.spaces.watcher.new(updateMenu):start()
ScreenWatcherForSpaces = hs.screen.watcher.new(updateMenu):start()

local function moveWindowToSpaceByDrag(targetSpace)
    local currentSpace = getSpaceInfo()
    if targetSpace == currentSpace then return end

    local win = hs.window.focusedWindow()
    if not win then return end

    local zoom = win:zoomButtonRect()
    local dragPos = { x = zoom.x + zoom.w + 2, y = zoom.y + (zoom.h / 2) + 10 }
    local savedPos = hs.mouse.absolutePosition()

    hs.mouse.absolutePosition(dragPos)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, dragPos):post()
    hs.timer.usleep(10000)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(targetSpace), 0)
    hs.timer.usleep(10000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, dragPos):post()
    hs.timer.doAfter(0.333, function() win:focus() end)
    hs.mouse.absolutePosition(savedPos)
end

for i = 1, 5 do
    if i > #hs.spaces.spacesForScreen("Primary") then
        hs.spaces.addSpaceToScreen("Primary")
    end

    hs.hotkey.bind({ "ctrl", "shift" }, tostring(i), function()
        moveWindowToSpaceByDrag(i)
    end)
end



























-- local function handleAppLaunch(appName)
--     local apps = {}
--     if Work then
--         apps = {
--             ["Arc"] = 1,
--             ["Safari"] = 1,
--             ["Slack"] = 2,
--             ["Ghostty"] = 3,
--             ["Zed"] = 3,
--             ["Screen Sharing"] = 4,
--         }
--     else
--         apps = {
--             ["Safari"] = 1,
--             ["Ghostty"] = 2,
--             ["Zed"] = 2,
--             ["Messages"] = 3,
--             ["Screen Sharing"] = 3
--         }
--     end

--     if apps[appName] == GetSpaceIndex() then return end
--     if apps[appName] then
--         moveWindowToSpaceByDrag(apps[appName])
--     end
-- end

-- ---needs to be a global var otherwise it gets garbage collected apparently
-- appwatcher = hs.application.watcher.new(function(appName, event)
--         if event == hs.application.watcher.launched then
--             hs.timer.doAfter(0.1, function()
--                 handleAppLaunch(appName)
--             end)
--         end
--     end)
--     :start()
