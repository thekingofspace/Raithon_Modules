local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replit = require(ReplicatedStorage.Shared.Replit)
Replit.OnReplication:Connect(function(Child)
    print(Child)
end)
