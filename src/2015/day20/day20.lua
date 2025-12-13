--- @title: Day 20: Infinite Elves and Infinite Houses ---
local M = {}
local util = require("util")

--- @description: Find the house with the highest number of elves
--- @param input string
--- @return number
function M.part1(input)
	local target = tonumber(util.trim(input))
	local max_h = 2000000
	local houses = {}
	for i = 1, max_h do
		houses[i] = 0
	end
	for d = 1, max_h do
		for k = d, max_h, d do
			houses[k] = houses[k] + 10 * d
		end
	end
	for h = 1, max_h do
		if houses[h] >= target then
			return h
		end
	end
	return -1
end

--- @description: Find the house with the highest number of elves
--- @param input string
--- @return number
function M.part2(input)
	local target = tonumber(util.trim(input))
	local max_h = 2000000
	local houses = {}
	for i = 1, max_h do
		houses[i] = 0
	end
	for d = 1, max_h do
		local count = 0
		for k = d, max_h, d do
			houses[k] = houses[k] + 11 * d
			count = count + 1
			if count >= 50 then
				break
			end
		end
	end
	for h = 1, max_h do
		if houses[h] >= target then
			return h
		end
	end
	return -1
end

return M
