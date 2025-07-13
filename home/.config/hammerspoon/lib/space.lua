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

function getSpaceIndex()
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

function replace_unicode_char(str, index, replacement)
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
    local dots = string.rep("􀀀", #hs.spaces.spacesForScreen("Primary"))
    local filled = replace_unicode_char(dots, index, "􀨂")

    spaceMenu:setTitle(filled)
    -- spaceMenu:setTitle(hs.styledtext.new(tostring(index),
    --     { font = { name = "SF Pro Rounded", size = 16 }, baselineOffset = -2.5 }))
    -- spaceMenu:setTitle(hs.styledtext.new("􀃋", { font = { size = 21 }, baselineOffset = -3.0 }))
end

-- Call once initially
updateSpace()

-- Set up watcher to respond to space changes
local spaceWatcher = hs.spaces.watcher.new(function()
    updateSpace()
end)
spaceWatcher:start()


local function moveWindowToSpace(window, spaceNumber)
    local mousePosition = hs.mouse.absolutePosition()
    local zoomButtonRect = window:zoomButtonRect()
    if not zoomButtonRect then return end

    local windowTarget = { x = zoomButtonRect.x + zoomButtonRect.w + 5, y = zoomButtonRect.y + (zoomButtonRect.h / 2) }
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, windowTarget):post()
    hs.timer.usleep(300000)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(spaceNumber), 0)
    hs.timer.usleep(300000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, windowTarget):post()
    hs.mouse.absolutePosition(mousePosition)
end

local function getFocusedWindowAndScreen()
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow or not focusedWindow:isStandard() or focusedWindow:isFullscreen() then return nil, nil end

    return focusedWindow, focusedWindow:screen()
end

hs.hotkey.bind({ "ctrl", "shift" }, "1", function()
    local focusedWindow = getFocusedWindowAndScreen()
    if not focusedWindow then return end
    moveWindowToSpace(focusedWindow, 1)
end)
hs.hotkey.bind({ "ctrl", "shift" }, "2", function()
    local focusedWindow = getFocusedWindowAndScreen()
    if not focusedWindow then return end
    moveWindowToSpace(focusedWindow, 2)
end)
hs.hotkey.bind({ "ctrl", "shift" }, "3", function()
    local focusedWindow = getFocusedWindowAndScreen()
    if not focusedWindow then return end
    moveWindowToSpace(focusedWindow, 3)
end)
