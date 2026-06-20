local runtimes = require(script.Parent.Parent.Services.Runtimes)
local EzSignal = require(script.Parent.Parent.Reactive.EzSignal)

local runTimeConnect = runtimes.Connect
local RUNTIME_EVENT = 'Heartbeat'

local timer = { }

export type timer = {
	tick : EzSignal.Signal<number>,
	ended : EzSignal.Signal<nil>,
	t : number,
	g : number,
	connection : () -> ()?,
}

function timer.new(start_time : number, end_time : number)
	return {
		tick = EzSignal.new() :: EzSignal.Signal<number>,
		ended = EzSignal.new() :: EzSignal.Signal<nil>,
		t = start_time,
		g = end_time,
		connection = nil
	}
end

function timer.start(_timer : timer)
	if _timer.connection ~= nil then
		return
	end
	local tic = os.clock()
	
	local start = _timer.t
	local goal = _timer.g
	
	local increment = 1
	
	if start > goal then
		increment = -1
	elseif start < goal then
		increment = 1
	end
	
	_timer.connection = runTimeConnect(RUNTIME_EVENT, function()
		if os.clock() - tic >= 1 then
			tic = os.clock()
			_timer.t += increment
			_timer.tick:fire(_timer.t)
			
			if _timer.t >= _timer.g then
				if _timer.connection ~= nil then
					_timer.connection()
					_timer.connection = nil
				end
				_timer.ended:fire()
			end
		end
	end)
end

function timer.stop(_timer : timer)
	if _timer.connection ~= nil then
		_timer.connection()
		_timer.connection = nil
	end
end

return timer