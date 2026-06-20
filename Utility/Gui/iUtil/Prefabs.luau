local Prefabs = {}

local TrackedElements = {} :: any
local Camera = workspace:WaitForChild("Camera") :: Camera
local CurrentResolution = 1156 
local ResolutionMax = 1.5
local ResolutionMin = 0.5 

local function handle_scale(multiplier: number)
	return math.clamp((Camera.ViewportSize.Y / CurrentResolution) * multiplier, ResolutionMin, ResolutionMax)
end

local function update_by_instance(inst: Instance, ratio: number)
	if inst:IsA("UIScale") then
		inst.Scale = handle_scale(inst:GetAttribute("Multiplier"))
	elseif inst:IsA("UIStroke") then
		inst.Thickness = handle_scale(inst:GetAttribute("Multiplier") + 1)
	end
end

function Prefabs.FromInstance(instance: Instance, multiplier: number?)
	multiplier = multiplier or instance:GetAttribute("Multiplier") or 1

	for _, item in instance:GetDescendants() do
		if item:IsA("UIStroke") or item:IsA("UIScale") then
			item:SetAttribute("Multiplier", multiplier)
			table.insert(TrackedElements, item)
		end
	end

	return instance
end

function Prefabs.Add(instance: Instance, multiplier: number?)
	multiplier = multiplier or instance:GetAttribute("Multiplier") or 1

	if instance:IsA("UIStroke") or instance:IsA("UIScale") then
		instance:SetAttribute("Multiplier", multiplier)
		table.insert(TrackedElements, instance)
	end

	return instance
end

function Prefabs.ScreenGui(name: string)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = name
	ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	ScreenGui.ScreenInsets = Enum.ScreenInsets.None
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return ScreenGui
end

function Prefabs.ContainerFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Transparency = 1
	return frame
end

function Prefabs.OriginFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0, 0)
	frame.Transparency = 1
	return frame
end

function Prefabs.UIScale(multiplier: number?)
	multiplier = multiplier or 1 

	local uiscale = Instance.new("UIScale")
	uiscale.Scale = handle_scale(multiplier :: any)
	uiscale:SetAttribute("Multiplier", multiplier)

	table.insert(TrackedElements, uiscale)
	return uiscale
end

function Prefabs.UIStroke(multiplier: number?)
	multiplier = multiplier or 1

	local uistroke = Instance.new("UIStroke")
	uistroke.Thickness = handle_scale(multiplier :: any) + 1
	uistroke:SetAttribute("Multiplier", multiplier)
	table.insert(TrackedElements, uistroke)
	return uistroke 
end

function Prefabs.updateScale()
	local UIScales = TrackedElements

	for i = #UIScales, 1, -1 do
		local item = UIScales[i]
		if item.Parent == nil then table.remove(UIScales, i); continue end
		update_by_instance(item, handle_scale(1))
	end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Prefabs.updateScale)

return Prefabs