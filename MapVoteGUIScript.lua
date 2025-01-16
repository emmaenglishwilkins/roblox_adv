
--https://create.roblox.com/docs/scripting/events/remote

local rs = game.ReplicatedStorage
local voteEvent = rs:WaitForChild("VoteEvent")
local status = rs:WaitForChild("Status")
local maps = rs:WaitForChild("Maps")

local localPlayer = game.Players.LocalPlayer

local mvGUI = script.Parent:WaitForChild("MapVoteGUI")
local frame = mvGUI:WaitForChild("Frame")

local buttons = {
	[frame.GrassButton] = maps.GrassMap,
	[frame.BGButton] = maps.bubbleGumMap,
	[frame.M1Button] = maps.MazeMap,
	[frame.M2Button] = maps.MazeMap2
}


for b, m in pairs(buttons) do --b for button, m for map
	--print("B",b)
	--print("M",m)
	b.MouseButton1Click:Connect(function()
		--turn all the buttons to blue, unless it's the selected button, then turn it green
		for b2, _ in buttons do --b2 for the buttons, _ because we don't need to loop through the maps again 
			if b == b2  then
				b2.BackgroundColor3 = Color3.new(0.555398, 0.836011, 0.330159)
			else
				b2.BackgroundColor3 = Color3.new(.07843137, .67843137, 1)
			end
		end
		voteEvent:FireServer(localPlayer, m)
	end)
end

function toggleVoting()
	--match checks for a substring in a string
	if status.Value:match("Voting") then
		frame.Visible = true
	else
		frame.Visible = false
	end
end

toggleVoting()
status:GetPropertyChangedSignal("Value"):Connect(toggleVoting)