local TweenService = game:GetService('TweenService')
local signal = require(script.Parent.Parent.Reactive.EzSignal)

local SequenceTween = {}
SequenceTween.__index = SequenceTween

-- Internal Helper: Gets a clean Color3 from a sequence without modifying the sequence
local function sampleColor(sequence: ColorSequence, time: number): Color3
	local kp = sequence.Keypoints
	if time <= 0 then return kp[1].Value end
	if time >= 1 then return kp[#kp].Value end
	for i = 1, #kp - 1 do
		local curr, nxt = kp[i], kp[i+1]
		if time >= curr.Time and time <= nxt.Time then
			local alpha = (time - curr.Time) / (nxt.Time - curr.Time)
			return curr.Value:Lerp(nxt.Value, alpha)
		end
	end
	return kp[#kp].Value
end

function SequenceTween.new(startState: ColorSequence, endState: ColorSequence, info: TweenInfo)
	local self = setmetatable({}, SequenceTween)

	self._start = startState
	self._end = endState
	self._info = info

	-- Pre-calculate time stamps ONCE to prevent "jiggling" keypoints
	local ts = {0, 1}
	local seen = {[0]=true, [1]=true}
	for _, k in ipairs(startState.Keypoints) do 
		local t = math.round(k.Time*1000)/1000
		if not seen[t] then table.insert(ts, k.Time) seen[t]=true end 
	end
	for _, k in pairs(endState.Keypoints) do 
		local t = math.round(k.Time*1000)/1000
		if not seen[t] then table.insert(ts, k.Time) seen[t]=true end 
	end
	table.sort(ts)
	if #ts > 20 then -- Roblox Limit
		ts = {} for i=0,19 do table.insert(ts, i/19) end
	end
	self._times = ts

	self.Updated = signal.new()
	self._proxy = Instance.new("NumberValue")

	self._connection = self._proxy.Changed:Connect(function(alpha)
		-- BOUNCER: If alpha is 0 or 1, return the RAW original sequences
		-- This scrubs away any rounding errors immediately.
		if alpha <= 0 then 
			signal.fire(self.Updated, self._start) 
			return 
		end
		if alpha >= 1 then 
			signal.fire(self.Updated, self._end) 
			return 
		end

		local kps = {}
		for _, t in ipairs(self._times) do
			local cA = sampleColor(self._start, t)
			local cB = sampleColor(self._end, t)
			table.insert(kps, ColorSequenceKeypoint.new(t,cA:Lerp(cB, alpha)))
		end
		signal.fire(self.Updated, ColorSequence.new(kps))
	end)

	self._tween = TweenService:Create(self._proxy, self._info, {Value = 1})
	self.Completed = self._tween.Completed

	return self
end

function SequenceTween:Play()
	self._proxy.Value = 0
	self._tween:Play()
end

function SequenceTween:Reverse()
	self._tween:Cancel()
	local currentAlpha = self._proxy.Value
	self._tween = TweenService:Create(self._proxy, self._info, {Value = 0})
	self._tween:Play()
end

function SequenceTween:Destroy()
	self._tween:Cancel()
	self._connection:Disconnect()
	self._proxy:Destroy()
	signal.cleanUp(self.Updated)
end

return SequenceTween