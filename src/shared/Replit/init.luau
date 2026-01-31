---------------------------------------------------------------------------- VARS
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
if IsClient == true then script:WaitForChild("SharedUtils") end
local Objects = require("@self/SharedUtils")
local module = IsClient == true and require(script:WaitForChild("ClientListener")) or require("@self/ServerListener")
---------------------------------------------------------------------------- BUILDER AND TYPES
export type Replit = {
    Check:() -> (boolean, string?)
}

export type Status = Objects.Status

return module::Replit