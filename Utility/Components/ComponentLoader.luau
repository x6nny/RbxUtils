--!strict
local CollectionService = require(script.Parent.Collection)

local ComponentLoader = { }
local CachedInstances = { }

local function shouldCleanupCachedInstance(instance) : boolean
	local numberTagsRegistered = 0
	
	if CachedInstances[instance] then
		for tag, comp in pairs(CachedInstances[instance]) do
			numberTagsRegistered += 1
		end
	end
	
	return numberTagsRegistered == 0
end

local function loadComponents(input : {ModuleScript?})
	for _, componentModule in input :: any do
		if not componentModule:IsA('ModuleScript') then continue end
		
		local component = require(componentModule) :: any
		local tag = component.Tag
		
		local function instanceAdded(instance)
			CachedInstances[instance] = if CachedInstances[instance] then CachedInstances[instance] else {}
			
			if CachedInstances[instance][tag] then
				return
			end
			
			local newInstance = component.new(instance)
			CachedInstances[instance][tag] = newInstance
		end
		
		local function instanceRemoved(instance)
			local cached = CachedInstances[instance]
			if cached then
				local currentComponent = cached[tag] :: any
				if currentComponent then
					if typeof(currentComponent) == 'table' and currentComponent.Destroy and typeof(currentComponent.Destroy) == 'function' then
						(currentComponent.Destroy :: any)()
					end
					if typeof(currentComponent) == 'function' then
						(currentComponent :: any)()
					end
					cached[tag] = nil
					
					if shouldCleanupCachedInstance(instance) then
						CachedInstances[instance] = nil
					end
				end
			end
		end
		
		local collection = CollectionService(tag)
		
		collection:tagAdded(instanceAdded)
		collection:tagRemoved(instanceRemoved)
	end
end

function ComponentLoader.Load(components : {ModuleScript?} | Instance)
	if typeof(components) == 'table' then
		loadComponents(components)
	elseif typeof(components) == 'Instance' then
		local modules = components:QueryDescendants('ModuleScript') :: {ModuleScript?}
		loadComponents(modules)
	end
end

return ComponentLoader