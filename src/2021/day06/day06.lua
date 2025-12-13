--- @title: --- Day 6: Lanternfish ---
local M = {}

--- @description: Simulate lanternfish population for 80 days
--- @param input string: the puzzle input
--- @return number: the total number of lanternfish after 80 days
function M.part1(input)
	local counts = {}
	for i = 0, 8 do
		counts[i] = 0
	end
	for num in input:gmatch("%d+") do
		counts[tonumber(num)] = counts[tonumber(num)] + 1
	end
	for day = 1, 80 do
		local new = counts[0]
		for i = 0, 7 do
			counts[i] = counts[i + 1]
		end
		counts[8] = new
		counts[6] = counts[6] + new
	end
	local total = 0
	for i = 0, 8 do
		total = total + counts[i]
	end
	return total
end

--- @description: Simulate lanternfish population for 256 days
--- @param input string: the puzzle input
--- @return number: the total number of lanternfish after 256 days
function M.part2(input)
	local counts = {}
	for i = 0, 8 do
		counts[i] = 0
	end
	for num in input:gmatch("%d+") do
		counts[tonumber(num)] = counts[tonumber(num)] + 1
	end
	for _ = 1, 256 do
		local new = counts[0]
		for i = 0, 7 do
			counts[i] = counts[i + 1]
		end
		counts[8] = new
		counts[6] = counts[6] + new
	end
	local total = 0
	for i = 0, 8 do
		total = total + counts[i]
	end
	return total
end

return M
