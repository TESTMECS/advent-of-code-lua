--- @title: --- Day 1: Sonar Sweep ---
local M = {}

--- @description: Count the number of times a depth measurement increases from the previous measurement
--- @param input string: the puzzle input
--- @return number: the count of increases
function M.part1(input)
	local depths = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(depths, tonumber(line))
	end
	local count = 0
	for i = 2, #depths do
		if depths[i] > depths[i - 1] then
			count = count + 1
		end
	end
	return count
end

--- @description: Count the number of times the sum of measurements in this sliding window increases from the previous sum
--- @param input string: the puzzle input
--- @return number: the count of increases in sliding windows
function M.part2(input)
	local depths = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(depths, tonumber(line))
	end
	local windows = {}
	for i = 1, #depths - 2 do
		windows[i] = depths[i] + depths[i + 1] + depths[i + 2]
	end
	local count = 0
	for i = 2, #windows do
		if windows[i] > windows[i - 1] then
			count = count + 1
		end
	end
	return count
end

return M
