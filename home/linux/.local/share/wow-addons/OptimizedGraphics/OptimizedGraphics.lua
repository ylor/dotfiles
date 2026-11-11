-- Set on login and kept: when anything else changes one, such as the graphics menu, it is set back.
local VALUES = {
    ResampleAlwaysSharpen = "1",
    graphicsBloomUserMult = "0", -- the game menu's lowest
    graphicsShadowQuality = "2", -- Good
    graphicsSSAO = "3", -- High
    graphicsComputeEffects = "3", -- High
    graphicsLightMode = "2", -- Secondary Lighting: High
    rawMouseEnable = "1", -- smoother mouse look
}

-- False until the first apply after login, so nothing is changed before the delay below.
local ready = false

local function Enforce(cvar)
    if tonumber(GetCVar(cvar)) ~= tonumber(VALUES[cvar]) then
        SetCVar(cvar, VALUES[cvar])
    end
end

local function ApplyAll()
    for cvar in pairs(VALUES) do
        Enforce(cvar)
    end
    ready = true
end

-- Settings changes can arrive under another name or with no event at all, so check every one shortly after any change.
local pending = false
local function Recheck()
    if not ready or pending then return end
    pending = true
    C_Timer.After(0.5, function()
        pending = false
        ApplyAll()
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CVAR_UPDATE") -- anything changes a console variable
f:RegisterEvent("GX_RESTARTED") -- graphics restart after applying a graphics setting
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "PLAYER_ENTERING_WORLD" then
        if arg1 or arg2 then -- initial login or /reload
            -- changing secondary lighting right away used to crash the game
            C_Timer.After(3, ApplyAll)
        end
    else
        Recheck()
    end
end)

-- The graphics menu applies its changes when it closes.
if SettingsPanel then
    SettingsPanel:HookScript("OnHide", Recheck)
end
