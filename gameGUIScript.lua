local rs = game.ReplicatedStorage

local status = rs:WaitForChild("Status")
local timer = rs:WaitForChild("Timer")
local currentTagged = rs:WaitForChild("Current Tagged Character")

print(status.Value)
print(timer.Value)
print(currentTagged.Value)

local localPlayer = game.Players.LocalPlayer

--print(player)

local GUI = script.Parent:WaitForChild("GameGUI")
local frame = GUI:WaitForChild("Frame")
local statusGUI = frame:WaitForChild("GameStatus")
local taggedGUI = frame:WaitForChild("Tagged")
local timerGUI = frame:WaitForChild("Timer")

function updateGUI()
	statusGUI.Text = status.Value

	if currentTagged.Value then
		print(localPlayer.Character)
		print(currentTagged.Value)
		print(localPlayer.Character == currentTagged.Value )
		if localPlayer.Character == currentTagged.Value then
			taggedGUI.Text = "You are tagged."
			timerGUI.Text = timer.Value
		else
			taggedGUI.Text = currentTagged.Value.Name .. " is tagged."
			timerGUI.Text = ""
		end
	else
		taggedGUI.Text = ""
	end

end

updateGUI()
status:GetPropertyChangedSignal("Value"):Connect(updateGUI)
currentTagged:GetPropertyChangedSignal("Value"):Connect(updateGUI)
timer:GetPropertyChangedSignal("Value"):Connect(updateGUI)