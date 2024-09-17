local config = {}

-- the game cannot start with only one player
config.MinimumPlayersNeeded = 2

-- number of seconds the game will go on for 
config.ExplodeTime = {
	[6] = 50,
	[5] = 40,
	[4] = 35,
	[3] = 30,
	[2] = 20,
}

config.RunnerSpeed = 16 -- 16 is the speed for roblox character
config.TaggedSpeed = 22

return config
