--!strict
local StarterGui = game:GetService('StarterGui')
local SetCoreGuiEnabled = StarterGui.SetCoreGuiEnabled
local GetCoreGuiEnabled = StarterGui.GetCoreGuiEnabled
local SetCore = StarterGui.SetCore
local GetCore = StarterGui.GetCore

local defaultResetBindable = nil

local function getCoreGuiEnabled(coreGui : Enum.CoreGuiType) : boolean
	return GetCoreGuiEnabled(StarterGui, coreGui)
end

local function setCoreGuiEnabled(coreGui : Enum.CoreGuiType, enabled : boolean) : boolean
	SetCoreGuiEnabled(StarterGui, coreGui, enabled)
	return getCoreGuiEnabled(coreGui)
end

local function requestCore(...)
	local succ = pcall(SetCore, StarterGui, ...)
	return succ
end

local function requestGetCore(value : string)
	local succ, result = pcall(function()
		return GetCore(StarterGui, value)
	end)
	return succ, result
end

local function getCore(core : string)
	local succ, result = requestGetCore(core)
	if not succ then
		task.wait()
		return getCore(core)
	end
	return result
end

local function disableReset()
	if defaultResetBindable == nil then
		defaultResetBindable = getCore('ResetButtonCallback')
	end
	local result = requestCore('ResetButtonCallback', false)
	if not result then
		task.wait()
		disableReset()
	end
end

local function enableReset()
	if defaultResetBindable == nil then return end
	
	local result = requestCore('ResetButtonCallback', defaultResetBindable)
	if not result then
		task.wait()
		enableReset()
	end
end

return {
	getCoreGuiState = getCoreGuiEnabled,
	setCoreGuiEnabled = setCoreGuiEnabled,
	getCore = getCore,
	disableReset = disableReset,
	enableReset = enableReset
}