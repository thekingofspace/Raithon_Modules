local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local TargetModule = IsClient and require(script:WaitForChild("Client")) or require("@self/Server")
local Signals = require("@self/Signals")
local Utils = require(script.Utils)

export type Status = Utils.Status
export type Tracker = Utils.Tracker

export type Reduct = {
    Replicated:Folder,
    OnReplication:Signals.Signaler<Instance>,

    ReplicateTo:(Instance:Instance, Targets:{Player}) -> {Status},
    UnReplicate:(Instance:Instance, Targets:{Player}) -> (),
    ReplicateChanges:(Instance:Instance, Targets:{Player}, Topic:string, ...any) -> (),

    Track:(Target:Instance) -> Tracker,
}

return TargetModule::Reduct