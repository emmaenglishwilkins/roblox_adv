local config = {}

config.MinimumPlayersNeeded = 2

config.ExplodeTime = { --How long the tagged player has before they explode based on how many players are alive.
	[6] = 50,
	[5] = 40,
	[4] = 35,
	[3] = 30,
	[2] = 20
}

config.RunnerSpeed = 16
config.TaggedSpeed = 22

return config