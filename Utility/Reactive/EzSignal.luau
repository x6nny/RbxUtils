type listener<A...> = (A...) -> ()
type cleanup = () -> ()?

type signal<A...> = {
	connections: {
		{
			listener: listener<A...>,
			cleanup: cleanup,
		}
	},
}

type class<A...> = {
	store: (signal: signal<A...>, name: string, overwrite: boolean?) -> (),
	unstore: (signal: signal<A...>) -> (),
	fire: (signal: signal<A...>, A...) -> (),
	connect: (signal: signal<A...>, listener: listener<A...>, cleanup: cleanup) -> () -> (),
	once: (signal: signal<A...>, listener: listener<A...>, cleanup: cleanup) -> () -> (),
	wait: (signal: signal<A...>) -> A...,
	waitUntil: (signal: signal<A...>, timeout: number) -> A...,
	cleanUp: (signal: signal<A...>) -> (),
}

export type Signal<A...> = signal<A...> & class<A...>

local stored = { }

local function store<A...>(signal: signal<A...>, name: string, overwrite: boolean?)
	if stored[name] ~= nil and (overwrite == nil or overwrite == false) then
		return
	end

	stored[name] = signal
end

local function unstore<A...>(signal: signal<A...>)
	local foundName: string?
	for name, sig in pairs(stored) do
		if sig == signal then
			foundName = name
			break
		end
	end

	if foundName then
		stored[foundName] = nil
	end
end

local function getStored<A...>(name: string): Signal<A...>
	return stored[name] :: any
end

local function connect<A...>(signal: signal<A...>, listener: listener<A...>, cleanup: cleanup): () -> ()
	local connection = {
		listener = listener,
		cleanup = cleanup
	}

	table.insert(signal.connections, connection)

	return function()
		local index = table.find(signal.connections, connection)
		if index then
			table.remove(signal.connections, index)
		end

		if cleanup then
			task.spawn(cleanup)
		end
	end
end

local function once<A...>(signal: signal<A...>, listener: listener<A...>, cleanup: cleanup): () -> ()
	local connection: () -> ()?
	connection = connect(signal, function(...)
		task.spawn(listener, ...)

		if connection then
			connection()
			connection = nil
		end
	end, cleanup)

	return function()
		if connection then
			connection()
			connection = nil
		end
	end
end

local function fire<A...>(signal: signal<A...>, ... : A...)
	for i = 1, #signal.connections do
		local connection = signal.connections[i]
		task.spawn(connection.listener, ...)
	end
end

local function wait<A...>(signal: signal<A...>): A...
	local running = coroutine.running()

	local connection
	connection = once(signal, function(...)
		coroutine.resume(running, ...)
	end, function()
		coroutine.resume(running)
	end)

	return coroutine.yield()
end

local function waitUntil<A...>(signal: signal<A...>, timeout : number): A...
	local running = coroutine.running()

	local connection: () -> ()?
	local thread: thread?
	connection = once(signal, function(...)
		coroutine.resume(running, ...)
	end, function()
		if thread then
			task.cancel(thread)
		end
		coroutine.resume(running)
	end)

	thread = task.delay(timeout, function()
		thread = nil
		if connection ~= nil then
			connection()
			connection = nil
		end
	end)

	return coroutine.yield()
end

local function cleanUp<A...>(signal: signal<A...>)
	for i, v in signal.connections do
		if v.cleanup then
			task.spawn(v.cleanup)
		end
	end

	table.clear(signal.connections)
end

local function new<A...>(): Signal<A...>
	return {
		connections = { },

		store = store,
		unstore = unstore,
		fire = fire,
		connect = connect,
		once = once,
		wait = wait,
		waitUntil = waitUntil,
		cleanUp = cleanUp,
	} :: any
end

local function wrap<A...>(signal: RBXScriptSignal): signal<A...>
	local self = new()
	
	local conn = signal:Connect(function(...)
		self:fire(...)
	end)
	
	local function cleanup()
		conn:Disconnect()
		conn = nil
	end
	
	table.insert(self.connections, {
		cleanup = cleanup,
		listener = function()
		end,
	})
	
	return self
end

return {
	new = new,
	connect = connect,
	fire = fire,
	once = once,
	wait = wait,
	waitUntil = waitUntil,
	cleanUp = cleanUp,
	store = store,
	unstore = unstore,
	getStored = getStored,
	wrap = wrap,
}