--- @title: --- Day 1: Calorie Counting ---
local M = {}

--- @description:
--- @param input string:
--- @return number:
function M.part1(input)
	local max_sum = 0
	local current_sum = 0
	for line in (input .. "\n"):gmatch("([^\n]*)\n") do
		if line == "" then
			-- end of a group
			if current_sum > max_sum then
				max_sum = current_sum
			end
			current_sum = 0
		else
			current_sum = current_sum + tonumber(line)
		end
	end
	return max_sum
end

--- @description: Find the sum of the top three elves' calorie counts
--- @param input string the puzzle input
--- @return number: the sum of the top three calorie counts
function M.part2(input)
	local sums = {}
	local current_sum = 0
	for line in (input .. "\n"):gmatch("([^\n]*)\n") do
		if line == "" then
			table.insert(sums, current_sum)
			current_sum = 0
		else
			current_sum = current_sum + tonumber(line)
		end
	end
	table.sort(sums, function(a, b)
		return a > b
	end)
	return sums[1] + sums[2] + sums[3]
end

return M
