--- @title: --- Day 6: Wait For It ---
local M = {}
local util = require("util")

--- @description: Product of ways to win each race
--- @param input string: the puzzle input
--- @return number: the product
function M.part1(input)
	local lines = util.read_lines(input)
	local times = util.parse_nums(lines[1])
	local dists = util.parse_nums(lines[2])
	local product = 1
	for i, T in ipairs(times) do
		local D = dists[i]
		local disc = T * T - 4 * D
		if disc > 0 then
			local sqrt = math.sqrt(disc)
			local t1 = (T - sqrt) / 2
			local t2 = (T + sqrt) / 2
			local min_t = math.ceil(t1 + 1e-9)
			local max_t = math.floor(t2 - 1e-9)
			local ways = max_t - min_t + 1
			if ways > 0 then
				product = product * ways
			end
		end
	end
	return product
end

--- @description: Ways to win the single race
--- @param input string: the puzzle input
--- @return number: the number of ways
function M.part2(input)
	local lines = util.read_lines(input)
	local T_str = lines[1]:gsub("Time:", ""):gsub(" ", "")
	local D_str = lines[2]:gsub("Distance:", ""):gsub(" ", "")
	local T = tonumber(T_str)
	local D = tonumber(D_str)
	local disc = T * T - 4 * D
	local sqrt = math.sqrt(disc)
	local t1 = (T - sqrt) / 2
	local t2 = (T + sqrt) / 2
	local min_t = math.ceil(t1 + 1e-9)
	local max_t = math.floor(t2 - 1e-9)
	return max_t - min_t + 1
end

return M
