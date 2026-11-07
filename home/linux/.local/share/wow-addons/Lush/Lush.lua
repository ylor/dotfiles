local ADDON = ...

local function yards(value)
    return value .. " yd"
end

-- Each row is one console variable, with its slider range and the value set on login.
local OPTIONS = {
    {cvar = "groundEffectDensity", name = "Density", min = 0, max = 256, step = 8, default = 64,
        format = tostring, tooltip = "How thick the grass grows."},
    {cvar = "groundEffectDist", name = "Draw Distance", min = 0, max = 600, step = 10, default = 500,
        format = yards, tooltip = "How far away grass is drawn."},
    {cvar = "groundEffectFade", name = "Fade Range", min = 0, max = 600, step = 10, default = 370,
        format = yards, tooltip = "How gradually grass fades out near the draw distance."},
}

local category

local byCvar = {} -- [lowercase console variable] = option
for _, option in ipairs(OPTIONS) do
    byCvar[option.cvar:lower()] = option
end

-- True while a preset moves the sliders: the game may write its own values meanwhile, and
-- the move is not taken as a custom change.
local applyingPreset = false

local enabledSetting

-- Lush only holds its values while switched on; off leaves the game's own in charge.
local function Active()
    return LushDB.enabled ~= false
end

-- Writes the saved value back if something else has changed it.
local function Enforce(option)
    if not Active() then return end
    local wanted = option.setting:GetValue()
    if tonumber(GetCVar(option.cvar)) ~= wanted then
        SetCVar(option.cvar, tostring(wanted))
    end
end

-- Has the game re-apply the graphics menu's Ground Clutter level. The level is changed and
-- put back, because setting it to its own value may not make the game write anything. The
-- sliders keep their saved values for when Lush is switched back on.
local function UseGameLevel()
    local level = tonumber(GetCVar("graphicsGroundClutter")) or 0
    SetCVar("graphicsGroundClutter", tostring(level == 0 and 1 or level - 1))
    SetCVar("graphicsGroundClutter", tostring(level))
    -- The level sets density and distance but not fade, which has no menu setting, so fade
    -- goes back to the game's own default.
    SetCVar("groundEffectFade", C_CVar.GetCVarDefault("groundEffectFade"))
end

local function EnforceAll()
    for _, option in ipairs(OPTIONS) do
        Enforce(option)
    end
end

-- Each preset sets all three sliders, in the order of OPTIONS: density, draw distance, fade.
local PRESETS = {
    {name = "Minimal", values = {0, 0, 0}},
    {name = "Good", values = {64, 500, 370}},
    {name = "High", values = {128, 500, 370}},
    {name = "Ultra", values = {256, 500, 370}},
}

local presetSetting

local function ApplyPreset(name)
    applyingPreset = true
    for _, preset in ipairs(PRESETS) do
        if preset.name == name then
            for i, option in ipairs(OPTIONS) do
                option.setting:SetValue(preset.values[i])
            end
        end
    end
    applyingPreset = false
end

-- The preset whose values the sliders currently hold, or "custom" if none.
local function DetectPreset()
    for _, preset in ipairs(PRESETS) do
        local match = true
        for i, option in ipairs(OPTIONS) do
            if option.setting:GetValue() ~= preset.values[i] then match = false end
        end
        if match then return preset.name end
    end
    return "custom"
end

local function PresetOptions()
    local container = Settings.CreateControlTextContainer()
    for _, preset in ipairs(PRESETS) do
        container:Add(preset.name, preset.name)
    end
    return container:GetData()
end

-- Greys a row out, and keeps it in step with the checkbox, while Lush is switched off.
local function DependOnEnabled(row, enabledRow)
    row:SetParentInitializer(enabledRow, Active)
    -- Blizzard indents a row and shrinks its label when its parent is on the same page; this
    -- keeps the greying but not the indent.
    function row:IsParentInitializerInLayout() return false end
end

