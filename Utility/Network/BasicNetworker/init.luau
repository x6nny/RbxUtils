--!strict
local event = require(script.Event)
local funct = require(script.Function)

export type event<T...> = event.event<T...>
export type funct<T..., K...> = funct.funct<T..., K...>

return {
	Event = event,
	Unreliable = require(script.Unreliable),
	Function = funct,
}