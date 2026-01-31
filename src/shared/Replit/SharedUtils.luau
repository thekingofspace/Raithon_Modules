---------------------------------------------------------------------------- VARS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--[=[
	Standard utils files for the whole project
]=]
local SharedUtils = {}
export type Status = {

}
---------------------------------------------------------------------------- MODULE
--[=[
	**CLIENT SCOPE**
    * Will wait 500 seconds for the event if it is not found it will spawn a error

    **SERVER SCOPE**
    * Will use `FindFirstChild` to attempt to locate the track event. if not found it will create it and return it

	@return Event for things
]=]
function SharedUtils.FindEvent():RemoteEvent
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

return SharedUtils