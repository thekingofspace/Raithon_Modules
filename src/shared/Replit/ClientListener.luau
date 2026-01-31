---------------------------------------------------------------------------- VARS
local module = {}
local Player:Player = game:GetService("Players").LocalPlayer
local UI_Folder:Folder = Player.PlayerGui:WaitForChild("REPLIT_REPLICATION", 500)
---------------------------------------------------------------------------- EVENTS
UI_Folder.ChildAdded:Connect(function(Child)

end)

return module