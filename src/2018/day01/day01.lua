--- @title: Day 1: Chronal Calibration ---
local M = {}
local lpeg = require("lpeg")
local P, R, S, C, Ct = lpeg.P, lpeg.R, lpeg.S, lpeg.C, lpeg.Ct
local digit = R("09") ^ 1
local sign = S("+-") ^ -1
local number = C(sign * digit) / tonumber

local newline = P("\r") ^ -1 * P("\n")
local line = number * (newline + -1) -- number followed by newline or end
local grammar = Ct(line ^ 1)

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local nums = grammar:match(input)
	local sum = 0
	for _, n in ipairs(nums) do
		sum = sum + n
	end
	return sum
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local nums = grammar:match(input)

	local seen = { [0] = true }
	local freq = 0

	local i = 1
	while true do
		freq = freq + nums[i]

		if seen[freq] then
			return freq
		end

		seen[freq] = true
		i = i + 1
		if i > #nums then
			i = 1 -- wrap around, repeat list
		end
	end
end

return M
