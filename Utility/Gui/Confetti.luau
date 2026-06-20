local tweenService = game:GetService('TweenService')
local players = game:GetService('Players')

local runtimes = require(script.Parent.Parent.Services.Runtimes)

local player = players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui') :: PlayerGui

local camera = workspace.CurrentCamera

local holder = Instance.new('ScreenGui')
holder.Name = '_CONFETTI'
holder.IgnoreGuiInset = true
holder.ResetOnSpawn = false
holder.DisplayOrder = 999
holder.Parent = playerGui

local baseColors = {
	Color3.fromRGB(255, 75, 75),
	Color3.fromRGB(75, 255, 75),
	Color3.fromRGB(75, 75, 255),
	Color3.fromRGB(255, 255, 75),
	Color3.fromRGB(255, 75, 255),
	Color3.fromRGB(75, 255, 255)
}

local function setDisplayOrder(displayOrder: number)
	holder.DisplayOrder = tonumber(displayOrder) or 999
end

local function createParticleFrame()
	local frame = Instance.new('Frame')
	local corner = Instance.new('UICorner')
	local aspect = Instance.new('UIAspectRatioConstraint')
	
	local viewportSize = camera.ViewportSize
	
	local size = math.random(25, 38)
	local color = baseColors[math.random(#baseColors)]
	
	local scaledX = (size / viewportSize.X)
	local scaledY = (size / viewportSize.Y)
	
	frame.BorderSizePixel = 0
	frame.Rotation = math.random(360)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.fromScale(scaledX, scaledY)
	frame.BackgroundColor3 = color
	frame.Name = '_PARTICLE'
	
	aspect.Name = 'aspect'
	aspect.AspectRatio = math.round(scaledX / scaledY)
	aspect.AspectType = Enum.AspectType.ScaleWithParentSize
	aspect.DominantAxis = Enum.DominantAxis.Width
	aspect.Parent = frame
	
	corner.Name = 'corner'
	corner.CornerRadius = UDim.new(math.random(), 0)
	corner.Parent = frame
	
	return frame
end

local function emit(amount: number, position: UDim2?)
	local particles = {}
	
	for i = 1, amount do
		local confetti = createParticleFrame()
		
		confetti.Position = if position then position else UDim2.fromScale(math.random(0, 100)/100, math.random(-25, 125)/100)
		confetti.Parent = holder
		
		local velocityX, velocityY, gravity = math.random(-300, 300), math.random(-350, -200), 75
		local rotationSpeed = math.random(-300, 300)
		local startTime = os.clock()
		
		local connection
		connection = runtimes.Connect('RenderStepped', function(deltaTime: number)
			if not confetti.Parent then
				if connection then
					connection()
					connection = nil
				end
				return
			end

			local elapsedTime = os.clock() - startTime
			local newX = confetti.Position.X.Scale + (velocityX * deltaTime / 400)
			local newY = confetti.Position.Y.Scale + (velocityY * deltaTime / 400) + (0.5 * gravity * elapsedTime ^ 2 / 3000)
			confetti.Position = UDim2.new(newX, 0, math.min(newY, 1.3), 0)
			confetti.Rotation += rotationSpeed * deltaTime + math.sin(elapsedTime * 2) * 0.5
			
			if newY > 1.3 then
				confetti:Destroy()
				if connection then
					connection()
					connection = nil
				end
				table.remove(particles, i)
			end
		end)
	end
end

return {
	setDisplayOrder = setDisplayOrder,
	emit = emit,
}