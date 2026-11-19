-- Brainrot Rush 3D: client HUD and alerts.
-- The server owns every number; this script only shows them, fires
-- the player's own actions, and warns about the wave and steals.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHud"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Top bar: cash, income, rebirths.
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.new(0.5, 0, 0, 8)
topBar.Size = UDim2.new(0, 520, 0, 44)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BackgroundTransparency = 0.25
topBar.BorderSizePixel = 0
topBar.Parent = gui

local function topLabel(name, x, text, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = UDim2.new(0, x, 0, 0)
	label.Size = UDim2.new(0, 160, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = 20
	label.Font = Enum.Font.FredokaOne
	label.Parent = topBar
	return label
end

local cashLabel = topLabel("Cash", 8, "Cash: $100", Color3.fromRGB(120, 255, 120))
local incomeLabel = topLabel("Income", 180, "Income: $0/s", Color3.fromRGB(255, 220, 90))
local rebirthLabel = topLabel("Rebirths", 352, "Rebirths: 0", Color3.fromRGB(255, 150, 220))

-- Rebirth button, bottom right.
local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.AnchorPoint = Vector2.new(1, 1)
rebirthButton.Position = UDim2.new(1, -16, 1, -16)
rebirthButton.Size = UDim2.new(0, 190, 0, 48)
rebirthButton.BackgroundColor3 = Color3.fromRGB(170, 80, 255)
rebirthButton.Text = "REBIRTH (+25% income)"
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 16
rebirthButton.Font = Enum.Font.FredokaOne
rebirthButton.Parent = gui
rebirthButton.MouseButton1Click:Connect(function()
	remotes.Rebirth:FireServer()
end)

-- Alert line, centre top under the bar.
local alertLabel = Instance.new("TextLabel")
alertLabel.Name = "Alert"
alertLabel.AnchorPoint = Vector2.new(0.5, 0)
alertLabel.Position = UDim2.new(0.5, 0, 0, 60)
alertLabel.Size = UDim2.new(0, 640, 0, 30)
alertLabel.BackgroundTransparency = 1
alertLabel.Text = "Click a brainrot on the conveyor to buy it. Click one on another base to steal it!"
alertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
alertLabel.TextSize = 17
alertLabel.Font = Enum.Font.FredokaOne
alertLabel.Parent = gui

-- Wave warning banner, hidden until the wave is coming.
local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "WaveWarning"
waveLabel.AnchorPoint = Vector2.new(0.5, 0)
waveLabel.Position = UDim2.new(0.5, 0, 0, 100)
waveLabel.Size = UDim2.new(0, 640, 0, 44)
waveLabel.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
waveLabel.BackgroundTransparency = 0.2
waveLabel.Text = ""
waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
waveLabel.TextSize = 24
waveLabel.Font = Enum.Font.FredokaOne
waveLabel.Visible = false
waveLabel.Parent = gui

local function formatCash(amount)
	local n = math.floor(amount)
	local text = tostring(n)
	local out = ""
	while #text > 3 do
		out = "," .. text:sub(-3) .. out
		text = text:sub(1, -4)
	end
	return "$" .. text .. out
end

local function bindStats()
	local stats = player:WaitForChild("leaderstats")
	local cash = stats:WaitForChild("Cash")
	local income = stats:WaitForChild("Income")
	local rebirths = stats:WaitForChild("Rebirths")
	local function refresh()
		cashLabel.Text = "Cash: " .. formatCash(cash.Value)
		incomeLabel.Text = "Income: " .. formatCash(income.Value) .. "/s"
		rebirthLabel.Text = "Rebirths: " .. rebirths.Value
	end
	cash.Changed:Connect(refresh)
	income.Changed:Connect(refresh)
	rebirths.Changed:Connect(refresh)
	refresh()
end

local alertUntil = 0
remotes.Notify.OnClientEvent:Connect(function(text)
	alertLabel.Text = text
	alertUntil = os.clock() + 6
end)

-- Generation guard: every warning bumps the token, and only the
-- loop holding the newest token keeps writing the banner. Two
-- warnings in a row can never spawn two fighting countdown loops.
local waveGeneration = 0
remotes.WaveWarning.OnClientEvent:Connect(function(secondsLeft)
	waveGeneration += 1
	local myGeneration = waveGeneration
	waveLabel.Visible = true
	for left = secondsLeft, 1, -1 do
		if myGeneration ~= waveGeneration then
			return
		end
		waveLabel.Text = "BRAINROT WAVE IN " .. left .. "s - GET TO YOUR BASE!"
		task.wait(1)
	end
	if myGeneration ~= waveGeneration then
		return
	end
	waveLabel.Text = "THE WAVE IS HERE!"
	task.wait(3)
	if myGeneration == waveGeneration then
		waveLabel.Visible = false
	end
end)

-- The help line fades back after an alert has been on screen a while.
task.spawn(function()
	while true do
		task.wait(1)
		if alertUntil > 0 and os.clock() > alertUntil then
			alertLabel.Text = "Click a brainrot on the conveyor to buy it. Click one on another base to steal it!"
			alertUntil = 0
		end
	end
end)

bindStats()
