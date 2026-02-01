local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
----------------------------------------------------------------------- VARS
local module = {}
local Utils = require("./Utils")
local Names = require("./NameSpaces")
local configs = require("./Configs")
local Signals = require("./Signals")
local Event = Utils.GetEvent()
----------------------------------------------------------------------- TYPES
export type Status = {
    Status: "pending" | "dead" | "complete";
    id:string;
    TrackedObject:Instance,
    Owner:Player,
    Changed:Signals.Signaler<any>
}
----------------------------------------------------------------------- CONSTRUCTION
module.Replicated = Utils.GetEnd()
module.TrackedInstances = {}::{[Instance]:string}
module.Status = {}::{[string]:Status}
module.TrackedSignals = {}
module.ID_Track = {}::{[string]:Instance}
----------------------------------------------------------------------- CASE SWITCH
local Switch = {
    ["instanceFound"] = function(Player:Player, StatusID:string)
        local Status = module.Status[StatusID]
        if not Status then return end
        module.Status[StatusID] = nil
        Status.Status = "complete"
        Status.TrackedObject:Destroy()
        Status.TrackedObject = nil
        Status.Changed:Fire()
    end,
    default = function(Player:Player, ...)
        
    end
}

Switch = setmetatable(Switch, {
    __call = function(self, Case:string, ...)
        local NewCase:any = rawget(self, Case) or rawget(self, "default")

        NewCase(...)
    end
})
----------------------------------------------------------------------- Status

----------------------------------------------------------------------- FUNCTIONS
local function OnEventRecieve(Player:Player, Topic:string, ...)
    Switch(Topic, Player, ...)
end
local function UpdatePlayer(Player:Player)
    if Player.PlayerGui:FindFirstChild(Names.ReplicationTarget) then
        return
    end
    local TargetFolder = Instance.new("Folder")
    TargetFolder.Name = Names.ReplicationTarget
    TargetFolder.Parent = Player.PlayerGui
end
local function playerLeft(Player:Player)
    for I, Status in pairs(module.Status) do
        if Status.Owner == Player then
            Status.Status = "dead"
            module.Status[I] = nil
            Status.TrackedObject:Destroy()
            Status.TrackedObject = nil
            Status.Changed:Fire()
        end
    end
    if Player:FindFirstAncestorOfClass("PlayerGui") then
        Player:FindFirstAncestorOfClass("PlayerGui"):FindFirstChild(Names.ReplicationTarget):Destroy()
    end
end

local function CreateStatus(id:string, OwnedObject:Instance, Owner:Player)
    local Status = {Status = "pending", id = id, TrackedObject = OwnedObject, Owner = Owner, Changed = Signals()}
    module.Status[id] = Status
    return Status
end

local function SetupObject(Instance:Instance)
    if not module.TrackedInstances[Instance] then
        local ID = Utils.GenerateGUID()
        module.TrackedInstances[Instance] = ID
        module.ID_Track[ID] = Instance
        module.TrackedSignals[ID] = Instance.Destroying:Connect(function()
            module.UnReplicate(Instance, Players:GetPlayers())
            module.TrackedSignals[ID]:Disconnect()
            module.ID_Track[ID] = nil
            module.TrackedSignals[ID] = nil
            module.TrackedInstances[Instance] = nil
            Instance = nil
            ID = nil
        end)
    end
end
----------------------------------------------------------------------- EVENTS
Event.OnServerEvent:Connect(OnEventRecieve)
for _, item in ipairs(Players:GetPlayers()) do
    UpdatePlayer(item)
end
Players.PlayerAdded:Connect(UpdatePlayer)
Players.PlayerRemoving:Connect(playerLeft)
----------------------------------------------------------------------- MODULE

function module.ReplicateTo(Instance:Instance, Targets:{Player}):{Status}
    if not Instance:IsDescendantOf(ServerStorage) and configs.ToggleWarnings == false then
        warn("[REPLIT] - Instances are recommended to be kept in server storage.")
    end
    local Ret = {}
    SetupObject(Instance)
    for _, item in ipairs(Targets) do
        if not item.PlayerGui then continue end
        local PlayerTargetFolder = item.PlayerGui:WaitForChild(Names.ReplicationTarget)
        local PlayerObject = Instance:Clone()
        local Status = CreateStatus(Utils.GenerateGUID(), PlayerObject, item)
        Utils.ToConfig(module.TrackedInstances[Instance], Status.id).Parent = PlayerObject
        PlayerObject.Parent = PlayerTargetFolder
        table.insert(Ret, Status)
    end

    return Ret
end

function module.UnReplicate(Instance:Instance, Targets:{Player})
    if not module.TrackedInstances[Instance] then
        return
    end
    local ID:string = module.TrackedInstances[Instance]
    for _, item in ipairs(Targets) do
        Event:FireClient(item, "RemoveInstance", ID)
    end
end

return module