local RunService = game:GetService("RunService")
local nh_types = require(script.Parent.nh_types)

return {
    player_queue = {} :: {[Player]: nh_types.Payload},

    packets = {
        reliable = {},
        reliable_count = -1,
    },

    connections = {},
    run_context = if RunService:IsServer() then "Server" else "Client",
    dependencies = {
        BufferHandler = require(script.Parent.Parent.BufferHandler)
    }
}