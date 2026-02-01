local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NameSpaces = require(script.Parent.NameSpaces)
local Signals = require(script.Parent.Signals)
local SharedNames = require(script.Parent:WaitForChild("NameSpaces"))
local module = {}

export type Status = {
    Status: "pending" | "dead" | "complete";
    id: string;
    TrackedObject: Instance,
    Owner: Player,
    Changed: Signals.Signaler<any>
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
        return game.ReplicatedStorage:WaitForChild(SharedNames.EventName)
    end

    local Event = ReplicatedStorage:FindFirstChild(SharedNames.EventName)
    if not Event then
        Event = Instance.new("RemoteEvent")
        Event.Name = SharedNames.EventName
        Event.Parent = game.ReplicatedStorage
    end
    return Event
end

function module.GetEnd():Folder
    if RunService:IsClient() == true then
        return game.ReplicatedStorage:WaitForChild(SharedNames.ReplicationEndPoint)
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

return module