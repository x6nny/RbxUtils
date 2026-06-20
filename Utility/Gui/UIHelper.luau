local CollectionService = game:GetService("CollectionService")
local Camera = workspace.CurrentCamera

local UIHelper = {}

local Tags = {
    Scale = "_scale"
}

UIHelper.Settings = {
    Resolution = 900,
    Max = 5,
    Min = 0
}

local Cached = {} :: {[Instance]: number}

local function handle_scale()
	return math.clamp((Camera.ViewportSize.Y / UIHelper.Settings.Resolution), UIHelper.Settings.Min, UIHelper.Settings.Max)
end

function UIHelper.add(instance: Instance)
    if instance:HasTag(Tags.Scale) then
        return
    end

    CollectionService:AddTag(instance, Tags.Scale)
end

function UIHelper.SetScreenGui(ScreenGui: ScreenGui)
	ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	ScreenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	return ScreenGui
end

function UIHelper._fetch_resolution()

    while Camera.ViewportSize.Y <= 1 do 
        task.wait()
    end

    return Camera.ViewportSize.Y
end

local function instance_added(instance: Instance)
    if Cached[instance] then
        return
    end
	
    if instance:IsA("UIScale") then
        Cached[instance] = instance.Scale
    elseif instance:IsA("UIStroke") then
        Cached[instance] = instance.Thickness
	end
	
	local new_scale = handle_scale()
	if instance:IsA('UIScale') then
		instance.Scale = new_scale
	elseif instance:IsA('UIStroke') then
		instance.Thickness = (new_scale + Cached[instance]) + 1
	end
end

CollectionService:GetInstanceAddedSignal(Tags.Scale):Connect(instance_added)

CollectionService:GetInstanceRemovedSignal(Tags.Scale):Connect(function(object: Instance) 
    Cached[object] = nil
end)

for _, instance in CollectionService:GetTagged(Tags.Scale) do
    instance_added(instance)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    for element, default in Cached do

        local new_scale = handle_scale()
        if element:IsA("UIScale") then
            element.Scale = new_scale
        elseif element:IsA("UIStroke") then
            element.Thickness = (new_scale + default) + 1
        end
    end
end)

return UIHelper