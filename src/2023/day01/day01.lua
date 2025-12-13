--- @title: --- Day 1: Trebuchet?! ---
local M = {}
local util = require("util")

local digits = {
	["one"] = 1,
	["two"] = 2,
	["three"] = 3,
	["four"] = 4,
	["five"] = 5,
	["six"] = 6,
	["seven"] = 7,
	["eight"] = 8,
	["nine"] = 9,
}

local function get_digit(s, i)
	local c = s:sub(i, i)
	if c:match("%d") then
		return tonumber(c)
	end
	for word, num in pairs(digits) do
		if s:sub(i, i + #word - 1) == word then
			return num
		end
	end
	return nil
end

--- @description: Sum calibration values from first and last digit in each line
--- @param input string: the puzzle input
--- @return number: the sum of calibration values
function M.part1(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local first = line:match("(%d)")
		local last = line:match(".*(%d)")
		if first and last then
			sum = sum + tonumber(first .. last)
		end
	end
	return sum
end

--- @description: Sum calibration values considering spelled-out digits
--- @param input string: the puzzle input
--- @return number: the sum of calibration values
function M.part2(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local first, last
		for i = 1, #line do
			if not first then
				first = get_digit(line, i)
			end
			local d = get_digit(line, i)
			if d then
				last = d
			end
		end
		if first and last then
			sum = sum + first * 10 + last
		end
	end
	return sum
end

return M
