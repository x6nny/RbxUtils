local raycastParams = require(script.Parent.RaycastParams)

return function(origin, direction, distance, params : raycastParams.params?) : (RaycastResult?, Vector3)
	local rayParams = if params then raycastParams(params) else nil
	return workspace:Raycast(origin, direction * distance, rayParams), origin + direction * distance
end