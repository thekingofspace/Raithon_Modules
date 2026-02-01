local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local TargetModule = IsClient and require(script:WaitForChild("Client")) or require("@self/Server")
local Signals = require("@self/Signals")
local Utils = require(script.Utils)

export type Status = Utils.Status

export type Replit = {
    Replicated:Folder,
    OnReplication:Signals.Signaler<Instance>,

    ReplicateTo:(Instance:Instance, Targets:{Player}) -> {Status},
    UnReplicate:(Instance:Instance, Targets:{Player}) -> ()
}

return TargetModule::Replit