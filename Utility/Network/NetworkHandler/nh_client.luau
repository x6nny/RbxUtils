local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local nh_context = require(script.Parent.nh_context)
local nh_serde = require(script.Parent.nh_serde)
local ser, der = nh_serde.serialize, nh_serde.deserialize

local reliable do
    local container = ReplicatedStorage:WaitForChild("nh_container")
    reliable = container:WaitForChild("nh_reliable") :: RemoteEvent

    reliable.OnClientEvent:Connect(function(buf: buffer)
        der(buf)
    end)
end

nh_context.player_queue[Player] = {}

RunService.Heartbeat:Connect(function()
    for player, queue in nh_context.player_queue do
        if #queue > 0 then
            reliable:FireServer(ser(queue)) 
            table.clear(queue)
        end
    end
end)

return nil