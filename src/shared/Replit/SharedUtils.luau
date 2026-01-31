---------------------------------------------------------------------------- VARS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
--[=[
	Standard utils files for the whole project
]=]
local SharedUtils = {}
export type Status = {

}

export type Config = {
    ID:string;
    At:number
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

--[=[
    Used by the server to generate a random ID for instances.

	@return ID string
]=]
function SharedUtils.RanID()
    return HttpService:GenerateGUID(false)
end

--[=[
    Add a config to a instance.

	@return Configuration
]=]
function SharedUtils.MakeConfig(ID:string, Target:Instance):Configuration
    local Config = Instance.new("Configuration")
    Config.Name = 'REPLIT_CONFIG_OBJECT'
    Config:SetAttribute("ID", ID)
    Config:SetAttribute("BoundAt", os.time())
    return Config
end

--[=[
    Reads the configuration instance and destroys it

	@return Configs as array
]=]
function SharedUtils.ReadConfig(Target:Instance):Config
    if Target.Name ~= "REPLIT_CONFIG_OBJECT" then
        Target = Target:FindFirstChild("REPLIT_CONFIG_OBJECT")
    end
    assert(Target, "Config not found.")
    local Args = {
        ID = Target:GetAttribute("ID"),
        At = Target:GetAttribute("BoundAt")
    }
    Target:Destroy()
    return Args
end

return SharedUtils