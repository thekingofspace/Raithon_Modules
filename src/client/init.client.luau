local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replit = require(ReplicatedStorage.Shared.Replit)

Replit.OnReplication:Once(function(Child)
    task.wait(3)

    Child:Destroy()
end)