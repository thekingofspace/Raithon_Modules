local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient() 

local module = IsClient == true and require(script:WaitForChild("ClientListener")) or require("@self/ServerListener")

export type Replit = {
    -- Server Methods
    Check: () -> (boolean, string?);
    ReplicateTo: (players:{Player}, isntance:Instance) -> {[string]:ReplitInstance}; -- returns a dict mapping config id to status object

    -- Client Methods
    
}

export type ReplitInstance = {
    State:{}
}

return module::Replit
