local RunService = game:GetService("RunService")
local Signals = require("@self/Signals")

type TrackedAspects = {
    CustomSignals:{[string]:Signals.Signaler<any>};
    RealSignals:{[string]:RBXScriptConnection};
}

local TrackedAspects:TrackedAspects = nil

do -- Initial Constructor
    local IsClient = RunService:IsClient() 

    if IsClient == true then
        TrackedAspects = require(script:WaitForChild("ClientListener"))
    else
        TrackedAspects = require("@self/ServerListener")
        print(`Replit booted up, clients should be listening to signals. use replit.check() to ensure.`)
    end
end

local module = {}

export type Server = {
    Check: () -> (boolean, string?); -- similar to pcall
    ReplicateTo: (receivers:{Player}, instance:Instance)->{[number]:ReplitInstance}; -- returns dict mapping an id to ReplitInstance, one for each player
    
}

return module::Replit
