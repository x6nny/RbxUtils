export type params = {
	IncludeInstances: {Instance?},
	ExcludeInstances: {Instance?},
	FilterType : Enum.RaycastFilterType,
	IgnoreWater : boolean?,
	BruteForceAllSlow : boolean?,
	CollisionGroup : string?,
	RespectCanCollide : boolean?
}

return function(raycastParams : params) : RaycastParams
	local params = RaycastParams.new()
	
	params.IncludeInstances = raycastParams.IncludeInstances
	params.ExcludeInstances = raycastParams.ExcludeInstances
	
	params.FilterType = raycastParams.FilterType
	params.IgnoreWater = raycastParams.IgnoreWater
	params.BruteForceAllSlow = raycastParams.BruteForceAllSlow
	params.CollisionGroup = raycastParams.CollisionGroup
	params.RespectCanCollide = raycastParams.RespectCanCollide
	
	return params
end