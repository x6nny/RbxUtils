local raycastParams = require(script.Parent.RaycastParams)

return function(position : Vector3, radius : number, direction : number, distance : number?, params : raycastParams.params) : RaycastResult
	local rayParams = if params then raycastParams(params) else nil
	local distance = distance or 1
	return workspace:Spherecast(position, radius, direction * distance, rayParams)
end