local function RegisterOptions()
    local layout
    category, layout = Settings.RegisterVerticalLayoutCategory("Lush")

    enabledSetting = Settings.RegisterAddOnSetting(category, "Lush_enabled", "enabled", LushDB,
        Settings.VarType.Boolean, "Enable Lush", true)
    -- The callback's arguments vary between game versions, so the value is read back instead.
    enabledSetting:SetValueChangedCallback(function()
        if enabledSetting:GetValue() then EnforceAll() else UseGameLevel() end
    end)

    for _, option in ipairs(OPTIONS) do
        option.setting = Settings.RegisterAddOnSetting(category, "Lush_" .. option.cvar, option.cvar,
            LushDB, Settings.VarType.Number, option.name, option.default)
        option.setting:SetValueChangedCallback(function()
            Enforce(option)
            if not applyingPreset then
                local name = DetectPreset()
                if LushDB.preset ~= name then presetSetting:SetValue(name) end
            end
        end)
    end

    -- The chosen preset is remembered only to show it; the sliders hold the real values.
    presetSetting = Settings.RegisterProxySetting(category, "Lush_preset", Settings.VarType.String, "Preset",
        "Good",
        function() return LushDB.preset or "custom" end,
        function(name)
            LushDB.preset = name
            ApplyPreset(name)
        end)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("General"))
    local enabledRow = Settings.CreateCheckbox(category, enabledSetting,
        "Off uses the graphics menu's Ground Clutter level.")
    DependOnEnabled(Settings.CreateDropdown(category, presetSetting, PresetOptions), enabledRow)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Fine Tuning",
        "More grass than the game's Ground Clutter setting allows. Higher density and draw distance cost framerate."))
    for _, option in ipairs(OPTIONS) do
        local slider = Settings.CreateSliderOptions(option.min, option.max, option.step)
        slider:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, option.format)
        DependOnEnabled(Settings.CreateSlider(category, option.setting, slider, option.tooltip), enabledRow)
    end

    Settings.RegisterAddOnCategory(category)
end

local function OpenOptions()
    Settings.OpenToCategory(category:GetID())
end

local function Say(text)
    print("|cff33ff99Lush:|r " .. text)
end

-- /lush opens the options; /lush <preset> applies one, so it can go in a macro.
SLASH_LUSH1 = "/lush"
SlashCmdList.LUSH = function(message)
    local word = strtrim(message):lower()
    if word == "" then
        OpenOptions()
        return
    end
    if word == "on" or word == "off" then
        enabledSetting:SetValue(word == "on")
        Say(word == "on" and "On." or "Off. Using the graphics menu's level.")
        return
    end
    local names = {}
    for _, preset in ipairs(PRESETS) do
        if word == preset.name:lower() then
            enabledSetting:SetValue(true)
            presetSetting:SetValue(preset.name)
            Say(preset.name .. " applied.")
            return
        end
        names[#names + 1] = preset.name:lower()
    end
    Say("Unknown preset. Try /lush " .. table.concat(names, ", /lush ") .. ", /lush on, /lush off, or /lush to open the options.")
end

-- Called by the addon list in the minimap corner, set in the .toc.
function Lush_OnCompartmentClick()
    OpenOptions()
end

function Lush_OnCompartmentEnter(_, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:AddLine("Lush")
    GameTooltip:AddLine("Click to open the options.", 1, 1, 1)
    GameTooltip:Show()
end

function Lush_OnCompartmentLeave()
    GameTooltip:Hide()
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Fires when anything changes a console variable, such as the graphics menu.
f:RegisterEvent("CVAR_UPDATE")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        LushDB = LushDB or {}
        RegisterOptions()
        LushDB.preset = DetectPreset()
    elseif event == "CVAR_UPDATE" then
        local option = type(arg1) == "string" and byCvar[arg1:lower()]
        if option and option.setting and not applyingPreset then Enforce(option) end
    elseif arg1 or arg2 then -- initial login or /reload
        EnforceAll()
    end
end)
