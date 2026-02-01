local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
----------------------------------------------------------------------- VARS
local Utils = require("./Utils")
local Names = require("./NameSpaces")
local configs = require("./ReplitConfigs")
local Signals = require("./Signals")
local Event = Utils.GetEvent()
----------------------------------------------------------------------- TYPES
type module = {
    Replicated: Folder;

    TrackedInstances: {[string]:Instance};
    TrackedStatuses: {[string]:Utils.Status};
    TrackedSignals: {[string]:RBXScriptConnection};
    UID_Registry: {[Instance]:string};
}
----------------------------------------------------------------------- CONSTRUCTION
local module = {}::module
module.Replicated = Utils.GetEnd()
module.TrackedInstances = {}
module.TrackedStatuses = {}
module.TrackedSignals = {}
module.UID_Registry = {}
----------------------------------------------------------------------- CASE SWITCH
local Switch = {
    ["instanceFound"] = function(Player:Player, StatusID:string)
        local Status = module.TrackedStatuses[StatusID]
        if not Status then return end
        module.TrackedStatuses[StatusID] = nil
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
    for ID, Status in pairs(module.TrackedStatuses) do
        if Status.Owner == Player then
            Status.Status = "dead"
            module.TrackedStatuses[ID] = nil
            Status.TrackedObject:Destroy()
            Status.TrackedObject = nil
            Status.Changed:Fire()
        end
    end
    local playerGui = Player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        playerGui:FindFirstChild(Names.ReplicationTarget):Destroy()
    end
end

local function CreateStatus(id:string, OwnedObject:Instance, Owner:Player)
    local Status = {
        Status = "pending";
        StatusID = id;
        TrackedObject = OwnedObject;
        Owner = Owner;
        Changed = Signals();
    }
    module.TrackedStatuses[id] = Status
    return Status
end

local function SetupObject(Instance:Instance)
    if not module.UID_Registry[Instance] then
        local ID = Utils.GenerateGUID()
        module.UID_Registry[Instance] = ID
        module.TrackedInstances[ID] = Instance
        module.TrackedSignals[ID] = Instance.Destroying:Connect(function()--TODO: Why not use :Once()?
            module.UnReplicate(Instance, Players:GetPlayers())
            module.TrackedSignals[ID]:Disconnect()
            module.TrackedInstances[ID] = nil
            module.TrackedSignals[ID] = nil
            module.UID_Registry[Instance] = nil
            Instance = nil::any
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
    SetupObject(Instance) --TODO: IF the same Instance is passed to .ReplicateTo() twice, may cause unexpected behaviour
    for _, item in ipairs(Targets) do
        if not item.PlayerGui then continue end
        local PlayerTargetFolder = item.PlayerGui:WaitForChild(Names.ReplicationTarget)
        local PlayerObject = Instance:Clone()
        local Status = CreateStatus(Utils.GenerateGUID(), PlayerObject, item)
        Utils.ToConfig(module.UID_Registry[Instance], Status.StatusID).Parent = PlayerObject
        PlayerObject.Parent = PlayerTargetFolder
        table.insert(Ret, Status)
    end

    return Ret
end

function module.UnReplicate(Instance:Instance, Targets:{Player})
    if not module.UID_Registry[Instance] then
        return
    end
    local ID:string = module.UID_Registry[Instance] --TODO: if no players are being replicated to, remove from UID_Registry
    for _, item in ipairs(Targets) do
        Event:FireClient(item, "RemoveInstance", ID)
    end
end

return module