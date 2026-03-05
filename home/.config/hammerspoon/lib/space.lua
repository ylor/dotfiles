---@diagnostic disable-next-line: undefined-global
local hs = hs

local spacesToAdd = 5 - #hs.spaces.spacesForScreen("Primary")
for _ = 1, math.max(0, spacesToAdd) do
    hs.spaces.addSpaceToScreen("Primary")
end

-- MARK: Menubar item
local spaceMenu = hs.menubar.new()

-- Function to get current space index and total count
local function getSpaceInfo()
    local screenSpaces = hs.spaces.spacesForScreen("Primary")
    local currentSpace = hs.spaces.activeSpaceOnScreen("Primary")

    for i, id in ipairs(screenSpaces) do
        if id == currentSpace then
            return i, #screenSpaces
        end
    end
    return nil, #screenSpaces
end

local function updateSpace()
    local currentIndex, totalSpaces = getSpaceInfo()

    if not currentIndex then
        spaceMenu:setTitle("?"); return
    end

    -- build indicator (e.g., ●○○○○)
    local indicator = ""
    for i = 1, totalSpaces do
        if i == currentIndex then
            indicator = indicator .. "◉"
        else
            indicator = indicator .. "○"
        end
    end

    spaceMenu:setTitle(indicator)
end

-- WATCHER: Update when the active space changes
hs.spaces.watcher.new(updateSpace):start()

updateSpace()

spaceMenu:setClickCallback(function()
    hs.openConsole(true)
    CenterMouse()
end)

-- Function to move window to space using mouse drag simulation
local function moveWindowToSpaceByDrag(spaceNumber)
    if spaceNumber == getSpaceInfo() then return end
    local win = hs.window.focusedWindow()
    if not win then return end

    local zoomButtonRect = win:zoomButtonRect()
    local headerX = zoomButtonRect.x + zoomButtonRect.w + 2
    local headerY = zoomButtonRect.y + (zoomButtonRect.h / 2)

    -- Store current mouse position
    local currentMouse = hs.mouse.getAbsolutePosition()

    -- Move mouse to window header
    hs.mouse.absolutePosition({ x = headerX, y = headerY })

    -- Mouse down (press and hold)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, { x = headerX, y = headerY }):post()
    -- hs.timer.usleep(10000) -- Wait 10ms

    -- Press Alt + number key (while holding mouse)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(spaceNumber), 0)
    hs.timer.usleep(10000) -- Wait 10ms

    -- Mouse up (release)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, { x = headerX, y = headerY }):post()
    hs.timer.usleep(10000) -- Wait 10ms

    -- Restore original mouse position
    hs.mouse.absolutePosition(currentMouse)

    -- Focus window
    hs.timer.doAfter(0.3, function()
        win:focus()
    end)
end

for i = 1, 5 do
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
