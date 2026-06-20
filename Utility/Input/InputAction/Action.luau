local Types = require(script.Parent.Types)
local Binding = require(script.Parent.Binding)

local Action = {}
Action.__index = Action

function Action.new(name: string, options: Types.ActionOptions)
	local self = setmetatable({}, Action)
	
	self.instance = Instance.new('InputAction')
	self.binds = {}
	
	self.listeners = {}
	
	self.instance.Name = name
	self.instance.Type = options.Type
	self.instance.Enabled = if options.Enabled ~= nil then options.Enabled else true
	
	self.instance.StateChanged:Connect(function(state)
		for i, v in self.listeners do
			if v.state == state then
				task.spawn(v.callback, state)
			end
		end
	end)
	
	return self
end

function Action:Enable(enabled: boolean)
	self.instance.Enabled = enabled
end

function Action:Bind(name: string, options: Types.BindOptions): Types.BindClass
	assert(self.binds[name] == nil, 'InputBinding already exists!')
	
	local bind: Types.BindClass = Binding.new(name, options)
	bind.instance.Parent = self.instance
	
	bind.instance.Destroying:Once(function()
		self.binds[name] = nil
	end)
	
	self.binds[name] = bind
	
	return bind
end

function Action:Unbind(name: string)
	assert(self.binds[name] ~= nil, 'InputBinding does not exist!')
	
	self.binds[name]:Destroy()
	self.binds[name] = nil
end

function Action:Listen(state: any, callback: (state: any) -> ()): () -> ()
	local data = {
		state = state,
		callback = callback
	}
	
	table.insert(self.listeners, data)
	
	return function()
		local index = table.find(self.listeners, data)
		if index then
			table.remove(self.listeners, index)
		end
	end
end

function Action:Destroy()
	for i, v in self.binds do
		v:Destroy()
	end
	
	self.binds = {}
	self.instance:Destroy()
end

return Action