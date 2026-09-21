local function SetLow()
    SetCVar("graphicsLightMode", "0")
    SetCVar("raidGraphicsLightMode", "0")
    SetCVar("giQuality", "1")
    SetCVar("RAIDgiQuality", "1")
end

local function SetHigh()
    SetCVar("graphicsLightMode", "2")
    SetCVar("raidGraphicsLightMode", "2")
    SetCVar("giQuality", "3")
    SetCVar("RAIDgiQuality", "3")
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_LEAVING_WORLD")

f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Without a small delay it still crashes.
        C_Timer.After(3, SetHigh)
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" then
        SetLow()
    end
end)
