---@diagnostic disable-next-line: undefined-global
local hs = hs

local numberOfSpaces = 5
local spacesCount = #hs.spaces.spacesForScreen("Primary")
if numberOfSpaces > spacesCount then
    for _ = spacesCount + 1, numberOfSpaces do
        hs.spaces.addSpaceToScreen("Primary")
    end
end

-- MARK: Menubar item
local spaceMenu = hs.menubar.new()

local function getSpaceIndex()
    -- local screen = hs.screen.primaryScreen()
    local screenSpaces = hs.spaces.spacesForScreen("Primary")
    local currentSpace = hs.spaces.activeSpaceOnScreen("Primary")
    for i, id in ipairs(screenSpaces) do
        if id == currentSpace then
            return i
        end
    end
    return "?"
end

local function replace_unicode_char(str, index, replacement)
    local utf8 = require("utf8")
    local chars = {}
    for p, c in utf8.codes(str) do
        table.insert(chars, utf8.char(c))
    end
    chars[index] = replacement
    return table.concat(chars)
end

-- Function to update the menubar title
local function updateSpace()
    local index = getSpaceIndex()
    local dots = string.rep("○", #hs.spaces.spacesForScreen("Primary"))
    local filled = replace_unicode_char(dots, index, "●")
    spaceMenu:setTitle(filled)
end

-- Call once initially
updateSpace()

-- Set up watcher to respond to space changes
local spaceWatcher = hs.spaces.watcher.new(updateSpace)
spaceWatcher:start()

---------------------------------------------------

-- function moveWindowToSpace(window, spaceNumber)
--     local app = window:application()
--     local spaceId = hs.spaces.spacesForScreen()[spaceNumber]
--     local mousePosition = hs.mouse.absolutePosition()
--     local zoomButtonRect = window:zoomButtonRect()
--     if not zoomButtonRect then return end
--     if hs.spaces.focusedSpace() == spaceId then return end
--     hs.alert.show(window)
--     local windowTarget = { x = zoomButtonRect.x + zoomButtonRect.w + 5, y = zoomButtonRect.y + (zoomButtonRect.h / 2) }
--     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, windowTarget):post()
--     hs.timer.usleep(100000)
--     hs.eventtap.keyStroke({ "ctrl" }, tostring(spaceNumber), 0)
--     hs.timer.usleep(100000)
--     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, windowTarget):post()
--     LaunchOrFocusOrCycle(app)
--     CenterMouse(app)
-- end

-- hs.hotkey.bind({ "ctrl", "shift" }, "1", function()
--     moveWindowToSpace(hs.window.focusedWindow(), 1)
-- end)
-- hs.hotkey.bind({ "ctrl", "shift" }, "2", function()
--     moveWindowToSpace(hs.window.focusedWindow(), 2)
-- end)
-- hs.hotkey.bind({ "ctrl", "shift" }, "3", function()
--     moveWindowToSpace(hs.window.focusedWindow(), 3)
-- end)
-- hs.hotkey.bind({ "ctrl", "shift" }, "4", function()
--     moveWindowToSpace(hs.window.focusedWindow(), 4)
-- end)
-- hs.hotkey.bind({ "ctrl", "shift" }, "5", function()
--     moveWindowToSpace(hs.window.focusedWindow(), 5)
-- end)

-- Function to move window to space using mouse drag simulation
local function moveWindowToSpaceByDrag(spaceNumber)
    local win = hs.window.focusedWindow()
    if not win then return end

    local zoomButtonRect = win:zoomButtonRect()
    local headerX = zoomButtonRect.x + zoomButtonRect.w + 5
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
    hs.timer.doAfter(0.333, function()
        win:focus()
    end)
end

-- Bind keys cmd + shift + 1-6
for i = 1, 5 do
    hs.hotkey.bind({ "ctrl", "alt", "cmd" }, tostring(i), function()
        print("Hotkey pressed: cmd + shift + " .. i)
        moveWindowToSpaceByDrag(i)
    end)
end
