-- Brainrot Rush 3D: stealing and slapping. Any player can pick up a
-- character from another player's base and carry it home, slower than
-- normal, while the victim gets an alert. A slap from the Slap tool
-- knocks the carrier down and drops the character back on its pad.

local Config = require(script.Parent.Config)
local Characters = require(script.Parent.Characters)
local Economy = require(script.Parent.Economy)

local Stealing = {}

local remotes = nil
local carryWelds = {}

local function tell(player, text)
	if remotes and remotes.Notify then
		remotes.Notify:FireClient(player, text)
	end
end

local function humanoidOf(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function rootOf(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Put a carried character back where it belongs: its owner's pad.
function Stealing.dropCarried(player)
	local d = Economy.getData(player)
	if not d or not d.carrying then
		return
	end
	local record = d.carrying
	d.carrying = nil
	local weld = carryWelds[player]
	if weld then
		weld:Destroy()
		carryWelds[player] = nil
	end
	record.root.Anchored = true
	local ownerData = record.owner and Economy.getData(record.owner)
	if ownerData and ownerData.base then
		-- Find a free pad on the owner's base.
		local used = {}
		for _, r in ipairs(Characters.active) do
			if r.state == "owned" and r.baseIndex == ownerData.base then
				used[r.padIndex] = true
			end
		end
		local padIndex = nil
		for i = 1, Config.PADS_PER_BASE do
			if not used[i] then
				padIndex = i
				break
			end
		end
		if padIndex then
			Characters.placeOnPad(record, ownerData.base, padIndex)
		else
			record.state = "owned"
			record.root.CFrame = CFrame.new(ownerData.base.center.X, 2, ownerData.base.center.Z)
		end
	else
		record.state = "owned"
	end
	local humanoid = humanoidOf(player)
	if humanoid then
		humanoid.WalkSpeed = Config.NORMAL_SPEED
	end
end

local function onSteal(player, charId)
	local d = Economy.getData(player)
	if not d then
		return
	end
	if d.carrying then
		tell(player, "You are already carrying a brainrot.")
		return
	end
	if os.clock() - d.lastSteal < Config.STEAL_COOLDOWN then
		return
	end
	d.lastSteal = os.clock()
	local record = Characters.getById(charId)
	if not record or record.state ~= "owned" then
		tell(player, "That brainrot is not on a base.")
		return
	end
	if record.owner == player then
		tell(player, "That one is already yours.")
		return
	end
	local hrp = rootOf(player)
	if not hrp then
		return
	end
	-- Carry it: weld the character above the player's head and slow
	-- the player down, so the dash home is a real risk.
	record.state = "carried"
	record.carrier = player
	d.carrying = record
	record.root.Anchored = false
	local weld = Instance.new("Weld")
	weld.Part0 = hrp
	weld.Part1 = record.root
	weld.C0 = CFrame.new(0, 3.5, 0)
	weld.Parent = hrp
	carryWelds[player] = weld
	local humanoid = humanoidOf(player)
	if humanoid then
		humanoid.WalkSpeed = Config.CARRY_SPEED
	end
	tell(player, "You stole " .. record.def.name .. "! Run home, you are slower now.")
	if record.owner then
		tell(record.owner, player.Name .. " is stealing your " .. record.def.name .. "! Slap them!")
	end
end

-- A slap: find a carrying player in range, knock them down and drop
-- what they are carrying. The victim's character goes home.
local function onSlap(player)
	local d = Economy.getData(player)
	if not d then
		return
	end
	if os.clock() - d.lastSlap < Config.SLAP_COOLDOWN then
		return
	end
	d.lastSlap = os.clock()
	local myRoot = rootOf(player)
	if not myRoot then
		return
	end
	for other, otherData in pairs(Economy.data) do
		if other ~= player and otherData.carrying then
			local otherRoot = rootOf(other)
			if otherRoot and (otherRoot.Position - myRoot.Position).Magnitude <= Config.SLAP_RANGE then
				Stealing.dropCarried(other)
				local humanoid = humanoidOf(other)
				if humanoid then
					humanoid.Sit = true
					task.delay(1.5, function()
						if humanoid.Parent then
							humanoid.Sit = false
						end
					end)
				end
				tell(player, "Slap! You knocked the thief down.")
				tell(other, player.Name .. " slapped you and you dropped the brainrot!")
				return
			end
		end
	end
end

-- Every player gets a Slap tool when their character spawns.
local function giveSlapTool(player)
	local character = player.Character
	if not character then
		return
	end
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then
		return
	end
	if backpack:FindFirstChild("Slap") then
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "Slap"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.8, 0.8, 3)
	handle.Color = Color3.fromRGB(255, 220, 120)
	handle.Parent = tool
	tool.Parent = backpack
	tool.Activated:Connect(function()
		onSlap(player)
	end)
end

function Stealing.init(remoteTable)
	remotes = remoteTable
	remotes.StealCharacter.OnServerEvent:Connect(onSteal)
	remotes.Slap.OnServerEvent:Connect(onSlap)
	-- Clicking a character on another player's base steals it; the
	-- init script calls this from the ClickDetector as well.
	Stealing.trySteal = onSteal
	local players = game:GetService("Players")
	players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			giveSlapTool(player)
		end)
	end)
end

return Stealing
