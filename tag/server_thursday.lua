--configuration file
local rs = game.ReplicatedStorage
local config = require(rs:WaitForChild("CONFIGURATION"))

-- keep track of who is tagged with a 
-- checkable value that will live in replicated storage
local currentTagged = Instance.new("ObjectValue")
currentTagged.Parent = rs
currentTagged.Name = "Current Tagged Character"-- this is how we will find in from the gui script later


-- GUI messages
local status = Instance.new("StringValue")
status.Name = "Status" -- this is how we will find in from the gui script later
status.Parent = rs

local timer = Instance.new("StringValue")
timer.Name = "Timer"
timer.Parent = rs
timer.Value = ""


----VOTING FOR MAPS----
local startVoting = rs:FindFirstChild("VotingOpen")
local voteEvent = rs:FindFirstChild("VoteEvent")
local endVoting = rs:FindFirstChild("VotingClosed")
local maps = rs:WaitForChild("Maps")
local map = nil -- where the winning map will go

local votes = {} --each player's vote ex: {[player1] = Map2, [player2] = Map3, [player3] = Map3}
local votesTallied = {
	[maps.GrassMap] = 0,
	[maps.bubbleGumMap] = 0,
	[maps.MazeMap] = 0,
	[maps.MazeMap2] = 0
}

function addVote(_, player, map)
	--votes will be tallied AFTER the voting period, because a player may change their mind
	votes[player] = map
	print("VOTED")
	print(votes)
end


voteEvent.OnServerEvent:Connect(addVote)




-- players
local players = game:GetService("Players")

-- red outline for whoever is "it"
local outline = Instance.new("Highlight")
outline.FillTransparency = 1
outline.OutlineColor = Color3.new(255,0,0)

-- bomb
local bomb = game.ServerStorage.BOMB:Clone()

