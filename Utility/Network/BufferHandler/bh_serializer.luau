--!native
local Serializer = {}

local function get_size(schema, data)
    local size = 0
    local t_size = (schema.size :: any) :: never

    if typeof(t_size) == "function" then
        size += t_size(data)
    else
        size += t_size
    end

    return size
end

function Serializer.serialize(schema: any, data)
    local size = get_size(schema, data)
    local buf = buffer.create(size)
    schema.write(buf, 0, data)
    return buf
end

function Serializer.deserialize<T>(schema: T, buf): T
    return (schema :: any).read(buf, 0)
end

return Serializer 
