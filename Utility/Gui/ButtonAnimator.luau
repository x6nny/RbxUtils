--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')

local state = require(script.Parent.Parent.Reactive.EzState)
local spr = require(script.Parent.Parent.Physics.Spring)
local tbl = require(script.Parent.Parent.Table.tbl)
local shine = require(script.Parent.Shine)

export type config = {
	mouseDownMultiplier : number?,
	hoverMultiplier : number?,
	
	shine: boolean?,
	shineTransparency: number?,
	shineColor: Color3?,
	shineTime: number?,
	shineDelay: number?,
	
	object : any,
	
	damping : number?,
	velocity : number?,
}

export type self = config & {
	states : {
		hovered : state.state<boolean>,
		mouseDown : state.state<boolean>,
	},

	_shine: typeof(shine.new(...)),

	listeners : {() -> ()},

	_init : (config) -> (),
	Destroy : (config) -> (),
}

local DEFAULT_SETTINGS = {
	mouseDownMultiplier = 0.95,
	hoverMultiplier = 1.05,
	
	shine = false,
	shineTransparency = 0.5,
	shineColor = Color3.new(1, 1, 1),
	shineTime = 1,
	shineDelay = 2,
	
	damping = 0.7,
	velocity = 8
}

local animator = {}
animator.__index = animator

local global_mouse_states = {}

function animator.new(config : config) : self
	local self = setmetatable(config, animator) :: self
	
	config = tbl.reconcile(config :: any, DEFAULT_SETTINGS) :: any
	
	self.states = {
		hovered = state.new(false) :: state.state<boolean>,
		mouseDown = state.new(false) :: state.state<boolean>
	}
	self.listeners = {}
	
	if config.shine then
		self._shine = shine.new(config.object, config.shineTransparency, config.shineColor, TweenInfo.new(config.shineTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, config.shineDelay))
		self._shine:Stop()
	end
	
	table.insert(global_mouse_states, self.states.mouseDown)
	
	self:_init()
	
	return self
end

function animator:_init()
	local hoverMultiplier = self.hoverMultiplier :: number
	local mouseDownMultiplier = self.mouseDownMultiplier :: number
	
	local scale = Instance.new('UIScale')
	scale.Scale = 1
	scale.Parent = self.object
	
	self.listeners[1] = state.subscribe(self.states.hovered :: state.state<boolean>, function(value : boolean)
		local default = self.defaultSize
		local targetScale = 1
		
		if value == true and state.peek(self.states.mouseDown :: state.state<boolean>) == false then
			targetScale = 1 * hoverMultiplier
		elseif value == true and state.peek(self.states.mouseDown :: state.state<boolean>) == true then
			targetScale = 1 * mouseDownMultiplier
		elseif value == false then
			if state.peek(self.states.mouseDown :: state.state<boolean>) == true then
				targetScale = 1 * mouseDownMultiplier
			end
		end
		
		if value and self._shine then
			self._shine:Play()
		elseif not value and self._shine then
			self._shine:Stop()
		end
		
		spr.stop(scale, 'Scale')
		spr.target(scale, self.damping, self.velocity, {
			Scale = targetScale
		})
	end)
	
	self.listeners[2] = state.subscribe(self.states.mouseDown :: state.state<boolean>, function(value : boolean)
		local default = self.defaultSize
		local targetScale = 1

		if value == true then
			targetScale = 1 * mouseDownMultiplier
		elseif value == false then
			if state.peek(self.states.hovered) == true then
				targetScale = 1 * hoverMultiplier
			end
		end

		spr.stop(scale, 'Scale')
		spr.target(scale, self.damping, self.velocity, {
			Scale = targetScale
		})
	end)
	
	local object = self.object :: Frame
	local states = self.states
	local hovered = states.hovered
	local mouseDown = states.mouseDown
	
	local button = object
	if object:IsA('TextButton') == false and object:IsA('ImageButton') == false then
		button = object:FindFirstChildWhichIsA('TextButton', true) :: TextButton or object:FindFirstChildWhichIsA('ImageButton', true) :: ImageButton
	end
	
	object.MouseEnter:Connect(function()
		state.change(hovered :: state.state<boolean>, true)
	end)
	
	object.MouseLeave:Connect(function()
		state.change(hovered :: state.state<boolean>, false)
	end)
	
	if button then
		(button :: ImageButton | TextButton).MouseButton1Down:Connect(function()
			state.change(mouseDown :: state.state<boolean>, true)
		end)
	end
end

function animator:Destroy()
	for _, v in self.listeners :: any do
		v()
	end
	
	local index = table.find(global_mouse_states, self.states.mouseDown)
	if index then
		table.remove(global_mouse_states, index)
	end
end

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		for _, v in global_mouse_states :: any do
			state.change(v, false)
		end
	end
end)

return animator