local Types = require(script.Parent.Types)

local Binding = {}
Binding.__index = Binding

function Binding.new(name: string, options: Types.BindOptions)
	local self = setmetatable({}, Binding)
	
	self.instance = Instance.new('InputBinding')
	
	self.instance.Name = name
	
	if options.KeyCode then
		self.instance.KeyCode = options.KeyCode
	end
	
	if options.PrimaryModifier then
		self.instance.PrimaryModifier = options.PrimaryModifier
	end
	
	if options.SecondaryModifier then
		self.instance.SecondaryModifier = options.SecondaryModifier
	end
	
	if options.UIButton then
		self.instance.UIButton = options.UIButton
	end
	
	return self
end

function Binding:Destroy()
	self.instance:Destroy()
	self.instance = nil
end

return Binding