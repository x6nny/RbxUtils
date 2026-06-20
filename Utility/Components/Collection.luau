--!strict
local CollectionService = game:GetService('CollectionService')

--> types
type struct<T> = {
	GetTagged : (struct<T>) -> {T},
	tagAdded : (struct<T>, fn : (instance : T) -> (), ancestors : {Instance?}?) -> (),
	tagRemoved : (struct<T>, fn : (instance : T) -> (), ancestors : {Instance?}?) -> (),
	AddTag : (struct<T>, instance : T) -> (),
	RemoveTag : (struct<T>, instance : T) -> (),
	HasTag : (struct<T>, instance : T) -> boolean,
}

export type collection<T> = struct<T>

--> Class
local collection = {}
collection.__index = collection

--> private
local function isAncestor(descendant : Instance, ancestors : {Instance}?) : boolean
	if ancestors == nil then return true end

	local _isAncestor = false

	for _, v in pairs(ancestors) do
		if v:IsAncestorOf(descendant) then
			_isAncestor = true
			break
		end
	end

	return _isAncestor
end

--> methods
function collection:GetTagged<T>() : {T}
	return CollectionService:GetTagged(self.tag)
end

function collection:tagAdded<T>(fn : (instance : T) -> (), ancestors : {Instance?}?)
	table.insert(self.tagAddedListeners :: {any}, fn)
	
	for _, v : Instance in pairs(self:GetTagged()) do
		if isAncestor(v :: any, ancestors :: any) == false then continue end
		task.spawn(fn, v :: any)
	end
	
	if self.tagAddedConnection == nil then
		self.tagAddedConnection = CollectionService:GetInstanceAddedSignal(self.tag):Connect(function(v : Instance)
			if isAncestor(v, ancestors :: any) == false then return end
			task.spawn(fn, v)
		end)
	end
	
	return function()
		local index = table.find(self.tagAddedListeners :: {any}, fn)
		if index == nil then return end
		table.remove(self.tagAddedListeners, index)
		
		if #self.tagAddedListeners == 0 then
			self.tagAddedConnection:Disconnect()
			self.tagAddedConnection = nil :: any
		end
	end
end

function collection:tagRemoved<T>(fn : (instance : T) -> (), ancestors : {Instance?}?) : () -> ()
	table.insert(self.tagAddedListeners, fn)

	if self.tagRemovedConnection == nil then
		self.tagRemovedConnection = CollectionService:GetInstanceRemovedSignal(self.tag):Connect(function(v : Instance)
			if isAncestor(v, ancestors :: any) == false then return end
			task.spawn(fn, v)
		end)
	end

	return function()
		local index = table.find(self.tagRemovedListeners :: {any}, fn)
		if index == nil then return end
		table.remove(self.tagRemovedListeners, index)

		if #self.tagRemovedListeners == 0 then
			self.tagRemovedConnection:Disconnect()
			self.tagRemovedConnection = nil :: any
		end
	end
end

function collection:AddTag<T>(instance : T | {T})
	if typeof(instance) ~= 'table' then
		instance:AddTag(self.tag)
	else
		for _, v in pairs(instance) do
			v:AddTag(self.tag)
		end
	end
end

function collection:RemoveTag<T>(instance : T | {T})
	if typeof(instance) ~= 'table' then
		instance:RemoveTag(self.tag)
	else
		for _, v in pairs(instance) do
			v:RemoveTag(self.tag)
		end
	end
end

function collection:HasTag(instance : Instance | {Instance}) : boolean
	if typeof(instance) ~= 'table' then
		return CollectionService:HasTag(instance, self.tag)
	else
		for _, v in pairs(instance) do
			if v:HasTag(self.tag) == false then
				return false
			end
		end
		return true
	end
end

--> return
return function<T>(tag : string) : struct<T>
	return setmetatable({
		tag = tag,
		
		tagAddedListeners = {},
		tagRemovedListeners = {}
	}, collection) :: any
end