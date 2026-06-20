type cooldown = {
	cooldowns : {
		[any] : { -- key
			[any] : number -- tag
		}
	},
	
	check : (cooldown : cooldown, key : any, tag : any, duration : number) -> boolean,
	remove : (cooldown : cooldown, key : any, tag : any?) -> (),
	destroy : (cooldown : cooldown) -> ()
}

local function check(cooldown : cooldown, key : any, tag : any, duration : number) : boolean
	if cooldown.cooldowns[key] == nil then
		cooldown.cooldowns[key] = {
			[tag] = os.clock()
		}
		
		return true
	end
	
	if cooldown.cooldowns[key][tag] == nil then
		cooldown.cooldowns[key][tag] = os.clock()
		return true
	end
	
	if (os.clock() - cooldown.cooldowns[key][tag]) >= duration then
		cooldown.cooldowns[key][tag] = os.clock()
		return true
	end
	
	return false
end

local function remove(cooldown : cooldown, key : any, tag : any?)
	if tag == nil then
		cooldown.cooldowns[key] = nil
	else
		cooldown.cooldowns[key][tag] = nil
	end
end

local function destroy(cooldown : cooldown)
	cooldown.cooldowns = nil
end

local function new() : cooldown
	return {
		cooldowns = { },
		
		check = check,
		remove = remove,
		destroy = destroy
	}
end

return {
	new = new,
	check = check,
	remove = remove,
	destroy = destroy,
}