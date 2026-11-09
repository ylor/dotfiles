-- Set on login and kept: when anything else changes one, such as the graphics menu, it is set back.
local VALUES = {
    ResampleAlwaysSharpen = "1",
    graphicsBloomUserMult = "0", -- the game menu's lowest
    graphicsShadowQuality = "2", -- Good
    graphicsSSAO = "3", -- High
    graphicsComputeEffects = "3", -- High
    graphicsLightMode = "1", -- Secondary Lighting: Good
    rawMouseEnable = "1", -- smoother mouse look
}

local byLower = {} -- [lowercase console variable] = console variable
for cvar in pairs(VALUES) do
    byLower[cvar:lower()] = cvar
end

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

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Fires when anything changes a console variable, such as the graphics menu.
f:RegisterEvent("CVAR_UPDATE")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "CVAR_UPDATE" then
        local cvar = ready and type(arg1) == "string" and byLower[arg1:lower()]
        if cvar then Enforce(cvar) end
    elseif arg1 or arg2 then -- initial login or /reload
        -- changing secondary lighting right away used to crash the game
        C_Timer.After(3, ApplyAll)
    end
end)
