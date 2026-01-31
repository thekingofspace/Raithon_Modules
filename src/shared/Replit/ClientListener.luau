---------------------------------------------------------------------------- VARS
local module = {}
local Player:Player = game:GetService("Players").LocalPlayer
local SharedUtils = require(script.Parent:WaitForChild("SharedUtils"))
local GlobalEvent = SharedUtils.FindEvent()
local UI_Folder:Folder = Player.PlayerGui:WaitForChild("REPLIT_REPLICATION", 500)
---------------------------------------------------------------------------- EVENTS
UI_Folder.ChildAdded:Connect(function(Child)

end)

return module