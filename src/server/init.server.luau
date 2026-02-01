local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Replit = require(ReplicatedStorage.Shared.Replit)

task.wait(5)

Replit.ReplicateTo(ServerStorage.ClickDetector, Players:GetPlayers())

task.wait(5)
ServerStorage.ClickDetector:Destroy()