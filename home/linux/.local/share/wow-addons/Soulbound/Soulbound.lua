-- Set on login and kept: when anything else changes one, such as the settings menu, it is set back.
local VALUES = {
    -- Graphics
    ResampleAlwaysSharpen = "1",
    graphicsBloomUserMult = "0", -- the game menu's lowest
    graphicsShadowQuality = "2", -- Good
    graphicsSSAO = "3", -- High
    graphicsComputeEffects = "3", -- High
    graphicsLightMode = "2", -- Secondary Lighting: High

    -- Gameplay & controls
    autoLootDefault = "1",
    softTargetInteract = "3", -- Interact Key always on
    cameraSmoothStyle = "1", -- Camera Following Style: Only Horizontal When Moving
    cameraDistanceMaxZoomFactor = "4", -- if the game caps it lower, its cap is kept instead
    rawMouseEnable = "1", -- smoother mouse look

    -- Interface & display
    statusText = "1", -- health and power text shown without hovering
    statusTextDisplay = "BOTH", -- numbers and percentages
    chatBubblesRaid = "1",
    raidFramesDisplayPowerBars = "1",
    raidFramesHealthText = "none",
    countdownForCooldowns = "1",
    occludedSilhouettePlayer = "1",
    showTargetOfTarget = "1",

    -- Combat & casting
    enableMouseoverCast = "1",
    autoSelfCast = "1", -- Self Cast: Auto, with the self cast key below
    ActionButtonUseKeyHeldSpell = "1", -- press and hold casting

    -- System > Preset
    questPOI = "1", -- quest areas and points of interest on the map

    -- Social
    profanityFilter = "0",

    -- Nameplates
    nameplateShowClassColor = "1", -- enemy
    nameplateShowFriendlyClassColor = "1",

    -- Audio
    Sound_EnableSoundWhenGameIsInBG = "1",
    Sound_EnableErrorSpeech = "0",
}

-- Nameplate aggro display: these bits are turned on, the others are left alone.
local THREAT_BITS = { Enum.NamePlateThreatDisplay.Flash, Enum.NamePlateThreatDisplay.HealthBarColor }
local ACTION_BARS = { "PROXY_SHOW_ACTIONBAR_2", "PROXY_SHOW_ACTIONBAR_3" }

local BINDINGS = {
    F = "INTERACTTARGET",
    G = "TOGGLEPINGLISTENER", -- Ping
}

local TRACKING = { Enum.MinimapTrackingFilter.TrivialQuests, Enum.MinimapTrackingFilter.QuestPOIs } -- low-level quests, quest areas

-- False until the first apply after login, so nothing is changed before the delay below.
local ready = false

local function Same(a, b)
    return (tonumber(a) or a) == (tonumber(b) or b)
end

local function Enforce(cvar)
    local current = GetCVar(cvar)
    if current == nil then -- not in this version of the game
        VALUES[cvar] = nil
        return
    end
    if Same(current, VALUES[cvar]) then return end
    SetCVar(cvar, VALUES[cvar])
    -- A value the game refuses or caps would otherwise be set again after every change.
    local after = GetCVar(cvar)
    if not Same(after, VALUES[cvar]) then VALUES[cvar] = after end
end

local function EnforceThreatBits()
    for _, index in ipairs(THREAT_BITS) do
        if not C_CVar.GetCVarBitfield("nameplateThreatDisplay", index) then
            C_CVar.SetCVarBitfield("nameplateThreatDisplay", index, true)
        end
    end
end

-- Through the settings menu's own setting: it saves the toggle and also shows the bar,
-- which SetActionBarToggles alone does not do until the next reload.
local function EnforceActionBars()
    for _, variable in ipairs(ACTION_BARS) do
        if Settings.GetSetting(variable) and not Settings.GetValue(variable) then
            Settings.SetValue(variable, true)
        end
    end
end

local function EnforceBindings()
    local changed = false
    for key, action in pairs(BINDINGS) do
        if GetBindingAction(key) ~= action then
            SetBinding(key, action)
            changed = true
        end
    end
    -- Self Cast "Auto" means no self cast key; the game's default "Auto and Key Press" uses Alt.
    if GetModifiedClick("SELFCAST") ~= "NONE" then
        SetModifiedClick("SELFCAST", "NONE")
        changed = true
    end
    if changed then SaveBindings(GetCurrentBindingSet()) end
end

local function EnforceTracking()
    for _, id in ipairs(TRACKING) do
        local i = MinimapUtil.GetFilterIndexForFilterID(id)
        local info = i and C_Minimap.GetTrackingInfo(i)
        if info and not info.active then C_Minimap.SetTracking(i, true) end
    end
end

-- Raid-style party frames are part of the Edit Mode layout, which is left to the player: say so at login if they are off.
local function RemindRaidStyle()
    if not EditModeManagerFrame:UseRaidStylePartyFrames() then
        print("|cffffd200Soulbound:|r turn on Edit Mode > Party Frames > Use Raid-Style Party Frames.")
    end
end

local f = CreateFrame("Frame")

local function ApplyAll()
    -- Key bindings and some settings cannot change during combat.
    if InCombatLockdown() then
        f:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    for cvar in pairs(VALUES) do
        Enforce(cvar)
    end
    EnforceThreatBits()
    EnforceActionBars()
    EnforceBindings()
    EnforceTracking()
    ready = true
end

-- Settings changes can arrive under another name or with no event at all, so check every one shortly after any change.
-- Cleared after applying, so the events from its own changes do not schedule another pass.
local pending = false
local function RunPending()
    ApplyAll()
    pending = false
end
local function Recheck()
    if not ready or pending then return end
    pending = true
    C_Timer.After(0.5, RunPending)
end

-- Raw mouse saved as on does not take effect at startup; setting it again from the console does,
-- even though the value is already 1, so ApplyAll would skip it.
local function ReapplyRawMouse()
    if Same(GetCVar("rawMouseEnable"), "1") then ConsoleExec("rawMouseEnable 1") end
end

local function OnLogin()
    ApplyAll()
    ReapplyRawMouse()
    RemindRaidStyle()
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CVAR_UPDATE") -- anything changes a console variable
f:RegisterEvent("GX_RESTARTED") -- graphics restart after applying a graphics setting
f:RegisterEvent("UPDATE_BINDINGS")
f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "PLAYER_ENTERING_WORLD" then
        if arg1 or arg2 then -- initial login or /reload
            -- changing secondary lighting right away used to crash the game
            C_Timer.After(3, OnLogin)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        f:UnregisterEvent("PLAYER_REGEN_ENABLED")
        ApplyAll()
    else
        Recheck()
    end
end)

-- The settings menu applies its changes when it closes.
SettingsPanel:HookScript("OnHide", Recheck)
