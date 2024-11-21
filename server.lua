-- configuration file
local rs = game.ReplicatedStorage
local config = require(rs:WaitForChild("CONFIGURATION"))
-- keeping track of tagged player
local currentTagged = Instance.new("ObjectValue")
currentTagged.Parent = rs
currentTagged.Name = "Current Tagged Character"

local status = Instance.new("StringValue")
status.Name = "Status"
status.Parent = rs

local timer = Instance.new("StringValue")
timer.Name = "Timer"
timer.Parent = rs

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

local outline = Instance.new("Highlight")
outline.FillTransparency = 1
outline.OutlineColor = Color3.new(255,0,0)
local bomb = game.ServerStorage.BOMB:Clone()

function tag(character)
	print("Tagging", character)
	task.wait(bomb:Destroy())
	if currentTagged.Value then 
		while currentTagged.Value:FindFirstChild("BOMB") do
			currentTagged.Value.BOMB:Destroy()
		end
	end
	bomb = game.ServerStorage.BOMB:Clone()
	bomb.Parent = character
	bomb.PrimaryPart.CFrame = character.UpperTorso.CFrame
	bomb.stickToPlayer.Part0 = character.UpperTorso

	character.Humanoid.WalkSpeed = config.TaggedSpeed
	outline.Parent = character
	currentTagged.Value = character
end

function untag(character)
	print("untagging", character)
	character.Humanoid.WalkSpeed = config.RunnerSpeed
end

local function countdown(seconds)
	for secondsLeft = seconds, 0, -1 do 
		print(secondsLeft)
		timer.Value = "You will explode in " .. secondsLeft .. " seconds"
		task.wait(1)
	end
end

livingPlayers = getLivingPlayers()
while #livingPlayers < config.MinimumPlayersNeeded do 
	-- if there are not enough players 
	if #livingPlayers < config.MinimumPlayersNeeded then
		--print("Waiting for more players...")
		status.Value = "Waiting for more players..."
		print(livingPlayers)
		task.wait(1)
	end
	livingPlayers = getLivingPlayers()
end

print("Enough players have joined")
print(livingPlayers)
status.Value = ""
currentTagged.Value = nil 

local map = workspace.GrassMap
local tagTicket = true

for _, character in pairs(livingPlayers) do
	character.Humanoid.WalkSpeed = config.RunnerSpeed
	character.HumanoidRootPart.CFrame = map.start.CFrame + Vector3.new(0,15,0)
	local player = players:GetPlayerFromCharacter(character)
	player.RespawnLocation = map.start

	character.Humanoid.Touched:Connect(function(part)
		if tagTicket then
			tagTicket = false
			local character2 = part.Parent
			if game.Players:GetPlayerFromCharacter(character2) then
				if character == currentTagged.Value then
					untag(character)
					tag(character2)
					wait(2)
				elseif character2 == currentTagged.Value then
					untag(character2)
					tag(character)
					wait(2)
				end
			end
		end
		tagTicket = true
	end)
end

livingPlayers = getLivingPlayers()

if #livingPlayers > 1 and currentTagged.Value == nil then
	local randomCharacter = livingPlayers[Random.new():NextInteger(1,#livingPlayers)]
	tag(randomCharacter)
end

countdown(config.ExplodeTime[#livingPlayers])
