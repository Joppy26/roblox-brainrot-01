-- Brainrot Rush 3D: money, bases and rebirth. The server owns every
-- number. Cash and income live in leaderstats, buying and rebirth go
-- through RemoteEvents with server-side validation, and the income
-- tick runs on the server once a second. A buy is only valid when
-- the player is actually standing near the character they clicked.

local Config = require(script.Parent.Config)
local Characters = require(script.Parent.Characters)

local Economy = {}
Economy.data = {}
Economy.bases = {}

local remotes = nil
local notifyEvent = nil

function Economy.rebirthMult(player)
	local d = Economy.data[player]
	if not d then
		return 1
	end
	return 1 + Config.REBIRTH_BONUS * d.rebirths
end

function Economy.getData(player)
	return Economy.data[player]
end

local function rootOf(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Keep the base sign honest: owner name and current income per second.
function Economy.updateSign(base)
	if not base or not base.sign then
		return
	end
	local gui = base.sign:FindFirstChildOfClass("SurfaceGui")
	if not gui then
		return
	end
	local label = gui:FindFirstChildOfClass("TextLabel")
	if not label then
		return
	end
	if base.owner then
		local rate = Characters.totalRate(base.owner, Economy.rebirthMult(base.owner))
		label.Text = base.owner.Name .. "\n" .. Config.formatCash(rate) .. "/s"
	else
		label.Text = "BASE\nEmpty"
	end
end

function Economy.assignBase(player)
	for _, base in ipairs(Economy.bases) do
		if base.owner == nil then
			base.owner = player
			Economy.updateSign(base)
			return base
		end
	end
	return nil
end

function Economy.freeBase(player)
	for _, base in ipairs(Economy.bases) do
		if base.owner == player then
			base.owner = nil
			Economy.updateSign(base)
		end
	end
end

local function freePad(base)
	local used = {}
	for _, record in ipairs(Characters.active) do
		if record.state == "owned" and record.baseIndex == base then
			used[record.padIndex] = true
		end
	end
	for i = 1, Config.PADS_PER_BASE do
		if not used[i] then
			return i
		end
	end
	return nil
end

local function cashOf(player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		return 0
	end
	local cash = stats:FindFirstChild("Cash")
	if not cash then
		return 0
	end
	return cash.Value
end

local function setCash(player, amount)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local cash = stats:FindFirstChild("Cash")
		if cash then
			cash.Value = math.floor(amount)
		end
	end
end

local function setIncome(player, amount)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local income = stats:FindFirstChild("Income")
		if income then
			income.Value = math.floor(amount)
		end
	end
end

local function setRebirths(player, amount)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local r = stats:FindFirstChild("Rebirths")
		if r then
			r.Value = amount
		end
	end
end

local function tell(player, text)
	if notifyEvent then
		notifyEvent:FireClient(player, text)
	end
end

-- Buying: the character must still be on the conveyor, the player
-- must be standing near it, and must have a base with a free pad
-- and enough cash. The mutation is rolled here, on the server, and
-- the billboard rate line is updated to match.
local function onBuy(player, charId)
	local d = Economy.data[player]
	if not d or not d.base then
		tell(player, "No base yet, wait for a free one.")
		return
	end
	local record = Characters.getById(charId)
	if not record or record.state ~= "conveyor" then
		tell(player, "That brainrot is gone.")
		return
	end
	local hrp = rootOf(player)
	if not hrp then
		return
	end
	if (record.root.Position - hrp.Position).Magnitude > Config.BUY_RANGE then
		tell(player, "Too far away to buy " .. record.def.name .. ". Get closer to the conveyor.")
		return
	end
	if cashOf(player) < record.def.price then
		tell(player, "Not enough cash for " .. record.def.name .. ". It costs " .. Config.formatCash(record.def.price) .. ".")
		return
	end
	local padIndex = freePad(d.base)
	if not padIndex then
		tell(player, "Your base is full.")
		return
	end
	setCash(player, cashOf(player) - record.def.price)
	record.mutation = Config.rollMutation()
	record.owner = player
	Characters.placeOnPad(record, d.base, padIndex)
	-- Refresh the rate line on the billboard, found by its name.
	local gui = record.root:FindFirstChild("Label")
	if gui then
		local rateLabel = gui:FindFirstChild("RateLabel")
		if rateLabel then
			local rate = record.def.rate * record.mutation.mult
			if record.mutation.name ~= "" then
				rateLabel.Text = record.mutation.name .. " " .. Config.formatCash(rate) .. "/s"
			else
				rateLabel.Text = Config.formatCash(rate) .. "/s"
			end
		end
	end
	Economy.updateSign(d.base)
	if record.mutation.name ~= "" then
		tell(player, "Bought " .. record.def.name .. " (" .. record.mutation.name .. ")!")
	else
		tell(player, "Bought " .. record.def.name .. "!")
	end
end

-- Rebirth: needs enough total income, then cash and characters reset
-- for a permanent +25% income per rebirth.
local function onRebirth(player)
	local d = Economy.data[player]
	if not d then
		return
	end
	local rate = Characters.totalRate(player, Economy.rebirthMult(player))
	if rate < Config.REBIRTH_INCOME_NEEDED then
		tell(player, "Rebirth needs " .. Config.formatCash(Config.REBIRTH_INCOME_NEEDED) .. "/s income. You have " .. Config.formatCash(rate) .. "/s.")
		return
	end
	for i = #Characters.active, 1, -1 do
		local record = Characters.active[i]
		if record.owner == player and record.state ~= "carried" then
			Characters.remove(record)
		end
	end
	d.rebirths += 1
	setCash(player, 0)
	setRebirths(player, d.rebirths)
	setIncome(player, 0)
	tell(player, "Rebirth " .. d.rebirths .. "! Income x" .. (1 + Config.REBIRTH_BONUS * d.rebirths) .. " forever.")
end

function Economy.onPlayerAdded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.START_CASH
	cash.Parent = stats
	local income = Instance.new("IntValue")
	income.Name = "Income"
	income.Value = 0
	income.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = stats

	Economy.data[player] = {
		base = Economy.assignBase(player),
		rebirths = 0,
		carrying = nil,
		lastSlap = 0,
		lastSteal = 0,
	}
	if Economy.data[player].base then
		tell(player, "Welcome to Brainrot Rush 3D! Buy brainrots off the conveyor.")
	else
		tell(player, "All four bases are taken right now. Watch and wait for a free base.")
	end
end

function Economy.onPlayerRemoving(player)
	local d = Economy.data[player]
	if d and d.carrying then
		-- Put the carried character back on its owner's pad.
		local record = d.carrying
		d.carrying = nil
		if record.owner then
			local ownerData = Economy.data[record.owner]
			if ownerData and ownerData.base then
				local padIndex = freePad(ownerData.base)
				if padIndex then
					Characters.placeOnPad(record, ownerData.base, padIndex)
				end
			end
		end
	end
	Economy.freeBase(player)
	Economy.data[player] = nil
end

-- Once a second, every owned character pays its owner.
function Economy.startIncomeTick()
	task.spawn(function()
		while true do
			task.wait(1)
			for player, d in pairs(Economy.data) do
				local rate = Characters.totalRate(player, Economy.rebirthMult(player))
				if rate > 0 then
					setCash(player, cashOf(player) + rate)
				end
				setIncome(player, rate)
				if d.base then
					Economy.updateSign(d.base)
				end
			end
		end
	end)
end

function Economy.init(remoteTable, bases)
	remotes = remoteTable
	notifyEvent = remotes.Notify
	Economy.bases = bases
	remotes.BuyCharacter.OnServerEvent:Connect(onBuy)
	remotes.Rebirth.OnServerEvent:Connect(onRebirth)
end

-- Clicking a character on the conveyor buys it; the init script calls
-- this from the ClickDetector as well as the RemoteEvent.
Economy.tryBuy = onBuy

return Economy
