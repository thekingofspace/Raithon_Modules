---------------------------------------------------------------------------- VARS
local module = {}
local Players = game:GetService("Players")
local SharedUtils = require("./SharedUtils")
local GlobalEvent = SharedUtils.FindEvent()
local ReplicationCache:{[Player]:any} = {}
---------------------------------------------------------------------------- FUNCTIONS
local function ApplyPlayer(targetPlayer)
    local PlayerFolder = targetPlayer.PlayerGui:FindFirstChild("REPLIT_REPLICATION")
    if not PlayerFolder then
        PlayerFolder = Instance.new("Folder")
        PlayerFolder.Name = "REPLIT_REPLICATION"
        PlayerFolder.Parent = targetPlayer.PlayerGui
    end
    ReplicationCache[targetPlayer] = {
        Folder = PlayerFolder
    }
end
---------------------------------------------------------------------------- EVENTS
for _, Player in ipairs(Players:GetPlayers()) do
    task.spawn(ApplyPlayer, Player)
end
Players.PlayerAdded:Connect(ApplyPlayer)

return module