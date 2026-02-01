----------------------------------------------------------------------- VARS
local Players = game:GetService("Players")
local module = {}
local Signals = require(script.Parent.Signals)
local SharedNames = require(script.Parent:WaitForChild("NameSpaces"))
local Utils = require(script.Parent:WaitForChild("Utils"))
local Event = Utils.GetEvent()
local Player = Players.LocalPlayer
local ReplicatedFolder = Player.PlayerGui:WaitForChild(SharedNames.ReplicationTarget, 500)
----------------------------------------------------------------------- CONSTRUCTION
module.Replicated = Utils.GetEnd()
module.TrackedInstances = {}::{[Instance]:string}
module.UID_Regsitry = {}::{[string]:Instance}
module.Events = {}::{[Instance]:RBXScriptConnection}
module.OnReplication = Signals()::Signals.Signaler<>
----------------------------------------------------------------------- CASE SWITCH
local Switch = {
    RemoveInstance = function(ID:string)
        local Instance = module.UID_Regsitry[ID]
        if not Instance then return end
        Instance:Destroy()
    end;

    default = function(...)
        
    end
}

Switch = setmetatable(Switch, {
    __call = function(self, Case:string, ...)
        local NewCase:any = rawget(self, Case) or rawget(self, "default")

        NewCase(...)
    end
})
----------------------------------------------------------------------- FUNCTIONS
local function OnReplication(Child:Instance)
    local ConfigInfo:Utils.Config = nil::any
    do
        local Config = Child:WaitForChild(SharedNames.ConfigName, 500)
        ConfigInfo = Utils.FromConfig(Config)
        Config:Destroy()
    end
    if module.UID_Regsitry[ConfigInfo.UID] then return end
    local NewChild = Child:Clone()
    Event:FireServer("instanceFound", ConfigInfo.StatusID)
    NewChild.Parent = module.Replicated
    module.TrackedInstances[NewChild] = ConfigInfo.UID
    module.UID_Regsitry[ConfigInfo.UID] = NewChild
    module.Events[NewChild] = NewChild.Destroying:Connect(function()
        module.Events[NewChild]:Disconnect()
        local UID:string = module.TrackedInstances[NewChild]
        module.Events[NewChild] = nil
        module.TrackedInstances[NewChild] = nil
        module.UID_Regsitry[UID] = nil
        NewChild = nil
    end)
    module.OnReplication:Fire(NewChild)
end
local function OnEventRecieve(Topic:string, ...)
    Switch(Topic, ...)
end
----------------------------------------------------------------------- EVENTS
ReplicatedFolder.ChildAdded:Connect(OnReplication)
Event.OnClientEvent:Connect(OnEventRecieve)

return module