---@diagnostic disable-next-line: undefined-global
local hs         = hs

Mod              = {}
Mod.main         = { "control" }
Mod.main.shift   = { "control", "shift" }
Mod.option       = { "option" }
Mod.option.shift = { "option", "shift" }
Mod.combined     = { "control", "option" }
Mod.hyper        = { "control", "option", "command" }
Mod.hyper.shift  = { "control", "option", "command", "shift" }
