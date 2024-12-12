local rs = game.ReplicatedStorage
local currentTagged = rs:WaitForChild("Current Tagged Character")
local status = rs:WaitForChild("Status")

local localPlayer = game.Players.LocalPlayer
print(localPlayer)

local GUI = script.Parent:WaitForChild("GameGUI")
local frame = GUI:WaitForChild("Frame")
local statusGUI = frame:WaitForChild("GameStatus")
local taggedGUI = frame:WaitForChild("Tagged")
local timerGUI = frame:WaitForChild("Timer")

function updateGUI()
	statusGUI.Text = status.Value
	if currentTagged.Value then
		if localPlayer.Character == currentTagged.Value then
			taggedGUI.Text = "you are it!"
		else
			taggedGUI.Text = currentTagged.Value.Name .. " is it :o."
		end
	end
end

updateGUI()
currentTagged:GetPropertyChangedSignal("Value"):Connect(updateGUI)
status:GetPropertyChangedSignal("Value"):Connect(updateGUI)