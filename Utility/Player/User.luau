local function fromId(id: number): User
	return User.fromId(id)
end

local function fromString(userString: string): User
	return User.fromString(userString)
end

local function fromPlayer(player: Player)
	return player.User
end

return {
	fromId = fromId,
	fromString = fromString,
	fromPlayer = fromPlayer,
}