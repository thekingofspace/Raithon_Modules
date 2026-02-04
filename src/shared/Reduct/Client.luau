local Players = game:GetService("Players")
----------------------------------------------------------------------- VARS
local Signals = require(script.Parent:WaitForChild("Signals"))
local SharedNames = require(script.Parent:WaitForChild("NameSpaces"))
local Utils = require(script.Parent:WaitForChild("Utils"))

local Player = Players.LocalPlayer
local Event = Utils.GetEvent()
local ReplicatedCache = Player.PlayerGui:WaitForChild(SharedNames.ReplicationTarget, 500)

----------------------------------------------------------------------- TYPES
type module = {
    Replicated: Folder;
    
    TrackedInstances: {[string]:Instance};
    UID_Registry: {[Instance]:string};
    Trackers:{[Instance]:Utils.Tracker},
    Track:(Target:Instance) -> Utils.Tracker,
    
    OnReplication: Signals.Signaler<>
}

----------------------------------------------------------------------- CONSTRUCTION
local module = {}::module
module.Replicated = Utils.GetEnd()
module.TrackedInstances = {}
module.UID_Registry = {}
module.Trackers = {}
module.OnReplication = Signals()

function module.Track(Target:Instance)
    if module.Trackers[Target] then return module.Trackers[Target] end

    local Tracker = Utils.NewTracker()
    module.Trackers[Target] = Tracker
    return Tracker
end

----------------------------------------------------------------------- CASE SWITCH
local Switch = {
    RemoveInstance = function(ID:string)
        local Instance = module.UID_Registry[ID]
        if not Instance then return end
        Instance:Destroy()
    end;

    UpdateInstance = function(ID:string, Topic:string, ...)
        local Target = module.TrackedInstances[ID]
        local Tracker:Utils.Tracker & Utils.Hidden = module.Trackers[Target]
        if Target and Tracker then
            local Section = Tracker.Topics[Topic]
            if Section then
                Tracker.Topics[Topic]:Fire(...)
            end
            Tracker.Tracked_Wild:Fire(Topic, ...)
        end
    end,

    AsyncCheck = function(ID:string)
        Event:FireServer("asyncUpdate", ID, module.TrackedInstances[ID] ~= nil)
    end,

    default = function(...)
        -- EXPLOITERRRRR!!!!!!
        -- local exploiter = {...}[1]
        -- exploiter:Decompile()
        -- >:D
    end;
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

    if module.TrackedInstances[ConfigInfo.UID] then return end
    
    local NewChild = Child:Clone()
    NewChild.Parent = module.Replicated

    Event:FireServer("instanceFound", ConfigInfo.StatusID, ConfigInfo.UID)
    
    module.UID_Registry[NewChild] = ConfigInfo.UID
    module.TrackedInstances[ConfigInfo.UID] = NewChild
    NewChild.Destroying:Once(function()        
        local UID:string = module.UID_Registry[NewChild]
        module.Trackers[NewChild] = nil
        Event:FireServer("instanceRemove", UID)
        module.UID_Registry[NewChild] = nil
        module.TrackedInstances[UID] = nil
        NewChild = nil
    end)
    module.OnReplication:Fire(NewChild)
end

local function OnEventRecieve(Topic:string, ...)
    Switch(Topic, ...)
end

----------------------------------------------------------------------- EVENTS
ReplicatedCache.ChildAdded:Connect(OnReplication)
Event.OnClientEvent:Connect(OnEventRecieve)

return module