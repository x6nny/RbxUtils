local raycastParams = require(script.Parent.RaycastParams)

return function(cframe : CFrame, size : Vector3, direction : number, distance : number?, params : raycastParams.params) : RaycastResult
	local rayParams = if params then raycastParams(params) else nil
	local distance = distance or 1
	return workspace:Blockcast(cframe, size, direction * distance, rayParams)
end