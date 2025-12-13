--- @title: --- Day 2: Dive! ---
local M = {}

--- @description: Calculate the final position after following the planned course
--- @param input string: the puzzle input
--- @return number: the product of horizontal position and depth
function M.part1(input)
	local horizontal = 0
	local depth = 0
	for line in input:gmatch("[^\n]+") do
		local dir, num = line:match("(%w+) (%d+)")
		num = tonumber(num)
		if dir == "forward" then
			horizontal = horizontal + num
		elseif dir == "down" then
			depth = depth + num
		elseif dir == "up" then
			depth = depth - num
		end
	end
	return horizontal * depth
end

--- @description: Calculate the final position using the new interpretation of the commands
--- @param input string: the puzzle input
--- @return number: the product of horizontal position and depth
function M.part2(input)
	local horizontal = 0
	local depth = 0
	local aim = 0
	for line in input:gmatch("[^\n]+") do
		local dir, num = line:match("(%w+) (%d+)")
		num = tonumber(num)
		if dir == "forward" then
			horizontal = horizontal + num
			depth = depth + aim * num
		elseif dir == "down" then
			aim = aim + num
		elseif dir == "up" then
			aim = aim - num
		end
	end
	return horizontal * depth
end

return M
