local rs = game.ReplicatedStorage
local config = require(rs:WaitForChild("CONFIGURATION"))

local players = game:GetService("Players")
local livingPlayers = {}

local function getLivingPlayers()
	local playerList = game.Players:GetPlayers()
	local livingPlayers = {}
	
	for _, player in pairs(playerList) do
		local character = player.Character or player.CharacterAdded:Wait()
		if character and character:FindFirstChild("Humanoid") then
			table.insert(livingPlayers, character)
		end
	end
	return livingPlayers
	
end
livingPlayers = getLivingPlayers()
while #livingPlayers < config.MinimumPlayersNeeded do
	print("Waiting for players...")
	print(livingPlayers)
	task.wait(1)
	livingPlayers = getLivingPlayers()
end
print("Enough players have joined!")
print(livingPlayers)

local map = workspace.GrassMap -- change the {GrassMap} part to what the model that represents their map is. 

for _, character in pairs(livingPlayers) do
	character.Humanoid.WalkSpeed = config.RunnerSpeed
	character.HumanoidRootPart.CFrame = map.start.CFrame + Vector3.new(0,15,0)
	local player = players:GetPlayerFromCharacter(character)
	player.RespawnLocation = map.start
end