-- function to make someone "it"
function tag(character)
	--print("tagging", character)
	task.wait(bomb:Destroy()) --destroy the previous bomb
	if currentTagged.Value then --make sure we really got all the bomb clones off of the tagged player
		while currentTagged.Value:FindFirstChild("BOMB") do
			currentTagged.Value:FindFirstChild("BOMB"):Destroy()
		end
	end
	bomb = game.ServerStorage.BOMB:Clone() --make a new bomb clone
	bomb.Parent = character -- give it to the new tagged person
	bomb.PrimaryPart.CFrame = character.UpperTorso.CFrame --send the glue (remember that was the model's primary part) to the character's torso
	bomb.stickToPlayer.Part0 = character.UpperTorso --use the stickToPlayer weld constraint
	outline.Parent = character
	character.Humanoid.WalkSpeed = config.TaggedSpeed
	currentTagged.Value = character
end

-- function to make someone no longer "it"
function untag(character)
	--print("untagging", character)
	character.Humanoid.WalkSpeed = config.RunnerSpeed
end



local function countdown(seconds)
	for secondsLeft = seconds, 0, -1 do
		print(secondsLeft)
		timer.Value = "You will explode in " .. secondsLeft .. " seconds."
		task.wait(1)
	end
end

local deadPlayers = {}

local function explode() 
	local explosion = Instance.new("Explosion")
	explosion.DestroyJointRadiusPercent = 0
	explosion.Position = currentTagged.Value.HumanoidRootPart.Position
	explosion.Parent = workspace


	local player = players:GetPlayerFromCharacter(currentTagged.Value)
	player.RespawnLocation = workspace.lobby

	table.insert(deadPlayers, player.UserId)

	currentTagged.Value.Humanoid.Health = 0
	currentTagged.Value = nil
end

local function isDead(character)
	local player = players:GetPlayerFromCharacter(character)
	local id = player.UserId
	if #deadPlayers > 0 then
		for currentIndex = 1, #deadPlayers do
			print("CHECKING:", deadPlayers[currentIndex])
			if deadPlayers[currentIndex] == id then
				return true
			end
		end
	end
	return false
end


-- get all the living players
function getLivingPlayers()
	local playerList = game.Players:GetPlayers()
	local livingPlayers = {}

	for _, player in pairs(playerList) do
		local character = player.Character or player.CharacterAdded:Wait() --If player.Character is nil then it will wait for CharacterAdded event to fire because of :Wait()
		print("CHARACTER:", character)
		print("FOUND DEAD:",isDead(character))
		print("DEAD:", deadPlayers)
		if character and character:FindFirstChild("Humanoid") and not isDead(character) then
			table.insert(livingPlayers, character)
		end
	end
	return livingPlayers
end


----Game Flow Starts:


while true do -- play multiple games
	local livingPlayers = {}
	--make sure there is at least 2 players
	while #livingPlayers < config.MinimumPlayersNeeded do
		livingPlayers = getLivingPlayers()
		if #livingPlayers < config.MinimumPlayersNeeded then
			status.Value = "Waiting for players..."
			task.wait(1)
		end
	end

	--Voting for a Map
	votes = {} -- empty the votes from any previous round
	local voteTimer = 0
	while voteTimer < 20 do
		status.Value = "Voting for map..."
		task.wait(1)
		voteTimer = voteTimer + 1
	end

	--Tally Votes
	--first clear votes from previous games
	for m, _ in votesTallied do
		votesTallied[m] = 0
	end
	for _, m in votes do --_ because we don't care which player voted for it, m for map
		votesTallied[m] = votesTallied[m] + 1
	end
	print(votesTallied)
	local max = 0 -- most votes
	local chosenMap = maps:GetChildren()[Random.new():NextInteger(1, #maps:GetChildren())] -- map with most votes (start with a random map in case no one voted)
	for m, v in votesTallied do -- m for map, v for votes
		--print("V", v)
		--print("M", m)
		if v > max then
			max = v
			chosenMap = m
		end
	end

	status.Value = "The " .. chosenMap.Name .. " was chosen."

	if map then
		map:Destroy() -- destroy the previous map clone
	end
	map = chosenMap:Clone()
	map.Parent = workspace

	task.wait(2) --give the map time to load in


	--the rounds repeat until there is one player left standing
	while #livingPlayers > 1 do
		livingPlayers = getLivingPlayers()

		--tagging
		--Debouncing
		local tagTicket = true 

		for _, character in pairs(livingPlayers) do
			--setup
			character.Humanoid.WalkSpeed = config.RunnerSpeed
			character.HumanoidRootPart.CFrame = map.start.CFrame + Vector3.new(0,15,0)

			--set their respawn to the map spawn point
			local player = players:GetPlayerFromCharacter(character)
			player.RespawnLocation = map.start



			--connect each character to the tag function when touched
			character.Humanoid.Touched:Connect(function(part)
				if tagTicket then
					local character2 = part.Parent
					--character2 and character bumped into each other
					--what happens next depends on who was "it" 
					--print(game.Players:GetPlayerFromCharacter(character2))
					if game.Players:GetPlayerFromCharacter(character2) then
						tagTicket = false --ticket is gone, nothing will interrupt this tag
						--print("Current Tagged", currentTagged.Value)
						if character == currentTagged.Value then	
							untag(character)
							tag(character2)
							wait(3) -- wait so the tag doesnt go back and forth really fast (cooldown)
						elseif character2 == currentTagged.Value then
							untag(character2)
							tag(character)
							wait(3)
						end
						tagTicket = true --let the tagging start again
					end
				end
			end)
		end--ends for loop through all the characters



		livingPlayers = getLivingPlayers()
		if #livingPlayers > 1 and currentTagged.Value == nil then
			--pick a random character
			local randomCharacter = livingPlayers[Random.new():NextInteger(1, #livingPlayers)]

			--freeze them for a little bit
			randomCharacter.HumanoidRootPart.Anchored = true --freeze them
			for i = 10, 0, -1 do
				status.Value = "The round begins in " .. i .. " seconds."
				task.wait(1)
			end
			status.Value = ""
			randomCharacter.HumanoidRootPart.Anchored = false --unfreeze

			tag(randomCharacter)
		end

		countdown(config.ExplodeTime[#livingPlayers])
		explode()
		livingPlayers = getLivingPlayers() --so we can know if there is only 1 person left
	end

	--one player left:
	if #livingPlayers == 1 then
		print(livingPlayers)
		status.Value = livingPlayers[1].Name .. " is the winner!!!"
		currentTagged.Value = nil
		timer.Value = ""
	end

	wait(10)
	--play again

	table.clear(deadPlayers)
end