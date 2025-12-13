--- @title: Day 9: Encoding Error ---
local M = {}
local util = require("util")

--- @description: Find the first invalid number
--- @param input string: the puzzle input
--- @return number: the invalid number
function M.part1(input)
	local lines = util.read_lines(input)
	local numbers = {}
	for _, line in ipairs(lines) do
		table.insert(numbers, tonumber(line))
	end
	local preamble = 25
	for i = preamble + 1, #numbers do
		local num = numbers[i]
		local valid = false
		for j = i - preamble, i - 1 do
			for k = j + 1, i - 1 do
				if numbers[j] + numbers[k] == num then
					valid = true
					break
				end
			end
			if valid then
				break
			end
		end
		if not valid then
			return num
		end
	end
	return 0
end

--- @description: Find the sum of min and max in contiguous set summing to invalid
--- @param input string: the puzzle input
--- @return number: the sum
function M.part2(input)
	local lines = util.read_lines(input)
	local numbers = {}
	for _, line in ipairs(lines) do
		table.insert(numbers, tonumber(line))
	end
	local invalid = M.part1(input)
	for start = 1, #numbers do
		local sum = 0
		local minv = math.huge
		local maxv = -math.huge
		for endi = start, #numbers do
			sum = sum + numbers[endi]
			minv = math.min(minv, numbers[endi])
			maxv = math.max(maxv, numbers[endi])
			if sum == invalid then
				return minv + maxv
			elseif sum > invalid then
				break
			end
		end
	end
	return 0
end

return M
