--- @title: --- Day 2: Cube Conundrum ---
local M = {}

--- @description: Sum IDs of possible games (red<=12, green<=13, blue<=14)
--- @param input string: the puzzle input
--- @return number: the sum of possible game IDs
function M.part1(input)
	local sum = 0
	local max_red, max_green, max_blue = 12, 13, 14
	for line in input:gmatch("[^\n]+") do
		local game_id = line:match("Game (%d+)")
		local game_part = line:match(": (.+)")
		local possible = true
		for set in game_part:gmatch("([^;]+)") do
			local red = tonumber(set:match("(%d+) red") or 0)
			local green = tonumber(set:match("(%d+) green") or 0)
			local blue = tonumber(set:match("(%d+) blue") or 0)
			if red > max_red or green > max_green or blue > max_blue then
				possible = false
				break
			end
		end
		if possible then
			sum = sum + tonumber(game_id)
		end
	end
	return sum
end

--- @description: Sum power of minimum sets for each game
--- @param input string: the puzzle input
--- @return number: the sum of powers
function M.part2(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local game_part = line:match(": (.+)")
		local min_red, min_green, min_blue = 0, 0, 0
		for set in game_part:gmatch("([^;]+)") do
			local red = tonumber(set:match("(%d+) red") or 0)
			local green = tonumber(set:match("(%d+) green") or 0)
			local blue = tonumber(set:match("(%d+) blue") or 0)
			min_red = math.max(min_red, red)
			min_green = math.max(min_green, green)
			min_blue = math.max(min_blue, blue)
		end
		sum = sum + min_red * min_green * min_blue
	end
	return sum
end

return M
