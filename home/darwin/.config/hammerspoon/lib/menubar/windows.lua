---@diagnostic disable-next-line: undefined-global
local hs = hs

local wf = hs.window.filter.copy(hs.window.filter.defaultCurrentSpace)
local menu = hs.menubar.new()
local iconCache = {}

-- Menu content builder
menu:setMenu(function()
    local windows = wf:getWindows()
    -- if #windows == 0 then
    --     return { { title = "No windows in current space", disabled = true } }
    -- end

    table.sort(windows, function(a, b)
        local appA = a:application():name()
        local appB = b:application():name()
        if appA ~= appB then return appA < appB end
        return (a:title()) < (b:title())
    end)

    local items = {}
    for i, w in ipairs(windows) do
        local app = w:application()
        local appName = app and app:name() or "Unknown"

        -- separator: compare to previous window's app instead of a mutable variable
        if i > 1 then
            local prevApp = windows[i - 1]:application()
            local prevName = prevApp and prevApp:name() or "Unknown"
            if prevName ~= appName then
                items[#items + 1] = { title = "-" }
            end
        end

        local title = w:title()
        if #title == 0 then title = app:name() end
        if #title > 50 then title = title:sub(1, 50) .. "…" end

        local id = app and app:bundleID()
        if id and iconCache[id] == nil then
            local img = hs.image.imageFromAppBundle(id)
            iconCache[id] = img and img:setSize({ w = 16, h = 16 }) or false
        end

        items[#items + 1] = {
            title = title,
            image = id and iconCache[id] or nil,
            fn = function() w:focus() end,
        }
    end
    return items
end)

local function updateCount()
    menu:setTitle("⧉ " .. #wf:getWindows())
end

wf:subscribe(hs.window.filter.windowsChanged, updateCount)
updateCount()
