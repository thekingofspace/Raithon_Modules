---------------------------------------------------------------------------- VARS
local RunService = game:GetService("RunService")

local IsClient = RunService:IsClient()
if IsClient == true then script:WaitForChild("SharedUtils"); script:WaitForChild("Signals") end
local Objects = require("@self/SharedUtils")
local module = IsClient == true and require(script:WaitForChild("ClientListener")) or require("@self/ServerListener")
---------------------------------------------------------------------------- BUILDER AND TYPES
--[=[
	A library for handling replication

	### Example usage

	```lua

	```
]=]

export type Replit = {
    -- Server Methods
    Check: () -> (boolean, string?);
    ReplicateTo: (players:{Player}, isntance:Instance) -> {[string]:Status}; -- returns a dict mapping config id to status object

    -- Client Methods
}


export type Status = Objects.Status

return module::Replit
