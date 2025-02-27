local rs = game:GetService("ReplicatedStorage") -- Use ReplicatedStorage
local groundTemplate = rs:WaitForChild("Road")

local groundLength = 50
local piecesAhead = 5
local groundPieces = {}
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Find SpawnLocation and get its CFrame
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if not spawnLocation then
	warn("SpawnLocation not found in workspace!")
	return
end
local spawnCFrame = spawnLocation.CFrame

local function spawnGroundPiece(positionCFrame)
	print("Spawning ground at:", positionCFrame.Position)
	local model = groundTemplate:Clone()

	-- Preserve the original orientation while setting the position
	local originalCFrame = groundTemplate:GetPivot()
	local newCFrame = positionCFrame * CFrame.Angles(originalCFrame:ToEulerAnglesXYZ())

	model:PivotTo(newCFrame)
	model.Parent = workspace
	table.insert(groundPieces, model)
end

local function updateGround()
	while true do
		local playerZ = humanoidRootPart.Position.Z

		-- Remove old ground pieces that are far behind the player
		for i = #groundPieces, 1, -1 do
			if groundPieces[i].PrimaryPart.Position.Z < playerZ - groundLength * (piecesAhead + 1) then
				groundPieces[i]:Destroy()
				table.remove(groundPieces, i)
			end
		end

		-- Ensure new pieces are always generated ahead of the player
		while #groundPieces == 0 or groundPieces[#groundPieces].PrimaryPart.Position.Z < playerZ + groundLength * piecesAhead do
			local lastZ = #groundPieces > 0 and groundPieces[#groundPieces].PrimaryPart.Position.Z or spawnCFrame.Position.Z
			local newPosition = spawnCFrame * CFrame.new(0, 0, lastZ + groundLength - spawnCFrame.Position.Z)
			spawnGroundPiece(newPosition)
		end

		wait(0.1)
	end
end

-- Initial ground generation at the SpawnLocation
for i = 1, piecesAhead do
	local startPosition = spawnCFrame * CFrame.new(0, 0, (i - 1) * groundLength)
	spawnGroundPiece(startPosition)
end

-- Start the ground update loop
spawn(function()
	updateGround()
end)
