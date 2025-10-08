---@diagnostic disable-next-line: undefined-global
local hs         = hs

Mod              = {}
Mod.main         = { "option" }
Mod.main.shift   = { "option", "shift" }
Mod.option       = { "control" }
Mod.option.shift = { "control", "shift" }
Mod.combined     = { "control", "option" }
Mod.hyper        = { "control", "option", "command" }
Mod.hyper.shift  = { "control", "option", "command", "shift" }
