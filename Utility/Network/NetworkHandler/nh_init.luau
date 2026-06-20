local nh_context = require(script.Parent.nh_context)
local packet = require(script.Parent.nh_packet)
local nh_settings = require(script.Parent.nh_settings)
local registry = nh_context.dependencies.BufferHandler.Registry

return {
    packet = packet,
    registry = registry,
    settings = nh_settings,
}