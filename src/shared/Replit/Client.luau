----------------------------------------------------------------------- VARS
local Signals = require(script.Parent:WaitForChild("Signals"))
local SharedNames = require(script.Parent:WaitForChild("NameSpaces"))
local Utils = require(script.Parent:WaitForChild("Utils"))

local Event = Utils.GetEvent()
local ReplicatedFolder = Utils.GetEnd()

----------------------------------------------------------------------- TYPES
type module = {
    Replicated: Folder;
    
    TrackedInstances: {[string]:Instance};
    TrackedEvents: {[string]:RBXScriptConnection};
    UID_Registry: {[Instance]:string};
    
    OnReplication: Signals.Signaler<>
}

----------------------------------------------------------------------- CONSTRUCTION
local module = {}::module
module.Replicated = Utils.GetEnd()
module.TrackedInstances = {}
module.TrackedEvents = {}
module.UID_Regsitry = {}
module.OnReplication = Signals()

----------------------------------------------------------------------- CASE SWITCH
local Switch = {
    RemoveInstance = function(ID:string)
        local Instance = module.UID_Regsitry[ID]
        if not Instance then return end
        Instance:Destroy()
    end;

    default = function(...)
        
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

    if module.UID_Regsitry[ConfigInfo.UID] then return end
    
    local NewChild = Child:Clone()
    NewChild.Parent = module.Replicated

    Event:FireServer("instanceFound", ConfigInfo.StatusID)
    
    module.UID_Registry[NewChild] = ConfigInfo.UID
    module.TrackedInstances[ConfigInfo.UID] = NewChild
    module.Events[NewChild] = NewChild.Destroying:Once(function()        
        local UID:string = module.UID_Registry[NewChild]
        module.Events[NewChild] = nil
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
ReplicatedFolder.ChildAdded:Connect(OnReplication)
Event.OnClientEvent:Connect(OnEventRecieve)

return module