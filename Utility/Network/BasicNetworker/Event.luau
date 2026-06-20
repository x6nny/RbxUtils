--!strict
local RunService = game:GetService('RunService')

--> types
export type event<T...> = {
	connections : {(T...) -> ()},
	event : string,
	
	_fire : (T...) -> (),
	OnServerEvent : (event<T...>, funct : (player : Player, T...) -> ()) -> () -> (),
	OnClientEvent : (event<T...>, funct : (T...) -> ()) -> () -> (),
	FireServer : (event<T...>, T...) -> (),
	FireClient : (event<T...>, player : Player, T...) -> (),
	FireAllClients : (event<T...>, T...) -> (),
}

type batch = {
	[string] : {
		[number] : {any}
	}
}

type server_batch = {
	[Player] : batch,
	['all'] : batch
}

--> assets
local Remotes = script.Parent.Remotes
local Remote = Remotes.Event

--> context
local context = if RunService:IsServer() then 'Server' else 'Client'

--> tracked
local tracked = {} :: {[string] : {}}
local batches = {} :: server_batch | batch

if context == 'Server' then
	Remote.OnServerEvent:Connect(function(player : Player, batched : batch)
		for event, batch in batched do
			local track = tracked[event]
			
			if track then
				for _, v in track :: any do
					for _, c in batch do
						v:_fire(player, unpack(c))
					end
				end
			end
		end
	end)
else
	Remote.OnClientEvent:Connect(function(batched : batch)
		for event, batch in batched do
			local track = tracked[event]

			if track then
				for _, v in track :: any do
					for _, c in batch do
						v:_fire(unpack(c))
					end
				end
			end
		end
	end)
end

RunService.Heartbeat:Connect(function()
	if context == 'Client' then
		local totalBatch = 0
		
		for i, v in batches :: any do
			totalBatch += 1
		end
		
		if totalBatch > 0 then
			local batch = batches
			batches = {}
			Remote:FireServer(batch)
		end
	elseif context == 'Server' then
		local totalBatch = 0
		
		for i, v in batches :: any do
			totalBatch += 1
		end
		
		if totalBatch > 0 then
			for player, batch in batches :: any do
				if typeof(player) == 'Instance' then
					Remote:FireClient(player, batch)
					batches[player :: any] = nil :: any
				elseif typeof(player) == 'string' and player:lower() == 'all' then
					Remote:FireAllClients(batch)
					batches[player :: any] = nil :: any
				end
			end
		end
	end
end)

--> class
local Event = {}
Event.__index = Event

--> constructor
function Event.new<T...>(event : string) : event<T...>
	local self = setmetatable({}, Event) :: any
	
	self.event = event
	self.connections = {}
	
	if tracked[event] == nil then
		tracked[event] = {}
	end
	
	table.insert(tracked[event], self)
	
	return self
end

--> methods
function Event:_fire<T...>(...: T...)
	for _, v in self.connections do
		task.spawn(v, ...)
	end
end

function Event:FireServer<T...>(...: T...)
	if context == 'Client' then
		if batches[self.event :: any] == nil then
			batches[self.event :: any] = {}
		end
		table.insert(batches[self.event :: any] :: any, table.pack(...))
	end
end

function Event:FireClient<T...>(player : Player, ...: T...)
	if context == 'Server' then
		if batches[player :: any] == nil then
			batches[player :: any] = {}
		end
		if batches[player :: any][self.event :: any] == nil then
			batches[player :: any][self.event :: any] = {}
		end
		
		table.insert(batches[player :: any][self.event :: any], table.pack(...))
	end
end

function Event:FireAllClients<T...>(...: T...)
	if context == 'Server' then
		if batches['all'] == nil then
			batches['all'] = {}
		end
		if batches['all'][self.event :: any] == nil then
			batches['all'][self.event :: any] = {}
		end

		table.insert(batches['all'][self.event :: any], table.pack(...))
	end
end

function Event:OnServerEvent<T...>(funct : (player : Player, T...) -> ())
	if context == 'Server' then
		table.insert(self.connections, funct)

		return function()
			local index = table.find(self.connections, funct)
			if index then
				table.remove(self.connections, index)
			end
		end
	end
	
	return nil :: any
end

function Event:OnClientEvent<T...>(funct : (T...) -> ())
	if context == 'Client' then
		table.insert(self.connections, funct)

		return function()
			local index = table.find(self.connections, funct)
			if index then
				table.remove(self.connections, index)
			end
		end
	end

	return nil :: any
end

--> return
return Event