local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Reduct = require(ReplicatedStorage.Shared.Reduct)

task.wait(2)

Reduct.ReplicateTo(ServerStorage.ClickDetector, Players:GetPlayers())

task.wait(3)

Reduct.ReplicateChanges(ServerStorage.ClickDetector, Players:GetPlayers(), "test43", "test")