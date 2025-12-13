--- @title: Day 25: Combo Breaker ---
local M = {}
local util = require("util")

--- @description: Find encryption key
--- @param input string: the puzzle input
--- @return number: the key
function M.part1(input)
	local lines = util.read_lines(input)
	local card = tonumber(lines[1])
	local door = tonumber(lines[2])
	local mod = 20201227
	local function find_loop(pub)
		local val = 1
		local loop = 0
		while val ~= pub do
			val = val * 7 % mod
			loop = loop + 1
		end
		return loop
	end
	local card_loop = find_loop(card)
	local val = 1
	for _ = 1, card_loop do
		val = val * door % mod
	end
	return val
end

--- @description: Done
--- @return string:
function M.part2(_)
	return "press that button"
end

return M
