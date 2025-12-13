--- @title: Day 10: Adapter Array ---
local M = {}
local util = require("util")

--- @description: Multiply differences of 1 and 3 jolts
--- @param input string: the puzzle input
--- @return number: the product
function M.part1(input)
	local adapters = {}
	for _, line in ipairs(util.read_lines(input)) do
		table.insert(adapters, tonumber(line))
	end
	table.sort(adapters)
	local jolts = { 0 }
	for _, a in ipairs(adapters) do
		table.insert(jolts, a)
	end
	table.insert(jolts, jolts[#jolts] + 3)
	local diff1, diff3 = 0, 0
	for i = 2, #jolts do
		local d = jolts[i] - jolts[i - 1]
		if d == 1 then
			diff1 = diff1 + 1
		elseif d == 3 then
			diff3 = diff3 + 1
		end
	end
	return diff1 * diff3
end

--- @description: Count ways to arrange adapters
--- @param input string: the puzzle input
--- @return number: the number of ways
function M.part2(input)
	local adapters = {}
	for _, line in ipairs(util.read_lines(input)) do
		table.insert(adapters, tonumber(line))
	end
	table.sort(adapters)
	local jolts = { 0 }
	for _, a in ipairs(adapters) do
		table.insert(jolts, a)
	end
	table.insert(jolts, jolts[#jolts] + 3)
	local ways = {}
	ways[1] = 1
	for i = 2, #jolts do
		ways[i] = 0
		for j = i - 1, 1, -1 do
			if jolts[i] - jolts[j] <= 3 then
				ways[i] = ways[i] + ways[j]
			else
				break
			end
		end
	end
	return ways[#jolts]
end

return M
