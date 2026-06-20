--!strict
local ContentProvider = game:GetService('ContentProvider')

local Dark = require(script.Parent.Dark)
local Light = require(script.Parent.Light)

local toload = {} :: {ImageLabel}

for _, icons : any in Dark :: any do
	for _, v in icons do
		local icon = Instance.new('ImageLabel')

		icon.Image = v
		table.insert(toload, icon)
	end
end

for _, icons : any in Light :: any do
	for _, v in icons do
		local icon = Instance.new('ImageLabel')

		icon.Image = v
		table.insert(toload, icon)
	end
end

ContentProvider:PreloadAsync(toload, function(assetId : string, status : Enum.AssetFetchStatus)
	for i, icon in toload do
		if icon.Image == assetId then
			icon:Destroy()
			table.remove(toload, i)
		end
	end
end)

return nil