local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local TargetModule = IsClient and require(script:WaitForChild("Client")) or require("@self/Server")
local Signals = require("@self/Signals")

export type Status = {
    Status: "pending" | "dead" | "complete";
    id:string;
    TrackedObject:Instance,
    Owner:Player,
    Changed:Signals.Signaler<any>
}

export type Replit = {
    Replicated:Folder,
    OnReplication:Signals.Signaler<Instance>,

    ReplicateTo:(Instance:Instance, Targets:{Player}) -> {Status},
    UnReplicate:(Instance:Instance, Targets:{Player}) -> ()
}

return TargetModule::Replit