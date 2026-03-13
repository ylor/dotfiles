---@diagnostic disable-next-line: undefined-global
local hs = hs

local iconCache = {}

local function appIcon(app)
    local id = app and app:bundleID()
    if not id then return nil end
    if not iconCache[id] then
        local img = hs.image.imageFromAppBundle(id)
        iconCache[id] = img and img:setSize({ w = 16, h = 16 }) or false
    end
    return iconCache[id] or nil
end

local wf = hs.window.filter.defaultCurrentSpace
local menu = hs.menubar.new()

local function updateCount()
    hs.timer.usleep(10000)
    menu:setTitle("⧉ " .. #wf:getWindows())
end

menu:setMenu(function()
    local windows = wf:getWindows()
    if #windows == 0 then
        return { { title = "No windows in current space", disabled = true } }
    end

    table.sort(windows, function(a, b)
        local nameA = a:application() and a:application():name() or ""
        local nameB = b:application() and b:application():name() or ""
        if nameA ~= nameB then return nameA < nameB end
        return a:title() < b:title()
    end)

    local items = {}
    local prevApp = nil
    for _, w in ipairs(windows) do
        local app = w:application()
        local appName = app and app:name() or "Unknown"
        local title = w:title()

        if prevApp and prevApp ~= appName then
            items[#items + 1] = { title = "-" }
        end
        prevApp = appName

        if title == "" then title = "Untitled" end
        if #title > 50 then title = title:sub(1, 49) .. "…" end

        items[#items + 1] = {
            title = title,
            image = appIcon(app),
            fn = function() w:focus() end,
        }
    end
    return items
end)

wf:subscribe(hs.window.filter.windowsChanged, updateCount)
updateCount()
