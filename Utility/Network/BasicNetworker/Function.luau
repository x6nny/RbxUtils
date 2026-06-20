--!strict
local RunService = game:GetService('RunService')

--> types
export type funct<T..., K...> = {
	event : string,
	
	InvokeServer : (funct<T..., K...>, T...) -> K...,
	OnServerInvoke : (funct<T..., K...>, func : (player : Player, T...) -> K...) -> ()
}

--> assets
local Remotes = script.Parent.Remotes
local Remote = Remotes.Function

--> context
local context = if RunService:IsServer() then 'Server' else 'Client'

--> tracked
local tracked = {} :: {[string] : (player : Player, ...any) -> ...any}

if context == 'Server' then
	Remote.OnServerInvoke = function(player : Player, key : string, ...)
		if tracked[key] then
			return tracked[key](player, ...)
		end
		return nil
	end
end

local Funct = {}
Funct.__index = Funct

function Funct.new<T..., K...>(event : string) : funct<T..., K...>
	local self = setmetatable({}, Funct) :: any
	
	self.event = event
	
	return self
end

function Funct:InvokeServer<T..., K...>(...: T...) : K...
	if context == 'Client' then
		return Remote:InvokeServer(self.event, ...)
	end
end

function Funct:OnServerInvoke<T..., K...>(func : (player : Player, T...) -> K...)
	if context == 'Server' then
		tracked[self.event] = func
	end
end

return Funct