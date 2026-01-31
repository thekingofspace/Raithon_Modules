local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient() 

local module = IsClient == true and require(script:WaitForChild("ClientListener")) or require("@self/ServerListener")

export type Replit = {
    Check:() -> (boolean, string?)
}


return module::Replit