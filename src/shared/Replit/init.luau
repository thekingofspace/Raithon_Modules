local RunService = game:GetService("RunService")
local Signals = require("@self/Signals")

type TrackedAspects = {
    CustomSignals:{Signals.Signaler<any>};
    RealSignals:{RBXScriptConnection};
}

local TrackedAspects:TrackedAspects = nil

do -- Initial Constructor
    local IsClient = RunService:IsClient() 

    if IsClient == true then
        TrackedAspects = require(script:WaitForChild("ClientListener"))
    else
        TrackedAspects = require("@self/ServerListener")
    end
end

local module = {}

return module