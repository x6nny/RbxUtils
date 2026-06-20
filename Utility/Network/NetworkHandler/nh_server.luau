local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local nh_context = require(script.Parent.nh_context)
local nh_serde = require(script.Parent.nh_serde)
local nh_settings = require(script.Parent.nh_settings)

local buffer_size_limit = nh_settings.buffer_size_limit
local ser, der = nh_serde.serialize, nh_serde.deserialize

local reliable, container do
    container = Instance.new("Folder")
    container.Name = "nh_container"
    container.Parent = ReplicatedStorage

    reliable = Instance.new("RemoteEvent")
    reliable.Name = "nh_reliable"
    reliable.Parent = container

    reliable.OnServerEvent:Connect(function(player: Player, buf: buffer)
        if typeof(buf) ~= "buffer" then return end

        if buffer.len(buf) > buffer_size_limit then
           player:Kick("Exceeded network request size limit, you may rejoin.")
        end

        der(buf, player)
    end)
end

local function player_added(player: Player)
    nh_context.player_queue[player] = {}
end

for _, player in Players:GetPlayers() do
    player_added(player)
end

Players.PlayerAdded:Connect(player_added)

Players.PlayerRemoving:Connect(function(player)
    if nh_context.player_queue[player] then
        nh_context.player_queue[player] = nil
    end
end)

RunService.Heartbeat:Connect(function()
    for player, queue in nh_context.player_queue do
        if #queue > 0 then
            reliable:FireClient(player, ser(queue)) 
            table.clear(queue)
        end
    end
end)

return nil