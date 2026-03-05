---@diagnostic disable-next-line: undefined-global
local hs = hs

local wf = hs.window.filter.new():setCurrentSpace(true):setScreens(hs.screen.primaryScreen():getUUID())
local windowList = {}
local windowIndex = 0

local function WindowHandler()
    local windows = wf:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end

    -- Simplified logic: if the count changed, we reset the cycle
    if #windows ~= #windowList then
        windowList = windows
        windowIndex = 1
    else
        windowIndex = (windowIndex % #windowList) + 1
    end

    if windowList[windowIndex] then
        windowList[windowIndex]:focus()
    end
end

-- 3. Key Map for Performance (Avoids repeated string lookups in hs.keycodes)
local keys = hs.keycodes.map

local function handleKeyDown(event)
    local kc      = event:getKeyCode()
    local mods    = event:getFlags()
    local isCmd   = mods.cmd and not (mods.ctrl or mods.alt)
    local isCtrl  = mods.ctrl and not (mods.cmd or mods.alt)
    local isAlt   = mods.alt and not (mods.cmd or mods.ctrl)
    local isHyper = mods.cmd and mods.ctrl and mods.alt

    -- window cycling
    if isCmd or isAlt then
        if (kc == keys["tab"]) then
            WindowHandler(); CenterMouse();
            return true
        end
    end

    -- window "management"
    if isCtrl then
        if kc == keys["left"] then
            WindowLeft(); return true
        end
        if kc == keys["down"] then
            WindowCenter(); return true
        end
        if kc == keys["up"] then
            WindowFill(); return true
        end
        if kc == keys["right"] then
            WindowRight(); return true
        end
    end

    if isHyper and kc == keys["down"] then
        WindowFloat(); return true
    end

    return false
end

EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()

local windowMenu = hs.menubar.new()
local iconCache = {} -- Prevents re-processing icons on every refresh
local excludedApps = { ["Notification Center"] = true }
local wf2 = hs.window.filter.new(true)

local function updateWindowMenu()
    local menuData = {}
    -- local allWindows = hs.window.allWindows()
    local allWindows = wf2:getWindows()

    for _, win in ipairs(allWindows) do
        local app = win:application()
        local winTitle = win:title()

        -- Filter out invalid windows, empty titles, and excluded apps
        if app and winTitle and winTitle ~= "" then
            local appName = app:name() or "Unknown App"

            if not excludedApps[appName] then
                -- Icon Caching: only resize the icon once per app bundle
                local bundleID = app:bundleID()
                if iconCache[bundleID] == nil then
                    local img = hs.image.imageFromAppBundle(bundleID)
                    iconCache[bundleID] = img and img:setSize({ w = 32, h = 32 }) or false
                end

                -- Styled Text for Menu Item
                local styledTitle = hs.styledtext.new(winTitle .. "\n", {
                    font = { size = 12, name = ".AppleSystemUIFontBold" }
                }) .. hs.styledtext.new(appName, {
                    font = { size = 10 },
                    color = { white = 0.5 }
                })

                table.insert(menuData, {
                    title = styledTitle,
                    key = (appName .. winTitle):lower(),
                    image = iconCache[bundleID] or nil,
                    fn = function(mods)
                        if mods.alt then
                            win:close()
                        else
                            if win:isMinimized() then win:unminimize() end
                            app:unhide()
                            win:focus()
                            if CenterMouse then CenterMouse(win) end
                        end
                    end
                })
            end
        end
    end

    table.sort(menuData, function(a, b) return a.key < b.key end)

    if #menuData == 0 then
        table.insert(menuData, { title = "No windows found", disabled = true })
    end

    windowMenu:setMenu(menuData)
    windowMenu:setTitle(#menuData > 0 and tostring(#menuData) or "")
end

-- Refresh logic
hs.hotkey.bind({ "alt" }, "W", function()
    updateWindowMenu()
    windowMenu:popupMenu(hs.mouse.absolutePosition())
end)

-- Watchers
hs.spaces.watcher.new(updateWindowMenu):start()

wf2:subscribe({
    hs.window.filter.windowCreated,
    hs.window.filter.windowDestroyed,
    hs.window.filter.windowMinimized,
    hs.window.filter.windowUnminimized
}, updateWindowMenu)

-- Initial run
updateWindowMenu()
