-- Brainrot Rush 3D: the arena, built entirely from Parts.
-- Green baseplate, a conveyor lane down the middle, four corner
-- bases with spawn points, rarity-coloured shop stalls along the
-- north edge, trees, and a welcome sign. No free models, no meshes,
-- no decals. Every sign is turned with CFrame.lookAt so its text
-- faces the arena centre, where the players actually stand.

local Config = require(script.Parent.Config)

local Map = {}

local CENTRE = Vector3.new(0, 0, 0)

local function makePart(parent, name, size, color, pos, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Position = pos
	p.Anchored = true
	p.CanCollide = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- A wooden board with a SurfaceGui on its Front face. `facing` is the
-- point the text should look at: CFrame.lookAt points the part's
-- Front (-Z) face at it, so the sign reads from that direction.
local function makeSign(parent, name, pos, size, text, textColor, bgColor, facing)
	local board = makePart(parent, name, size, bgColor, pos, Enum.Material.Wood)
	local target = facing or CENTRE
	board.CFrame = CFrame.lookAt(pos, Vector3.new(target.X, pos.Y, target.Z))
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = gui
	return board
end

-- Four corner bases. Each entry: { center, pads, sign, spawn,
-- owner, color }. Pads hold the positions characters stand on.
function Map.buildBases(workspace)
	local bases = {}
	local corners = {
		Vector3.new(-70, 0, -70),
		Vector3.new(70, 0, -70),
		Vector3.new(-70, 0, 70),
		Vector3.new(70, 0, 70),
	}
	local colors = {
		Color3.fromRGB(255, 120, 120),
		Color3.fromRGB(120, 160, 255),
		Color3.fromRGB(120, 255, 140),
		Color3.fromRGB(255, 210, 90),
	}
	for i, corner in ipairs(corners) do
		local folder = Instance.new("Folder")
		folder.Name = "Base" .. i
		folder.Parent = workspace

		-- Raised platform with a coloured rim.
		makePart(folder, "Platform", Vector3.new(26, 1, 26), Color3.fromRGB(240, 235, 220), corner + Vector3.new(0, 0.5, 0))
		makePart(folder, "Rim", Vector3.new(28, 0.4, 28), colors[i], corner + Vector3.new(0, 0.2, 0))

		-- Sign post at the base, turned to face the arena centre so
		-- a player walking in from the lane can read it.
		local board = makeSign(folder, "BaseSign", corner + Vector3.new(0, 4, 0), Vector3.new(16, 5, 0.6), "BASE " .. i .. "\nEmpty", Color3.fromRGB(255, 255, 255), colors[i], CENTRE)

		-- Six pads in two rows of three.
		local pads = {}
		for row = 1, 2 do
			for col = 1, 3 do
				local px = corner.X - 7 + (col - 1) * 7
				local pz = corner.Z - 4 + (row - 1) * 8
				local pad = makePart(folder, "Pad" .. ((row - 1) * 3 + col), Vector3.new(5, 0.4, 5), Color3.fromRGB(200, 200, 210), Vector3.new(px, 1.2, pz))
				pad.CanCollide = false
				table.insert(pads, pad.Position + Vector3.new(0, 1, 0))
			end
		end

		-- Spawn point at the back of the base.
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.Color = colors[i]
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.AllowTeamChangeOnTouch = false
		spawn.Duration = 0
		spawn.Position = corner + Vector3.new(0, 1.5, 0)
		spawn.Parent = folder

		table.insert(bases, {
			center = corner,
			pads = pads,
			sign = board,
			spawn = spawn,
			owner = nil,
			color = colors[i],
		})
	end
	return bases
end

-- The conveyor lane: dark strip down the middle with yellow edges
-- and chevrons, so the walking characters read as a market line.
function Map.buildLane(workspace)
	local lane = Instance.new("Folder")
	lane.Name = "Conveyor"
	lane.Parent = workspace
	makePart(lane, "Lane", Vector3.new(152, 0.5, 13), Color3.fromRGB(60, 60, 70), Vector3.new(0, 0.25, Config.LANE_Z))
	for _, side in ipairs({ -7, 7 }) do
		makePart(lane, "Edge", Vector3.new(152, 0.6, 0.8), Color3.fromRGB(255, 210, 0), Vector3.new(0, 0.3, Config.LANE_Z + side))
	end
	for x = -66, 66, 12 do
		local chevron = makePart(lane, "Chevron", Vector3.new(4, 0.6, 4), Color3.fromRGB(255, 210, 0), Vector3.new(x, 0.3, Config.LANE_Z))
		chevron.Orientation = Vector3.new(0, 45, 0)
		chevron.CanCollide = false
	end
	-- Gates read from the middle of the arena: IN faces east down
	-- the lane, OUT faces west back up it.
	makeSign(lane, "StartGate", Vector3.new(-76, 5, 0), Vector3.new(1, 8, 12), "IN", Color3.fromRGB(255, 255, 255), Color3.fromRGB(60, 180, 80), Vector3.new(0, 5, 0))
	makeSign(lane, "EndGate", Vector3.new(76, 5, 0), Vector3.new(1, 8, 12), "OUT", Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 60, 60), Vector3.new(0, 5, 0))
	return lane
