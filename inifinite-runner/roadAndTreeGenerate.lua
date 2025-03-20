local ss = game:GetService("ServerStorage")
local groundTemplate = ss:FindFirstChild("GroundPiece")
local Rtree = ss:FindFirstChild("rightTrees")
local Ltree = ss:FindFirstChild("leftTrees")

local cf = groundTemplate:GetPivot()
local Ltree_cf = Ltree:GetPivot()
local Rtree_cf = Rtree:GetPivot()
-- size: 64.733, 0.202, 64.733
-- pos: -1.749, 0.1, 47.398
-- orientation: 0, 90, 0

local groundLength = 64.733 
local piecesAhead = 5
local groundPieces = {}
local moveZStep = .5 
local loopWait = 0.05
-- local offset = 0
local trees = {} -- Store trees here
local treeMoveZStep = moveZStep  -- Same speed as road

local function spawnGroundPiece(postion)
	local model = groundTemplate:Clone()
	model:PivotTo(cf + postion)
	model.Parent = workspace
	-- model.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 10)
	table.insert(groundPieces, model)
end

local function spawnTrees(position)
	-- trees pivot position -67.5, 0.5, 53.5
	local rightTreeClone = Rtree:Clone()
	local leftTreeClone = Ltree:Clone()
	
	local gr = rightTreeClone["right-ground"]
	local gl = leftTreeClone["left-ground"]
	
	--workspace.Terrain:FillBlock(gr.CFrame, gr.Size, Enum.Material.Grass)
	--workspace.Terrain:FillBlock(gl.CFrame, gl.Size, Enum.Material.Grass)

	rightTreeClone:PivotTo(Rtree_cf + position + Vector3.new(0,2,0))  -- Offset right
	leftTreeClone:PivotTo(Ltree_cf + position + Vector3.new(0,2,0))  -- Offset left

	rightTreeClone.Parent = workspace
	leftTreeClone.Parent = workspace

	table.insert(trees, rightTreeClone)
	table.insert(trees, leftTreeClone)
end

local function moveGround()
	while true do
		for i=#groundPieces, 1, -1 do
			local groundPiece = groundPieces[i]
			groundPiece:PivotTo(groundPiece:GetPivot() + 
				Vector3.new(0,0,moveZStep))
			if groundPiece:GetPivot().Position.Z > groundLength then
				groundPiece:Destroy()
				table.remove(groundPieces, i)
			end
		end
		
		-- move trees
		for i =#trees, 1, -1 do
			local tree = trees[i]
			tree:PivotTo(tree:GetPivot() + Vector3.new(0,0,treeMoveZStep))
			if tree:GetPivot().Position.Z > groundLength then
				tree:Destroy()
				table.remove(trees, i)
			end
		end

		if groundPieces[#groundPieces]:GetPivot().Position.Z >= -groundLength * (piecesAhead - 1) then
			local newPosition = Vector3.new(0,0,-groundLength * piecesAhead)
			spawnGroundPiece(newPosition)
			spawnTrees(newPosition)
		end
		wait()
	end
end

wait(3)
for i=1, piecesAhead, 1 do
	local position = Vector3.new(0,0, -i * groundLength)
	spawnGroundPiece(position)
	spawnTrees(position)
	-- wait(1)
end

moveGround()