local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local nh_context = require(script.Parent.nh_context)
local nh_serde = require(script.Parent.nh_serde)

local serialize_noid, deserialize_noid = nh_serde.serialize_noid, nh_serde.deserialize_noid

local run_context = nh_context.run_context
local packets = nh_context.packets

local unreliables = 0

return {
    event = function<S>(schema: S)
        packets.reliable_count += 1
        local id_count = packets.reliable_count

        local connections = {}
        local struct = {
            _connections = connections,
            _schema = schema,
            _identity = "event",

            Fire = function(data: S, player: Player?)
                if run_context == "Server" and player then
                    table.insert(nh_context.player_queue[player], {id = id_count, schema = schema, data = data} :: any)
                else
                    table.insert(nh_context.player_queue[Players.LocalPlayer], {id = id_count, schema = schema, data = data} :: any)
                end
            end,

            FireAll = function(data: S)
                assert(run_context == "Server", "FireAll can only be called from the server.")
                local payload = {id = id_count, schema = schema, data = data} :: any

                for _, player in Players:GetPlayers() do
                    table.insert(nh_context.player_queue[player], payload)
                end
            end,

            FireList = function(data: S, Players: {Player})
                assert(run_context == "Server", "FireList can only be called from the server.")
                local payload = {id = id_count, schema = schema, data = data} :: any

                for _, player in Players do
                    table.insert(nh_context.player_queue[player], payload)
                end
            end,

            Connect = function(callback: (data: S, Player: Player?) -> ())
                table.insert(connections, callback)
            end
        }

        nh_context.packets.reliable[id_count] = struct
        return struct
    end,

    funct = function<S, I>(schema: S, incoming: I)
        packets.reliable_count += 1
        local id_count = packets.reliable_count

        local connections = {}
        local invokes = {}

        local struct = {
            _connections = connections,
            _schema = schema,
            _identity = "funct",
            _incoming = incoming,
            _invokes = invokes,

            Invoke = function(data: S)
                assert(run_context == "Client", "Invoke only works on client")
                table.insert(nh_context.player_queue[Players.LocalPlayer], {id = id_count, schema = schema, data = data} :: any)

                local thread = coroutine.running()
                table.insert(invokes, thread)
                return coroutine.yield()
            end,

			Callback = function(callback: (schema: S, player: Player?) -> I)
                assert(run_context == "Server", "Callback only works on server")
                table.insert(connections, callback)
            end
        }

        nh_context.packets.reliable[id_count] = struct
        return struct
    end,


    unreliable = function <S>(schema: S)
        local connections = {}

        local inst 
        unreliables += 1

        if run_context == "Server" then
            inst = Instance.new("UnreliableRemoteEvent")
            inst.Name = `nh_unreliable_{unreliables}`
            inst.Parent = ReplicatedStorage:FindFirstChild("nh_container")

            inst.OnServerEvent:Connect(function(player: Player, buf: buffer)
                if typeof(buf) ~= "buffer" then return end
                deserialize_noid(schema, connections, buf, player)
            end)

        elseif run_context == "Client" then
            inst = ReplicatedStorage:FindFirstChild("nh_container"):FindFirstChild(`nh_unreliable_{unreliables}`)

            inst.OnClientEvent:Connect(function(player: Player, buf: buffer)
                deserialize_noid(schema, connections, buf, player)
            end)
        end

        local struct = {
            _connections = connections,

            Fire = function(data: S, player: Player?)
                if run_context == "Server" and player then
                    inst:FireClient(player, serialize_noid(schema, data))
                else
                    inst:FireServer(serialize_noid(schema, data))
                end
            end,

            FireAll = function(data: S)
                assert(run_context == "Server", "FireAll can only be called from the server.")

                for _, player in Players:GetPlayers() do
                    inst:FireClient(player, serialize_noid(schema, data))
                end
            end,

            FireList = function(data: S, Players: {Player})
                assert(run_context == "Server", "FireList can only be called from the server.")

                for _, player in Players do
                    inst:FireClient(player, serialize_noid(schema, data))
                end
            end,

            Connect = function(callback: (data: S, Player: Player?) -> ())
                table.insert(connections, callback)
            end
        }
        return struct
    end,
}