--- @title: Day 4: Secure Container ---
local M = {}
local util = require("util")

--- @function: checks if a string is strictly non-decreasing digitst ie 1234
--- @param s string
--- @return boolean
local function is_non_decreasing(s)
	local prev = nil
	for d in s:gmatch("%d") do
		local n = tonumber(d)
		if prev and n < prev then
			return false
		end
		prev = n
	end
	return true
end

--- @function: checks if a number is valid
--- @param num number
--- @return boolean
local function check_rules(num)
	local flag1 = #tostring(num) == 6
	local flag2 = tostring(num):match("(%d)%1") ~= nil
	local flag3 = is_non_decreasing(tostring(num))
	if flag1 and flag2 and flag3 then
		return true
	end
	return false
end

--- @function: checks if a number is valid
--- @param num number
--- @return boolean
local function check_rules_part2(num)
	local s = tostring(num)
	local flag1 = #s == 6
	local freq = {}
	if not s then
		return false
	end
	for d in s:gmatch("%d") do
		freq[d] = (freq[d] or 0) + 1
	end
	local flag2 = false
	for _, count in pairs(freq) do
		if count == 2 then
			flag2 = true
			break
		end
	end
	local flag3 = is_non_decreasing(s)
	return flag1 and flag2 and flag3
end

--- @function: iterate over a range
--- @param s string
--- @return function
local function iter_range(s)
	s = util.trim(s)
	local a, b = s:match("^(%d+)%-(%d+)$")
	a, b = tonumber(a), tonumber(b)
	return function(_, last)
		local next = (last or a - 1) + 1
		if next <= b then
			return next
		end
	end
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local count = 0
	for i in iter_range(input) do
		if check_rules(i) then
			count = count + 1
		end
	end
	return count
end

--- @description Count valid passwords with exactly two of any digit the same
--- @param input string the puzzle input
--- @return number the count of valid passwords
function M.part2(input)
	local count = 0
	for i in iter_range(input) do
		if check_rules_part2(i) then
			count = count + 1
		end
	end
	return count
end

return M
