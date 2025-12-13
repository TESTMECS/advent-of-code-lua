--- @title: Day 1: Inverse Captcha ---
local M = {}

--- @description: Count consecutive digits that match the previous
--- @param input string: of digits
--- @return number sum: of matching digits
function M.part1(input)
	input = input:gsub("%s+", "")
	local sum = 0
	local len = #input
	for i = 1, len do
		local current = input:sub(i, i)
		local next_digit = (i == len) and input:sub(1, 1) or input:sub(i + 1, i + 1)
		if current == next_digit then
			sum = sum + tonumber(current)
		end
	end
	return sum
end

--- @description: Count the number of digits that match the middle digit
--- @param input string:  of digits
--- @return number: sum of matching digits
function M.part2(input)
	input = input:gsub("%s+", "")
	local sum = 0
	local len = #input
	local half = len // 2
	for i = 1, len do
		local current = input:sub(i, i)
		local halfway_index = (i + half - 1) % len + 1
		local halfway_digit = input:sub(halfway_index, halfway_index)
		if current == halfway_digit then
			sum = sum + tonumber(current)
		end
	end
	return sum
end

return M
