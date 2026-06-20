--!native
local nh_context = require(script.Parent.nh_context)
local nh_settings = require(script.Parent.nh_settings)
local nh_types = require(script.Parent.nh_types)

local Serializer = {}
Serializer.serialize_noid = nh_context.dependencies.BufferHandler.Serializer.serialize

local settings = nh_settings
local id_option = settings.id_option
local id_size = settings.id_size

local packets = nh_context.packets
local run_context = nh_context.run_context

local function get_size(payload: nh_types.Payload)
    local size = 0

    for i = 1, #payload do
        local item = payload[i]
        size += id_size :: any

        local t_size = item.schema.size

        if typeof(t_size) == "function" then
            size += t_size(item.data)
        else
            size += t_size
        end

    end

    return size
end

function Serializer.serialize(payload: nh_types.Payload)
    local size = get_size(payload)
    local buf = buffer.create(size)
    local pos = 0

    for i = 1, #payload do
        local item = payload[i]
        pos = id_option.write(buf, pos, item.id)
        pos = item.schema.write(buf, pos, item.data)
    end

    return buf
end

function Serializer.deserialize(buf: buffer, player: Player?)
    local cursor = 0    
    local len = buffer.len(buf)
    local id = 0
    local value = nil

    while cursor < len do
        id, cursor = id_option.read(buf, cursor)
        local packet = packets.reliable[id]

        if not packet then continue end

        local connections = packet._connections
        local identity = packet._identity

        if identity == "event" then
            value, cursor = packet._schema.read(buf, cursor)
            for i = 1, #connections do
                connections[i](value, player)
            end
        elseif identity == "funct" then
            if run_context == "Server" and player then
                if #connections < 0 then continue end
                value, cursor = packet._schema.read(buf, cursor)

                for i = 1, #connections do
                    local result = connections[i](value, player)
                    table.insert(nh_context.player_queue[player], {id = id, schema = packet._incoming, data = result})
                end

            elseif run_context == "Client" then
                 value, cursor = packet._incoming.read(buf, cursor) 
                 local invokes = packet._invokes

                 if invokes[1] then
                    task.spawn(invokes[1], value)
                    table.remove(invokes, 1)
                 end
            end
        end
    end
end

function Serializer.deserialize_noid(schema: any, connections: any, buf: buffer, player: Player?)
    local value = (schema :: any).read(buf, 0)
    for i = 1, #connections do
        connections[i](value, player)
    end
end

return Serializer 

