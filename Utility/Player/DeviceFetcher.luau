--!strict
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')

type device = 'PC' | 'Mobile' | 'Controller' | nil
type displaySize = Enum.DisplaySize | nil

local DeviceFetcher = {
	currentDevice = nil,
	displaySize = nil,
	_changeListeners = {} :: {(device : device) -> ()},
	_displayChangeListeners = {} :: {(displaySize : displaySize) -> ()},
}

function DeviceFetcher.onDeviceChanged(fn : (device : device) -> ()) : () -> ()
	table.insert(DeviceFetcher._changeListeners, fn)
	
	return function()
		local index = table.find(DeviceFetcher._changeListeners, fn)
		if index then
			table.remove(DeviceFetcher._changeListeners, index)
		end
	end
end

function DeviceFetcher.onDisplaySizeChanged(fn : (displaySize : displaySize) -> ())
	table.insert(DeviceFetcher._displayChangeListeners, fn)
	
	return function()
		local index = table.find(DeviceFetcher._displayChangeListeners, fn)
		if index then
			table.remove(DeviceFetcher._displayChangeListeners, index)
		end
	end
end

function DeviceFetcher.getDevice() : device
	return DeviceFetcher.currentDevice
end

function DeviceFetcher.getDisplaySize() : displaySize
	return DeviceFetcher.displaySize
end

local function updateDevice()
	local input = UserInputService.PreferredInput
	local device = nil

	if input == Enum.PreferredInput.Touch then
		device = 'Mobile'
	elseif input == Enum.PreferredInput.Gamepad then
		device = 'Controller'
	elseif input == Enum.PreferredInput.KeyboardAndMouse then
		device = 'PC'
	end

	DeviceFetcher.currentDevice = device :: any

	for _, v in DeviceFetcher._changeListeners do
		task.spawn(v, DeviceFetcher.currentDevice)
	end
end

local function updateDisplaySize()
	DeviceFetcher.displaySize = GuiService.ViewportDisplaySize :: any
end

updateDevice()
updateDisplaySize()

UserInputService:GetPropertyChangedSignal('PreferredInput'):Connect(function()
	updateDevice()
end)

GuiService:GetPropertyChangedSignal('ViewportDisplaySize'):Connect(function()
	updateDisplaySize()
end)

return DeviceFetcher