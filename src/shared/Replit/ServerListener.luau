
local Players = game:GetService("Players")

local SharedUtils = require(script.Parent.SharedUtils)
local Signals = require(script.Parent.Signals)

---------------------------------------------------------------------------- VARS

type module ={
    CustomSignals: {[string]:Signals.Signaler<any>};
    RealSignals: {[string]:RBXScriptSignal};
    Pending: {[string]:Instance};
    ReplicationCache : {[Player ]:any};
}

local module:module = {}
module.CustomSignals = {}
module.RealSignals = {}
module.Pending = {} :: {[string]:Instance}
module.ReplicationCache = {}
module.PendingSinks = {}


local GlobalEvent =  SharedUtils.FindEvent()

local handlers = {
    ReplicaReceived = function(options)

    end
}

---------------------------------------------------------------------------- FUNCTIONS

local function ApplyPlayer(targetPlayer)
    local PlayerFolder = targetPlayer.PlayerGui:FindFirstChild("REPLIT_REPLICATION")
    if not PlayerFolder then
        PlayerFolder = Instance.new("Folder")
        PlayerFolder.Name = "REPLIT_REPLICATION"
        PlayerFolder.Parent = targetPlayer.PlayerGui
    end
    module.ReplicationCache[targetPlayer] = {
        Folder = PlayerFolder
    }
end

local function remoteFired(player:Player, topic:string, options)
    local callback = typeof(topic) == "string" and handlers[topic]
    if callback then
        callback(options)
    end
end

---------------------------------------------------------------------------- EVENTS

for _, Player in ipairs(Players:GetPlayers()) do
    task.spawn(ApplyPlayer, Player)
end
Players.PlayerAdded:Connect(ApplyPlayer)
GlobalEvent.OnServerEvent:Connect(remoteFired)

return module