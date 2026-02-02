local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Replit = require(ReplicatedStorage.Shared.Replit)

task.wait(2)

Replit.ReplicateTo(ServerStorage.ClickDetector, Players:GetPlayers())

task.wait(6)
Replit.ReplicateTo(ServerStorage.ClickDetector, Players:GetPlayers())
print("second")