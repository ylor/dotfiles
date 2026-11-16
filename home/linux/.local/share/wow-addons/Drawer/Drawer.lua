-- Moves every addon's minimap button into the minimap's AddOns drawer (Blizzard's addon
-- compartment) and keeps it off the minimap. Runs when the UI loads: login and /reload.

-- "|cffffd200Leatrix Plus|r", "Leatrix_Plus" and "WhatsTrainingMinimap" become
-- "leatrixplus" and "whatstraining", so a button name can be matched to a drawer entry.
local function key(text)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower():gsub("[^%w]", "")
    return (text:gsub("minimap$", ""))
end

-- The drawer's own list: TOC entries (by title) and ones added in code (LibDBIcon's by name).
local function inDrawer(name)
    local wanted = key(name)
    for _, entry in ipairs(AddonCompartmentFrame.registeredAddons) do
        if key(entry.text) == wanted then return true end
    end
    return false
end

-- Hidden for good: whatever shows the button again (its addon, a hover fade) is undone.
local function stash(button)
    button:Hide()
    button:HookScript("OnShow", button.Hide)
end

local function move(icon, name, button)
    if not inDrawer(name) and button.dataObject.OnClick then
        icon:AddButtonToCompartment(name)
    end
    stash(button)
end

-- Buttons made without LibDBIcon, such as OpenMapMinimapButton. Only those whose addon
-- is in the drawer are hidden, so none becomes unreachable.
local function stashOwnButtons()
    for _, child in ipairs({ Minimap:GetChildren() }) do
        local addon = (child:GetName() or ""):match("^(.+)MinimapButton$")
        if addon and inDrawer(addon) then stash(child) end
    end
end

local function run()
    local icon = LibStub and LibStub("LibDBIcon-1.0", true)
    if icon then
        for _, name in ipairs(icon:GetButtonList()) do
            move(icon, name, icon:GetMinimapButton(name))
        end
        -- Buttons registered later.
        icon.RegisterCallback("Drawer","LibDBIcon_IconCreated", function(_, button, name)
            move(icon, name, button)
        end)
    end
    stashOwnButtons()
end

-- The drawer adds TOC entries on the first PLAYER_ENTERING_WORLD, so wait a frame past it.
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    if AddonCompartmentFrame then C_Timer.After(0, run) end
end)
