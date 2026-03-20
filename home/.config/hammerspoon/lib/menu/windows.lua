---@diagnostic disable-next-line: undefined-global
local hs = hs

local wf = hs.window.filter.copy(hs.window.filter.defaultCurrentSpace)
local menu = hs.menubar.new()
local iconCache = {}

-- Menu content builder
menu:setMenu(function()
    local windows = wf:getWindows()
    if #windows == 0 then
        return { { title = "No windows in current space", disabled = true } }
    end

    table.sort(windows, function(a, b)
        local appA = a:application()
        local appB = b:application()
        local nameA = appA and appA:name() or ""
        local nameB = appB and appB:name() or ""
        if nameA ~= nameB then return nameA < nameB end
        return (a:title() or "") < (b:title() or "")
    end)

    local items = {}
    local prevApp
    for _, w in ipairs(windows) do
        local app = w:application()
        local appName = app and app:name() or "Unknown"

        if prevApp and prevApp ~= appName then
            items[#items + 1] = { title = "-" }
        end
        prevApp = appName

        -- Icon with cache
        local id = app and app:bundleID()
        if id and iconCache[id] == nil then
            local img = hs.image.imageFromAppBundle(id)
            iconCache[id] = img and img:setSize({ w = 16, h = 16 }) or false
        end

        local title = w:title() or "Untitled"
        if #title > 50 then title = title:sub(1, 49) .. "…" end

        items[#items + 1] = {
            title = title,
            image = id and iconCache[id] or nil,
            fn = function() w:focus() end,
        }
    end
    return items
end)

local function updateCount()
    hs.timer.doAfter(0.1, function()
        menu:setTitle("⧉ " .. #wf:getWindows())
    end)
end

wf:subscribe(hs.window.filter.windowsChanged, updateCount)
updateCount()