end

-- Shop stalls along the north edge, one per rarity, so the lane
-- reads as a market and new players learn the ladder at a glance.
-- Stall signs face south, into the arena.
function Map.buildShops(workspace)
	local shops = Instance.new("Folder")
	shops.Name = "Shops"
	shops.Parent = workspace
	for i, rarity in ipairs(Config.RARITIES) do
		local x = -75 + (i - 1) * 30
		local stall = Instance.new("Folder")
		stall.Name = rarity.name .. "Stall"
		stall.Parent = shops
		makePart(stall, "Counter", Vector3.new(12, 3, 4), Color3.fromRGB(150, 110, 70), Vector3.new(x, 1.5, -86), Enum.Material.Wood)
		makePart(stall, "Awning", Vector3.new(13, 0.5, 6), rarity.color, Vector3.new(x, 6, -86))
		makePart(stall, "PostLeft", Vector3.new(0.6, 6, 0.6), Color3.fromRGB(120, 90, 60), Vector3.new(x - 6, 3, -86), Enum.Material.Wood)
		makePart(stall, "PostRight", Vector3.new(0.6, 6, 0.6), Color3.fromRGB(120, 90, 60), Vector3.new(x + 6, 3, -86), Enum.Material.Wood)
		makeSign(stall, "StallSign", Vector3.new(x, 8.5, -86), Vector3.new(12, 3, 0.6), rarity.name, Color3.fromRGB(255, 255, 255), rarity.color, CENTRE)
	end
	return shops
end

function Map.buildTrees(workspace)
	local trees = Instance.new("Folder")
	trees.Name = "Trees"
	trees.Parent = workspace
	local spots = {
		Vector3.new(-88, 0, -40),
		Vector3.new(-88, 0, 40),
		Vector3.new(88, 0, -40),
		Vector3.new(88, 0, 40),
		Vector3.new(-40, 0, -88),
		Vector3.new(40, 0, -88),
		Vector3.new(-40, 0, 88),
		Vector3.new(40, 0, 88),
	}
	for _, spot in ipairs(spots) do
		local trunk = makePart(trees, "Trunk", Vector3.new(1.5, 6, 1.5), Color3.fromRGB(120, 80, 40), spot + Vector3.new(0, 3, 0), Enum.Material.Wood)
		trunk.CanCollide = false
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves"
		leaves.Shape = Enum.PartType.Ball
		leaves.Size = Vector3.new(7, 7, 7)
		leaves.Color = Color3.fromRGB(60, 180, 80)
		leaves.Position = spot + Vector3.new(0, 8, 0)
		leaves.Anchored = true
		leaves.CanCollide = false
		leaves.Parent = trees
	end
	return trees
end

function Map.buildAll(workspace)
	-- Bright daylight, no fog, vivid colours.
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 10
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(160, 160, 160)
	lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
	lighting.FogEnd = 1000
	lighting.GeographicLatitude = 20

	local bases = Map.buildBases(workspace)
	Map.buildLane(workspace)
	Map.buildShops(workspace)
	Map.buildTrees(workspace)

	-- Welcome sign over the middle of the north side, facing south
	-- into the arena.
	makeSign(workspace, "WelcomeSign", Vector3.new(0, 10, -92), Vector3.new(40, 6, 1), "BRAINROT RUSH 3D", Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 40, 60), CENTRE)

	return bases
end

return Map
