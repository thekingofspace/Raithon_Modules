---------------------------------------------------------------------------- VARS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local module = {}
export type Status = {

}
---------------------------------------------------------------------------- MODULE

--If the event exists find it, if not create it
--If on client it will wait for the event
function module.FindEvent():RemoteEvent
    if RunService:IsClient() == true then
        return ReplicatedStorage:WaitForChild("REPLIT_REMOTE_EVENT", 500)
    end
    local Event = ReplicatedStorage:FindFirstChild("REPLIT_REMOTE_EVENT")

    if not Event then
        Event = Instance.new("RemoteEvent")
        Event.Name = "REPLIT_REMOTE_EVENT"
        Event.Parent = ReplicatedStorage
    end

    return Event
end

return module