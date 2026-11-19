-- Brainrot Rush 3D: shared tuning numbers and the cast list.
-- Every other server module requires this one, so the whole game's
-- balance lives in one place and the client never decides a price.

local Config = {}

-- Arena geometry. The conveyor runs along X at Z = 0, from the west
-- end to the east end. Bases sit in the four corners.
Config.ARENA_HALF = 96
Config.LANE_Z = 0
Config.LANE_HALF_WIDTH = 6
Config.LANE_START_X = -72
Config.LANE_END_X = 72
Config.WALK_SPEED = 4.5
Config.SPAWN_INTERVAL = 5
Config.PADS_PER_BASE = 6
Config.MAX_BASES = 4

-- Rarities, in ladder order. Color is the rarity colour used on
-- billboards, stalls and base signs.
Config.RARITIES = {
	{ name = "Common", color = Color3.fromRGB(170, 170, 170), weight = 40 },
	{ name = "Rare", color = Color3.fromRGB(80, 160, 255), weight = 28 },
	{ name = "Epic", color = Color3.fromRGB(170, 80, 255), weight = 16 },
	{ name = "Legendary", color = Color3.fromRGB(255, 170, 0), weight = 9 },
	{ name = "Mythic", color = Color3.fromRGB(255, 60, 90), weight = 5 },
	{ name = "Secret", color = Color3.fromRGB(255, 235, 60), weight = 2 },
}

-- The cast. price is what a player pays, rate is cash per second.
-- build is the name of the builder function in Characters.
Config.CHARACTERS = {
	{
		name = "Tung Tung Sahur",
		rarity = "Common",
		price = 25,
		rate = 1,
		build = "TungTung",
	},
	{
		name = "Chimpanzini Bananini",
		rarity = "Rare",
		price = 150,
		rate = 5,
		build = "Chimpanzini",
	},
	{
		name = "Tralalero Tralala",
		rarity = "Epic",
		price = 600,
		rate = 15,
		build = "Tralalero",
	},
	{
		name = "Ballerina Cappuccina",
		rarity = "Legendary",
		price = 2000,
		rate = 40,
		build = "Ballerina",
	},
	{
		name = "Bombardiro Crocodilo",
		rarity = "Mythic",
		price = 6000,
		rate = 120,
		build = "Bombardiro",
	},
	{
		name = "Lirili Larila",
		rarity = "Secret",
		price = 20000,
		rate = 400,
		build = "Lirili",
	},
}

-- Mutations rolled when a character is bought.
-- name, income multiplier, chance.
Config.MUTATIONS = {
	{ name = "", mult = 1, chance = 0.87 },
	{ name = "Gold", mult = 2, chance = 0.10 },
	{ name = "Rainbow", mult = 5, chance = 0.03 },
}

-- Rebirth: needs this much total income per second, then resets cash
-- and owned characters for a permanent +25% income per rebirth.
Config.REBIRTH_INCOME_NEEDED = 100
Config.REBIRTH_BONUS = 0.25
Config.START_CASH = 100

-- Stealing.
Config.CARRY_SPEED = 10
Config.NORMAL_SPEED = 16
Config.SLAP_RANGE = 9
Config.SLAP_COOLDOWN = 3
Config.STEAL_COOLDOWN = 5

-- The Brainrot Wave: a warning, then a sweep across the lane.
Config.WAVE_PERIOD = 180
Config.WAVE_WARNING = 20
Config.WAVE_SWEEP_TIME = 10

function Config.rarityColor(rarityName)
	for _, r in ipairs(Config.RARITIES) do
		if r.name == rarityName then
			return r.color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

function Config.characterByName(name)
	for _, c in ipairs(Config.CHARACTERS) do
		if c.name == name then
			return c
		end
	end
	return nil
end

function Config.rollRarity()
	local total = 0
	for _, r in ipairs(Config.RARITIES) do
		total += r.weight
	end
	local roll = math.random(1, total)
	local running = 0
	for _, r in ipairs(Config.RARITIES) do
		running += r.weight
		if roll <= running then
			return r.name
		end
	end
	return "Common"
end

function Config.rollMutation()
	local roll = math.random()
	local running = 0
	for _, m in ipairs(Config.MUTATIONS) do
		running += m.chance
		if roll <= running then
			return m
		end
	end
	return Config.MUTATIONS[1]
end

function Config.characterOfRarity(rarityName)
	local pool = {}
	for _, c in ipairs(Config.CHARACTERS) do
		if c.rarity == rarityName then
			table.insert(pool, c)
		end
	end
	return pool[math.random(1, #pool)]
end

return Config
