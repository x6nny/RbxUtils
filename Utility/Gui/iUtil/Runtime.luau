--!strict
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local Prefabs = require(script.Parent.Prefabs)

local Runtime = {}
Runtime.Context = if RunService:IsClient() and RunService:IsRunning() then "Live" else "Plugin"
Runtime.ContextIsLive = Runtime.Context == "Live"

function Runtime.Holder(holder_name: string)
	local Holder: any

	if Runtime.ContextIsLive then
		Holder = Prefabs.ScreenGui(holder_name)
		Holder.ResetOnSpawn = false
	else
		Holder = Prefabs.ContainerFrame()
	end

	return Holder :: Instance
end

return Runtime