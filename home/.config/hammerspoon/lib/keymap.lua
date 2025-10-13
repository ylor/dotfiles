---@diagnostic disable-next-line: undefined-global
local hs        = hs

Mod             = {}
Mod.main        = { "option" }
Mod.main.shift  = { "option", "shift" }
Mod.alt         = { "control" }
Mod.alt.shift   = { "control", "shift" }
Mod.combined    = { "control", "option" }
Mod.hyper       = { "control", "option", "command" }
Mod.hyper.shift = { "control", "option", "command", "shift" }
