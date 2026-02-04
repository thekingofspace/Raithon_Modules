local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local TargetModule = IsClient and require(script:WaitForChild("Client")) or require("@self/Server")
local Signals = require("@self/Signals")
local Utils = require(script.Utils)

export type Status = Utils.Status
export type Tracker = Utils.Tracker

--[[
In the sacred tongue of the Omnissiah, we chant hail, spirit of the machine essence divine in your code and circuitry. The stars aligned by the Omnissiah's will, we commune and bind with sacred oils and chants. Your grace we find blessed be the gears in perfect sink they turn. Blessed be the spark in holy fire they burn. through rights arcane. Your wisdom we discern, in your hollowed core. The sacred mystery yearn. Blessed be the Omnissiah!
]]

export type Reduct = {
    Replicated:Folder,
    OnReplication:Signals.Signaler<Instance>,

    ReplicateTo:(Instance:Instance, Targets:{Player}) -> {Status},
    UnReplicate:(Instance:Instance, Targets:{Player}) -> (),
    ReplicateChanges:(Instance:Instance, Targets:{Player}, Topic:string, ...any) -> (),
    IsReplicated:(Instance:Instance, Targets:{Player}) -> {[Player]:boolean},

    Track:(Target:Instance) -> Tracker,
}

return TargetModule::Reduct