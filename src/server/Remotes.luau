-- Brainrot Rush 3D: the RemoteEvents the client and server use.
-- All gameplay actions go through these; the server validates every
-- one, so the client can never grant itself cash or a character.

local Remotes = {}

function Remotes.create()
	local storage = game:GetService("ReplicatedStorage")
	local folder = Instance.new("Folder")
	folder.Name = "BrainrotRemotes"
	folder.Parent = storage

	local names = {
		"BuyCharacter",
		"StealCharacter",
		"Slap",
		"Rebirth",
		"Notify",
		"WaveWarning",
	}
	local out = {}
	for _, name in ipairs(names) do
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = folder
		out[name] = event
	end
	return out
end

return Remotes
