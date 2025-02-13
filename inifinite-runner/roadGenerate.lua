local rs = game:GetService("ReplicatedStorage") -- Use ReplicatedStorage
local groundTemplate = rs:WaitForChild("Road")

local groundLength = 50
local piecesAhead = 5
local groundPieces = {}
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")


local function spawnGroundPiece(position)
	print("Spawning ground at:", position)
	local model = groundTemplate:Clone()

	-- Preserve the original orientation while setting the position
	local originalCFrame = groundTemplate:GetPivot()
	local newCFrame = CFrame.new(position.Position) * CFrame.Angles(originalCFrame:ToEulerAnglesXYZ())

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
			local lastZ = #groundPieces > 0 and groundPieces[#groundPieces].PrimaryPart.Position.Z or playerZ
			local newPosition = CFrame.new(0, 0, lastZ + groundLength)
			spawnGroundPiece(newPosition)
		end

		wait(0.1)
	end
end

-- Initial ground generation
for i = 1, piecesAhead do
	spawnGroundPiece(CFrame.new(0, 0, (i - 1) * groundLength))
end

-- Start the ground update loop
spawn(function()
	updateGround()
end)
