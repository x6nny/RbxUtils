local userInputService = game:GetService('UserInputService')
local camera = workspace.CurrentCamera

local raycastParams = require(script.Parent.RaycastParams)
local Raycast = require(script.Parent.Raycast)

return function(distance : number, rayParams : raycastParams.params?, depth : number?) : (RaycastResult?, Vector3)
	local mouseLocation = userInputService:GetMouseLocation()
	local mX, mY = mouseLocation.X, mouseLocation.Y
	
	local unitRay = camera:ViewportPointToRay(mX, mY, depth)
	local origin = unitRay.Origin
	local direction = unitRay.Direction
	
	return Raycast(origin, direction, distance, rayParams), origin + direction * distance
end