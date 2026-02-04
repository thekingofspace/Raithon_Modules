local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reduct = require(ReplicatedStorage.Shared.Reduct)

Reduct.OnReplication:Once(function(Child)
    local Track = Reduct.Track(Child)

    Track:Listen():Connect(function(Topic, ...)
        print(Topic, ...)
    end)
end)