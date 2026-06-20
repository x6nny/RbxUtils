local nh_context = require(script.Parent.nh_context)
local BufferHandler = nh_context.dependencies.BufferHandler

local id_option: any = BufferHandler.Registry.u8
local id_size = id_option.size 
local buffer_size_limit = 10000

return {
    id_option = id_option,
    id_size = id_size,
    buffer_size_limit = buffer_size_limit
}