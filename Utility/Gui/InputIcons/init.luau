--!strict
local Dark = require(script.Dark)
local Light = require(script.Light)

task.spawn(require, script.Preload)

return {
	Dark = Dark,
	Light = Light
}