--- @title: Day 3: Toboggan Trajectory ---
local M = {}
local util = require("util")

--- @description Count trees hit with slope right 3, down 1
--- @param input string the puzzle input
--- @return number number of trees hit
function M.part1(input)
	local lines = util.read_lines(input)
	local height = #lines
	local width = #lines[1]
	local row = 1
	local col = 1
	local count = 0
	while row <= height do
		if lines[row]:sub(col, col) == "#" then
			count = count + 1
		end
		row = row + 1
		col = ((col - 1 + 3) % width) + 1
	end
	return count
end

--- @description Multiply tree counts for multiple slopes
--- @param input string the puzzle input
--- @return number product of tree counts
function M.part2(input)
	local lines = util.read_lines(input)
	local height = #lines
	local width = #lines[1]
	local function count_trees(right, down)
		local row = 1
		local col = 1
		local count = 0
		while row <= height do
			if lines[row]:sub(col, col) == "#" then
				count = count + 1
			end
			row = row + down
			col = ((col - 1 + right) % width) + 1
		end
		return count
	end
	local slopes = {
		{ 1, 1 },
		{ 3, 1 },
		{ 5, 1 },
		{ 7, 1 },
		{ 1, 2 },
	}
	local product = 1
	for _, slope in ipairs(slopes) do
		product = product * count_trees(slope[1], slope[2])
	end
	return product
end

return M
