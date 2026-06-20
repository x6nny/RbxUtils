--!strict
return function(number : number) : string
	if number == nil then
		return ''
	end
	local days = math.floor(number / 86400)
	local hours = math.floor((number % 86400) / 3600)
	local minutes = math.floor((number % 3600) / 60)
	local secs = number % 60

	local formatted
	if days > 0 then
		formatted = string.format("%dd %dh %dm %ds", days, hours, minutes, secs)
	elseif hours > 0 then
		formatted = string.format("%dh %dm %ds", hours, minutes, secs)
	elseif minutes > 0 then
		formatted = string.format("%dm %ds", minutes, secs)
	else
		formatted = string.format("%ds", secs)
	end
	
	return formatted
end