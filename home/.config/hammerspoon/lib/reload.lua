---@diagnostic disable-next-line: undefined-global
local hs = hs
local config = hs.fs.pathToAbsolute(hs.configdir .. "/init.lua")
local configDir = config:match("(.*/)")
local paths = { hs.configdir, configDir }

for _, dir in pairs(paths) do
    hs.pathwatcher.new(dir, hs.reload):start()
end
