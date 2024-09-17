-- configuration file
local rs = game.ReplicatedStorage
local config = require(rs:WaitForChild("CONFIGURATION"))
-- players 
local players = game:GetService("Players")
local livingPlayers = {} -- array

function getLivingPlayers()
	local playerList = game.Players:GetPlayers() -- get all the players 
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
	-- if there are not enough players 
	if #livingPlayers < config.MinimumPlayersNeeded then
		print("Waiting for more players...")
		print(livingPlayers)
		task.wait(1)
	end
livingPlayers = getLivingPlayers()
end

print("Enough players have joined")
print(livingPlayers)

local map = workspace.GrassMap

for _, character in pairs(livingPlayers) do
	character.Humanoid.WalkSpeed = config.RunnerSpeed
	character.HumanoidRootPart.CFrame = map.start.CFrame + Vector3.new(0,15,0)
	local player = players:GetPlayerFromCharacter(character)
	player.RespawnLocation = map.start
end

