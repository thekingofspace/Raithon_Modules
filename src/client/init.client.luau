local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replit = require(ReplicatedStorage.Shared.Replit)

Replit.OnReplication:Once(function(Child)
    local Track = Replit.Track(Child)

    Track:Listen():Connect(function(Topic, ...)
        print(Topic, ...)
    end)
end)