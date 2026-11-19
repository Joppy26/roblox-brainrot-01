-- Brainrot Rush 3D: server entry point.
-- Builds the arena, starts the conveyor, wires the economy, stealing
-- and the Brainrot Wave, and hands every player a base and a Slap tool.

local Players = game:GetService("Players")

local Config = require(script.Parent.Config)
local Map = require(script.Parent.Map)
local Characters = require(script.Parent.Characters)
local Economy = require(script.Parent.Economy)
local Remotes = require(script.Parent.Remotes)
local Stealing = require(script.Parent.Stealing)
local Wave = require(script.Parent.Wave)

math.randomseed(os.time())

local workspace = game:GetService("Workspace")
local bases = Map.buildAll(workspace)
local remotes = Remotes.create()

Characters.init(workspace)
Economy.init(remotes, bases)
Stealing.init(remotes)
Wave.init(remotes)

-- Clicking a character is how you buy and steal: on the conveyor it
-- is a purchase, on another player's base it is a steal attempt.
Characters.onSpawned = function(record)
	local click = record.root:FindFirstChildOfClass("ClickDetector")
	if not click then
		return
	end
	click.MouseClick:Connect(function(player)
		if record.state == "conveyor" then
			Economy.tryBuy(player, record.id)
		elseif record.state == "owned" then
			Stealing.trySteal(player, record.id)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	Economy.onPlayerAdded(player)
end)
Players.PlayerRemoving:Connect(function(player)
	Economy.onPlayerRemoving(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	Economy.onPlayerAdded(player)
end

Characters.startConveyor()
Characters.startSpawning()
Economy.startIncomeTick()
Wave.start(workspace)

print("Brainrot Rush 3D is running: " .. #Config.CHARACTERS .. " characters, " .. #bases .. " bases.")
