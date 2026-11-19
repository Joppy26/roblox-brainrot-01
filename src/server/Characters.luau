-- Brainrot Rush 3D: the cast. Every character is assembled from
-- Parts in code, so the whole cast lives in src/ and the place is
-- fully reproducible from the repo. Characters walk the conveyor,
-- wear a billboard with name, rarity and $/s, and can be bought,
-- stolen or carried home.

local Config = require(script.Parent.Config)

local Characters = {}
Characters.active = {}
Characters.nextId = 0

local folder = nil
local onSpawned = nil

local function addPart(model, root, name, size, color, offset, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = false
	p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	if shape then
		p.Shape = shape
	end
	p.Parent = model
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = p
	weld.C0 = CFrame.new(offset)
	p.CFrame = root.CFrame * weld.C0
	weld.Parent = root
	return p
end

local function addWedge(model, root, name, size, color, offset)
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = false
	p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.Parent = model
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = p
	weld.C0 = CFrame.new(offset)
	p.CFrame = root.CFrame * weld.C0
	weld.Parent = root
	return p
end

-- One builder per character. Each takes (model, root) and adds parts
-- relative to the root, which sits at ground level under the model.
local Builders = {}

function Builders.TungTung(model, root)
	-- A log with a bat: brown log body, darker log head, wooden bat.
	addPart(model, root, "Body", Vector3.new(2, 3.5, 2), Color3.fromRGB(150, 100, 50), Vector3.new(0, 2.2, 0), Enum.PartType.Cylinder)
	addPart(model, root, "Head", Vector3.new(1.8, 1.6, 1.8), Color3.fromRGB(120, 75, 35), Vector3.new(0, 4.6, 0))
	addPart(model, root, "EyeLeft", Vector3.new(0.4, 0.4, 0.2), Color3.fromRGB(255, 255, 255), Vector3.new(-0.4, 4.8, 0.95))
	addPart(model, root, "EyeRight", Vector3.new(0.4, 0.4, 0.2), Color3.fromRGB(255, 255, 255), Vector3.new(0.4, 4.8, 0.95))
	addPart(model, root, "Bat", Vector3.new(0.5, 3, 0.5), Color3.fromRGB(200, 160, 100), Vector3.new(1.4, 3, 0.6), Enum.PartType.Cylinder)
	addPart(model, root, "ArmLeft", Vector3.new(0.5, 1.5, 0.5), Color3.fromRGB(150, 100, 50), Vector3.new(-1.2, 2.6, 0))
	addPart(model, root, "FootLeft", Vector3.new(0.8, 0.4, 1.2), Color3.fromRGB(90, 60, 30), Vector3.new(-0.5, 0.2, 0.2))
	addPart(model, root, "FootRight", Vector3.new(0.8, 0.4, 1.2), Color3.fromRGB(90, 60, 30), Vector3.new(0.5, 0.2, 0.2))
end

function Builders.Chimpanzini(model, root)
	-- A chimp holding a banana: brown body, tan face, big ears, banana.
	addPart(model, root, "Body", Vector3.new(2.2, 2.6, 1.8), Color3.fromRGB(120, 80, 40), Vector3.new(0, 2, 0))
	addPart(model, root, "Head", Vector3.new(1.8, 1.6, 1.6), Color3.fromRGB(120, 80, 40), Vector3.new(0, 4, 0), Enum.PartType.Ball)
	addPart(model, root, "Face", Vector3.new(1.2, 1, 0.4), Color3.fromRGB(220, 190, 150), Vector3.new(0, 3.9, 0.8))
	addPart(model, root, "EarLeft", Vector3.new(0.6, 0.8, 0.4), Color3.fromRGB(220, 190, 150), Vector3.new(-1, 4.2, 0))
	addPart(model, root, "EarRight", Vector3.new(0.6, 0.8, 0.4), Color3.fromRGB(220, 190, 150), Vector3.new(1, 4.2, 0))
	addPart(model, root, "Banana", Vector3.new(0.5, 2, 0.5), Color3.fromRGB(255, 220, 0), Vector3.new(1.3, 3, 0.6))
	addPart(model, root, "BananaTip", Vector3.new(0.5, 0.5, 0.5), Color3.fromRGB(180, 140, 0), Vector3.new(1.3, 4.1, 0.6))
	addPart(model, root, "LegLeft", Vector3.new(0.6, 1, 0.6), Color3.fromRGB(100, 65, 30), Vector3.new(-0.5, 0.5, 0))
	addPart(model, root, "LegRight", Vector3.new(0.6, 1, 0.6), Color3.fromRGB(100, 65, 30), Vector3.new(0.5, 0.5, 0))
end

function Builders.Tralalero(model, root)
	-- A shark with legs and sneakers: blue body, white belly, fin,
	-- tail, legs and white sneakers.
	addPart(model, root, "Body", Vector3.new(2, 2.4, 4), Color3.fromRGB(90, 140, 200), Vector3.new(0, 2.6, 0))
	addPart(model, root, "Belly", Vector3.new(1.6, 1.6, 3), Color3.fromRGB(230, 240, 250), Vector3.new(0, 2, 0))
	addPart(model, root, "Head", Vector3.new(1.8, 1.8, 1.6), Color3.fromRGB(90, 140, 200), Vector3.new(0, 3.4, 1.8))
	addPart(model, root, "Snout", Vector3.new(1.4, 1, 1), Color3.fromRGB(200, 220, 240), Vector3.new(0, 3, 2.6))
	addPart(model, root, "EyeLeft", Vector3.new(0.3, 0.4, 0.2), Color3.fromRGB(0, 0, 0), Vector3.new(-0.5, 3.8, 2.5))
	addPart(model, root, "EyeRight", Vector3.new(0.3, 0.4, 0.2), Color3.fromRGB(0, 0, 0), Vector3.new(0.5, 3.8, 2.5))
	addWedge(model, root, "Fin", Vector3.new(0.4, 1.6, 1.6), Color3.fromRGB(60, 100, 160), Vector3.new(0, 4.4, -0.4))
	addPart(model, root, "Tail", Vector3.new(0.4, 1.6, 1.4), Color3.fromRGB(60, 100, 160), Vector3.new(0, 3.2, -2.4))
	addPart(model, root, "LegLeft", Vector3.new(0.5, 1.4, 0.5), Color3.fromRGB(90, 140, 200), Vector3.new(-0.5, 0.7, 0.4))
	addPart(model, root, "LegRight", Vector3.new(0.5, 1.4, 0.5), Color3.fromRGB(90, 140, 200), Vector3.new(0.5, 0.7, 0.4))
	addPart(model, root, "ShoeLeft", Vector3.new(0.7, 0.4, 1.4), Color3.fromRGB(255, 255, 255), Vector3.new(-0.5, 0.2, 0.6))
	addPart(model, root, "ShoeRight", Vector3.new(0.7, 0.4, 1.4), Color3.fromRGB(255, 255, 255), Vector3.new(0.5, 0.2, 0.6))
end

function Builders.Ballerina(model, root)
	-- A ballerina with a cappuccino cup head: pink dress, tutu disc,
	-- cup head with foam and a tiny handle.
	addPart(model, root, "Dress", Vector3.new(1.8, 2, 1.4), Color3.fromRGB(255, 150, 200), Vector3.new(0, 2, 0))
	addPart(model, root, "Tutu", Vector3.new(3.4, 0.3, 3.4), Color3.fromRGB(255, 200, 220), Vector3.new(0, 1.4, 0), Enum.PartType.Cylinder)
	addPart(model, root, "Cup", Vector3.new(1.6, 1.6, 1.6), Color3.fromRGB(240, 230, 210), Vector3.new(0, 4, 0), Enum.PartType.Cylinder)
	addPart(model, root, "Foam", Vector3.new(1.4, 0.4, 1.4), Color3.fromRGB(180, 120, 60), Vector3.new(0, 4.9, 0), Enum.PartType.Cylinder)
	addPart(model, root, "Handle", Vector3.new(0.4, 0.8, 0.4), Color3.fromRGB(240, 230, 210), Vector3.new(1, 4, 0))
	addPart(model, root, "ArmLeft", Vector3.new(0.4, 1.6, 0.4), Color3.fromRGB(255, 210, 180), Vector3.new(-1.1, 2.8, 0))
	addPart(model, root, "ArmRight", Vector3.new(0.4, 1.6, 0.4), Color3.fromRGB(255, 210, 180), Vector3.new(1.1, 2.8, 0))
	addPart(model, root, "LegLeft", Vector3.new(0.5, 1.2, 0.5), Color3.fromRGB(255, 210, 180), Vector3.new(-0.4, 0.6, 0))
	addPart(model, root, "LegRight", Vector3.new(0.5, 1.2, 0.5), Color3.fromRGB(255, 210, 180), Vector3.new(0.4, 0.6, 0))
	addPart(model, root, "ShoeLeft", Vector3.new(0.6, 0.3, 1), Color3.fromRGB(255, 150, 200), Vector3.new(-0.4, 0.15, 0.2))
	addPart(model, root, "ShoeRight", Vector3.new(0.6, 0.3, 1), Color3.fromRGB(255, 150, 200), Vector3.new(0.4, 0.15, 0.2))
end

function Builders.Bombardiro(model, root)
	-- A crocodile bomber plane: green fuselage, wings, tail fin,
	-- snout with teeth, and a propeller nose.
	addPart(model, root, "Fuselage", Vector3.new(2, 1.8, 5), Color3.fromRGB(60, 160, 70), Vector3.new(0, 2.8, 0))
	addPart(model, root, "Snout", Vector3.new(1.6, 1, 1.6), Color3.fromRGB(50, 130, 60), Vector3.new(0, 2.6, 2.8))
	addPart(model, root, "ToothLeft", Vector3.new(0.3, 0.4, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(-0.5, 2.2, 3.2))
	addPart(model, root, "ToothRight", Vector3.new(0.3, 0.4, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(0.5, 2.2, 3.2))
	addPart(model, root, "EyeLeft", Vector3.new(0.4, 0.5, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(-0.5, 3.6, 2.2))
	addPart(model, root, "EyeRight", Vector3.new(0.4, 0.5, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(0.5, 3.6, 2.2))
	addPart(model, root, "WingLeft", Vector3.new(3, 0.3, 1.6), Color3.fromRGB(40, 120, 50), Vector3.new(-2.2, 2.8, 0))
	addPart(model, root, "WingRight", Vector3.new(3, 0.3, 1.6), Color3.fromRGB(40, 120, 50), Vector3.new(2.2, 2.8, 0))
	addWedge(model, root, "TailFin", Vector3.new(0.4, 1.6, 1.4), Color3.fromRGB(40, 120, 50), Vector3.new(0, 4, -2.2))
	addPart(model, root, "Propeller", Vector3.new(0.3, 2.4, 0.3), Color3.fromRGB(80, 80, 80), Vector3.new(0, 2.8, 3.6))
	addPart(model, root, "LegLeft", Vector3.new(0.5, 1, 0.5), Color3.fromRGB(50, 130, 60), Vector3.new(-0.6, 0.5, 0.5))
	addPart(model, root, "LegRight", Vector3.new(0.5, 1, 0.5), Color3.fromRGB(50, 130, 60), Vector3.new(0.6, 0.5, 0.5))
end

function Builders.Lirili(model, root)
	-- A cactus elephant: green cactus body with spikes, big ears,
	-- a long trunk and a pink flower on top.
	addPart(model, root, "Body", Vector3.new(2.6, 2.6, 3.2), Color3.fromRGB(60, 180, 90), Vector3.new(0, 2.2, 0))
	addPart(model, root, "Head", Vector3.new(2, 1.8, 1.8), Color3.fromRGB(60, 180, 90), Vector3.new(0, 4, 1.2), Enum.PartType.Ball)
	addPart(model, root, "Trunk", Vector3.new(0.6, 2.2, 0.6), Color3.fromRGB(50, 150, 75), Vector3.new(0, 3.2, 2.4))
	addPart(model, root, "EarLeft", Vector3.new(0.4, 1.4, 1.2), Color3.fromRGB(40, 140, 65), Vector3.new(-1.1, 4.2, 1))
	addPart(model, root, "EarRight", Vector3.new(0.4, 1.4, 1.2), Color3.fromRGB(40, 140, 65), Vector3.new(1.1, 4.2, 1))
	addPart(model, root, "Spike1", Vector3.new(0.3, 0.8, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(-0.8, 3.8, -0.8))
	addPart(model, root, "Spike2", Vector3.new(0.3, 0.8, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(0.8, 3.8, -0.8))
	addPart(model, root, "Spike3", Vector3.new(0.3, 0.8, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(0, 3.8, 0.8))
	addPart(model, root, "Flower", Vector3.new(0.9, 0.5, 0.9), Color3.fromRGB(255, 120, 200), Vector3.new(0, 5.1, 1.2), Enum.PartType.Ball)
	addPart(model, root, "LegLeft", Vector3.new(0.7, 1.2, 0.7), Color3.fromRGB(50, 150, 75), Vector3.new(-0.7, 0.6, 0.6))
	addPart(model, root, "LegRight", Vector3.new(0.7, 1.2, 0.7), Color3.fromRGB(50, 150, 75), Vector3.new(0.7, 0.6, 0.6))
	addPart(model, root, "LegBackLeft", Vector3.new(0.7, 1.2, 0.7), Color3.fromRGB(50, 150, 75), Vector3.new(-0.7, 0.6, -0.8))
	addPart(model, root, "LegBackRight", Vector3.new(0.7, 1.2, 0.7), Color3.fromRGB(50, 150, 75), Vector3.new(0.7, 0.6, -0.8))
end

-- The floating label every character wears: name, rarity colour,
-- mutation and money per second, readable from across the arena.
-- The three lines are named, so other modules can find the rate
-- line by name instead of guessing by colour. The offset sits above
-- the tallest model (Lirili tops out near 5.4 studs), so the label
-- never clips into a head.
local function buildBillboard(model, root, def, mutation)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.new(0, 140, 0, 64)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 5.8, 0)
	gui.AlwaysOnTop = true
	gui.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.BackgroundTransparency = 0.3
	nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 15
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Parent = gui

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Position = UDim2.new(0, 0, 0, 22)
	rarityLabel.Size = UDim2.new(1, 0, 0, 20)
	rarityLabel.BackgroundTransparency = 0.3
	rarityLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	rarityLabel.Text = def.rarity
	rarityLabel.TextColor3 = Config.rarityColor(def.rarity)
	rarityLabel.TextSize = 14
	rarityLabel.Font = Enum.Font.FredokaOne
	rarityLabel.Parent = gui

	local rateText = Config.formatCash(def.rate) .. "/s"
	if mutation.name ~= "" then
		rateText = mutation.name .. " " .. Config.formatCash(def.rate * mutation.mult) .. "/s"
	end
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "RateLabel"
	rateLabel.Position = UDim2.new(0, 0, 0, 42)
	rateLabel.Size = UDim2.new(1, 0, 0, 20)
	rateLabel.BackgroundTransparency = 0.3
	rateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	rateLabel.Text = rateText
	rateLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	rateLabel.TextSize = 14
	rateLabel.Font = Enum.Font.FredokaOne
	rateLabel.Parent = gui

	return gui
end

-- init takes the spawn callback as an argument, so no module ever
-- writes to a shared mutable slot to wire up click handling.
function Characters.init(workspace, spawnedCallback)
	folder = Instance.new("Folder")
	folder.Name = "Brainrots"
	folder.Parent = workspace
	onSpawned = spawnedCallback
end

function Characters.conveyorCount()
	local count = 0
	for _, record in ipairs(Characters.active) do
		if record.state == "conveyor" then
			count += 1
		end
	end
	return count
end

function Characters.spawnOne()
	local rarity = Config.rollRarity()
	local def = Config.characterOfRarity(rarity)
	local mutation = { name = "", mult = 1 }
	Characters.nextId += 1

	local model = Instance.new("Model")
	model.Name = def.name .. "_" .. Characters.nextId
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(2, 1, 2)
	root.Color = Color3.fromRGB(255, 255, 255)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.Position = Vector3.new(Config.LANE_START_X, 1, Config.LANE_Z)
	root.Parent = model
	model.PrimaryPart = root

	Builders[def.build](model, root)
	buildBillboard(model, root, def, mutation)

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 40
	click.Parent = root

	model.Parent = folder
	local record = {
		id = Characters.nextId,
		def = def,
		mutation = mutation,
		model = model,
		root = root,
		state = "conveyor",
		owner = nil,
		baseIndex = nil,
		padIndex = nil,
		x = Config.LANE_START_X,
	}
	table.insert(Characters.active, record)
	if onSpawned then
		onSpawned(record)
	end
	return record
end

function Characters.getById(id)
	for _, record in ipairs(Characters.active) do
		if record.id == id then
			return record
		end
	end
	return nil
end

function Characters.getByModel(model)
	for _, record in ipairs(Characters.active) do
		if record.model == model then
			return record
		end
	end
	return nil
end

function Characters.ownedBy(player)
	local owned = {}
	for _, record in ipairs(Characters.active) do
		if record.state == "owned" and record.owner == player then
			table.insert(owned, record)
		end
	end
	return owned
end

function Characters.totalRate(player, rebirthMult)
	local total = 0
	for _, record in ipairs(Characters.ownedBy(player)) do
		total += record.def.rate * record.mutation.mult
	end
	return total * rebirthMult
end

function Characters.placeOnPad(record, base, padIndex)
	record.state = "owned"
	record.baseIndex = base
	record.padIndex = padIndex
	local padPos = base.pads[padIndex]
	record.root.CFrame = CFrame.new(padPos.X, padPos.Y + 1, padPos.Z)
	record.x = padPos.X
end

function Characters.remove(record)
	for i, r in ipairs(Characters.active) do
		if r == record then
			table.remove(Characters.active, i)
			break
		end
	end
	if record.model then
		record.model:Destroy()
	end
end

-- The conveyor walk: every heartbeat, characters on the lane step
-- forward; any that reach the east gate without being bought leave.
function Characters.startConveyor()
	task.spawn(function()
		while true do
			local dt = task.wait(0.1)
			for i = #Characters.active, 1, -1 do
				local record = Characters.active[i]
				if record.state == "conveyor" then
					record.x += Config.WALK_SPEED * dt
					record.root.CFrame = CFrame.new(record.x, 1, Config.LANE_Z)
						* CFrame.Angles(0, math.rad(-90), 0)
					if record.x >= Config.LANE_END_X then
						Characters.remove(record)
					end
				end
			end
		end
	end)
end

-- A steady trickle of new characters onto the lane, capped so the
-- conveyor never floods the map with models.
function Characters.startSpawning()
	task.spawn(function()
		while true do
			if Characters.conveyorCount() < Config.MAX_CONVEYOR then
				Characters.spawnOne()
			end
			task.wait(Config.SPAWN_INTERVAL)
		end
	end)
end

return Characters
