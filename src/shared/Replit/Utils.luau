local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NameSpaces = require(script.Parent.NameSpaces)
local Signals = require(script.Parent.Signals)
local SharedNames = require(script.Parent:WaitForChild("NameSpaces"))
local module = {}

export type Status = {
    Status: "pending" | "dead" | "complete";
    StatusID: string;
    TrackedObject: Instance,
    Owner: Player,
    Changed: Signals.Signaler<any>
}

export type Hidden = {
    Tracked_Wild:{Signals.Signaler<(string, ...any)>},
    Topics:{
        [string]:Signals.Signaler<...any>
    }
}

export type Tracker = {
    ListenTo:(self:Tracker, Topic:string) -> Signals.Signaler<...any>;
    Listen:(self:Tracker) -> Signals.Signaler<(string, ...any)>;
}

export type Config = {
    UID:string;
    StatusID:string
}

function module.GenerateGUID()
    return HttpService:GenerateGUID(false)
end

function module.GetEvent():RemoteEvent
    if RunService:IsClient() == true then
        return script.Parent:FindFirstChild(SharedNames.EventName)
    end

    local Event = ReplicatedStorage:FindFirstChild(SharedNames.EventName)
    if not Event then
        Event = Instance.new("RemoteEvent")
        Event.Name = SharedNames.EventName
        Event.Parent = script.Parent
    end
    return Event
end

function module.GetEnd():Folder
    if RunService:IsClient() == true then
        return game.ReplicatedStorage:WaitForChild(SharedNames.ReplicationEndPoint,500)
    end

    local Event = ReplicatedStorage:FindFirstChild(SharedNames.ReplicationEndPoint)
    if not Event then
        Event = Instance.new("Folder")
        Event.Name = SharedNames.ReplicationEndPoint
        Event.Parent = game.ReplicatedStorage
    end
    return Event
end

function module.ToConfig(UID:string, StatusID:string):Configuration
    local Target = Instance.new("Configuration")
    Target.Name = NameSpaces.ConfigName
    Target:SetAttribute("UID", UID)
    Target:SetAttribute("StatusID", StatusID)
    return Target
end

function module.FromConfig(Config:Configuration):Config
    return {
        UID = Config:GetAttribute("UID");
        StatusID = Config:GetAttribute("StatusID")
    }
end

local Tracker = {}
Tracker.__index = Tracker

function Tracker.Listen(self:Tracker & Hidden)
    local Signal = Signals()
    table.insert(self.Tracked_Wild, Signal)
    return Signal
end

function Tracker.ListenTo(self:Tracker & Hidden, Topic:string)
    if self.Topics[Topic] then return self.Topics[Topic] end

    local Signal = Signals()
    self.Topics[Topic] = Signal
    return Signal
end

function module.NewTracker():Tracker
    local self = setmetatable({Tracked_Wild = {}, Topics = {}}, Tracker)::any

    return self
end

return module