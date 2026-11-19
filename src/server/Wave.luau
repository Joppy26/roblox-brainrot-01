-- Brainrot Rush 3D: the Brainrot Wave. Every three minutes a warning
-- sounds, then a red wall sweeps across the middle of the map. Anyone
-- the wall itself passes is caught right then, drops what they are
-- carrying and is knocked back to their base. The dash home is the
-- second threat in the game, next to stealing.

local Config = require(script.Parent.Config)
local Economy = require(script.Parent.Economy)
local Stealing = require(script.Parent.Stealing)

local Wave = {}

local remotes = nil

local function insideBase(player, base)
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	local pos = root.Position
	return math.abs(pos.X - base.center.X) < 14 and math.abs(pos.Z - base.center.Z) < 14
end

-- Send one player home: drop whatever they carry, teleport them to
-- their base, and tell them why.
local function knockHome(player, d)
	Stealing.dropCarried(player)
	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(d.base.center.X, 3, d.base.center.Z)
		end
	end
	if remotes and remotes.Notify then
		remotes.Notify:FireClient(player, "The wave caught you outside! Back to your base.")
	end
end

local function sweep(workspace)
	-- A tall red translucent wall that crosses the lane from west to
	-- east, so players can see the danger coming.
	local wall = Instance.new("Part")
	wall.Name = "WaveWall"
	wall.Size = Vector3.new(2, 30, 200)
	wall.Color = Color3.fromRGB(255, 40, 60)
	wall.Transparency = 0.5
	wall.Anchored = true
	wall.CanCollide = false
	wall.Material = Enum.Material.Neon
	wall.Position = Vector3.new(-95, 15, 0)
	wall.Parent = workspace

	-- The wall catches players as it passes them, step by step, so
	-- someone who outruns the wall at the last second really escapes,
	-- and someone it rolls over is knocked home at once.
	local caught = {}
	local steps = 100
	for i = 1, steps do
		local x = -95 + (190 * i) / steps
		wall.Position = Vector3.new(x, 15, 0)
		for player, d in pairs(Economy.data) do
			if d.base and not caught[player] and not insideBase(player, d.base) then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and math.abs(root.Position.X - x) < 4 then
					caught[player] = true
					knockHome(player, d)
				end
			end
		end
		task.wait(Config.WAVE_SWEEP_TIME / steps)
	end
	wall:Destroy()
	-- Safety net: anyone still outside their base after the sweep
	-- also goes home, so nobody is left stranded in the lane.
	for player, d in pairs(Economy.data) do
		if d.base and not caught[player] and not insideBase(player, d.base) then
			knockHome(player, d)
		end
	end
end

function Wave.start(workspace)
	task.spawn(function()
		while true do
			task.wait(Config.WAVE_PERIOD - Config.WAVE_WARNING)
			-- Warning: 20 seconds to get home.
			if remotes and remotes.WaveWarning then
				remotes.WaveWarning:FireAllClients(Config.WAVE_WARNING)
			end
			if remotes and remotes.Notify then
				remotes.Notify:FireAllClients("BRAINROT WAVE in " .. Config.WAVE_WARNING .. " seconds! Get to your base!")
			end
			task.wait(Config.WAVE_WARNING)
			sweep(workspace)
			if remotes and remotes.Notify then
				remotes.Notify:FireAllClients("The Brainrot Wave has passed.")
			end
		end
	end)
end

function Wave.init(remoteTable)
	remotes = remoteTable
end

return Wave
