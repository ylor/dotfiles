---@diagnostic disable-next-line: undefined-global
local hs = hs

local menu = hs.menubar.new()
local iconCache = {}
local excludedApps = { ["Notification Center"] = true }
local max_char = 50

local function getIcon(bundleID)
    if iconCache[bundleID] == nil then
        local img = hs.image.imageFromAppBundle(bundleID)
        iconCache[bundleID] = img and img:setSize({ w = 32, h = 32 }) or false
    end
    return iconCache[bundleID] or nil
end

local mainFont = { size = 12, name = ".AppleSystemUIFontBold" }
local subFont  = { size = 10 }
local subColor = { white = 0.5 }

local function styledTitle(winTitle, appName)
    return hs.styledtext.new(winTitle .. "\n", { font = mainFont })
        .. hs.styledtext.new(appName, { font = subFont, color = subColor })
end

local function showMenu()
    local f = menu:frame()
    menu:popupMenu({ x = f.x, y = f.y + f.h })
end

local function updateMenu()
    local menuData = {}

    for _, win in ipairs(hs.window.allWindows()) do
        local app = win:application()
        local winTitle = win:title()
        local appName = app and app:name()

        if app and appName and not excludedApps[appName] and winTitle and winTitle ~= "" then
            if #winTitle > max_char then
                winTitle = winTitle:sub(1, max_char) .. "…"
            end

            local bundleID = app:bundleID()
            menuData[#menuData + 1] = {
                title = styledTitle(winTitle, appName),
                key   = (appName .. winTitle):lower(),
                image = getIcon(bundleID),
                fn    = function(mods)
                    if mods.alt then
                        win:close()
                        updateMenu()
                        showMenu()
                    else
                        if win:isMinimized() then win:unminimize() end
                        app:unhide()
                        win:focus()
                        if CenterMouse then CenterMouse(win) end
                    end
                end
            }
        end
    end

    table.sort(menuData, function(a, b) return a.key < b.key end)

    menu:setMenu(#menuData > 0 and menuData or { { title = "No windows found", disabled = true } })
    menu:setTitle(#menuData > 0 and tostring(#menuData) or "")
end

hs.hotkey.bind({ "alt" }, "W", function()
    updateMenu()
    showMenu()
end)

hs.spaces.watcher.new(updateMenu):start()

hs.window.filter.new(true):subscribe({
    hs.window.filter.windowCreated,
    hs.window.filter.windowDestroyed,
    hs.window.filter.windowMinimized,
    hs.window.filter.windowUnminimized
}, updateMenu)

updateMenu()
