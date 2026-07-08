---@diagnostic disable-next-line: undefined-global
local hs = hs

function HeliumSelectAll()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "a", 0)
end

_G.HeliumModal = AppModal("Helium")
