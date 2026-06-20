local utility = script.Parent.Parent

local UIUtil = utility.Gui
local ButtonAnimator = require(UIUtil.ButtonAnimator)

local Reactive = utility.Reactive
local state = require(Reactive.EzState)

type animConfig = {
	HoverMultiplier: number,
	MouseDownMultiplier: number,
	
	shine: boolean?,
	shineTransparency: number?,
	shineColor: Color3?,
	shineTime: number?,
	shineDelay: number?,
}

local ButtonManager = {}
ButtonManager.__index = ButtonManager

function ButtonManager.new(button: Frame, onActivated: () -> (), active: boolean?, animConfig: animConfig?): button
	local self = setmetatable({}, ButtonManager)
	
	self.states = {
		active = if active then state.new(active) else state.new(true)
	}
	
	self.frame = button
	self.button = Instance.new('TextButton')
	
	self.button.BackgroundTransparency = 1
	self.button.Size = UDim2.fromScale(1, 1)
	self.button.Text = ''
	self.button.Parent = self.frame
	
	ButtonAnimator.new({
		object = self.frame,
		defaultSize = self.frame.Size,
		
		hoverMultiplier = if animConfig then animConfig.HoverMultiplier else 1.05,
		mouseDownMultiplier = if animConfig then animConfig.MouseDownMultiplier else 0.95,
		
		shine = if animConfig then animConfig.shine else false,
		shineColor = if animConfig then animConfig.shineColor else Color3.new(1, 1, 1),
		shineTransparency = if animConfig then animConfig.shineTransparency else 0.5,
		shineTime = if animConfig then animConfig.shineTime else 1,
		shineDelay = if animConfig then animConfig.shineDelay else 2,
	})
	
	local function updateActive(value: boolean)
		self.button.Interactable = value
		self.frame.Interactable = value
	end
	
	state.subscribe(self.states.active, updateActive)
	updateActive(state.peek(self.states.active))
	
	self.button.Activated:Connect(onActivated)
	
	return self
end

function ButtonManager:setActive(active: boolean)
	state.change(self.states.active, active)
end

export type button = typeof(ButtonManager.new(...))

return ButtonManager