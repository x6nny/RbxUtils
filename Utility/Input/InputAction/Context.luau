local types = require(script.Parent.Types)
local Inputs = script.Parent.Inputs

local Action = require(script.Parent.Action)

local context = {}
context.__index = context

function context.new(name: string, options: types.ContextOptions?): types.ContextClass
	assert(Inputs:FindFirstChild(name) == nil, 'InputContext already exists!')
	
	local self = setmetatable({}, context)
	
	self.instance = Instance.new('InputContext')
	self.actions = {}
	
	self.instance.Name = name
	self.instance.Parent = Inputs
	
	if options then
		self.instance.Priority = if options.Priority then options.Priority else 1_000
		self.instance.Sink = if options.Sink ~= nil then options.Sink else false
	end
	
	return self
end

function context:Enable(enabled: boolean)
	self.instance.Enabled = enabled
end

function context:Action(name: string, options: types.ActionOptions): types.ActionClass
	assert(self.actions[name] == nil, 'InputAction already exists!')
	
	local action = Action.new(name, options)
	action.instance.Parent = self.instance
	
	action.instance.Destroying:Once(function()
		self.actions[name] = nil
	end)
	
	self.actions[name] = action
	
	return action
end

return context