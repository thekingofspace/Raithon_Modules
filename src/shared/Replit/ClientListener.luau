local Players = game:GetService("Players")

export type Config = {
    ID:string;

}

local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")

local function onChildAdded(child:Instance)
    local config = child:FindFirstChildOfClass("Configuration")
    config = config and config:GetAttributes()::Config
    -- do stuff
end

do  -- setup stuff
    playerGui.ChildAdded:Connect(onChildAdded)
end

return {
    CustomSignals = {};
    RealSignals = {};
}