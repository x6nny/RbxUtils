--!strict
local TimeFrom = 1764274732 -- print(DateTime.now().UnixTimestamp) --> in case of needing to reset global time.
local TimeFormatter = require(script.Parent.Parent.Formatters.TimeFormat)

return function(seconds: number)
	local current = DateTime.now().UnixTimestamp
	local difference = TimeFrom - current

	local remainder = difference % seconds
	local formatted = TimeFormatter(remainder)

	return {
		remainder = remainder,
		formatted = formatted,
		iterations = math.abs(math.floor(difference / seconds)) --> good for rng as this is consistent based off elapsed seconds.
	}
end