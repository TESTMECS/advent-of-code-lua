--- @title: Day 2: Password Philosophy ---
local M = {}
local util = require("util")

--- @description Count valid passwords where the character count is within the range
--- @param input string the puzzle input
--- @return number number of valid passwords
function M.part1(input)
	local lines = util.read_lines(input)
	local count = 0
	for _, line in ipairs(lines) do
		local min, max, char, password = line:match("(%d+)-(%d+) (%w+): (%w+)")
		min = tonumber(min)
		max = tonumber(max)
		local freq = util.count_char_freq(password)
		local count_char = freq[char] or 0
		if count_char >= min and count_char <= max then
			count = count + 1
		end
	end
	return count
end

--- @description Count valid passwords where exactly one of the two positions contains the character
--- @param input string the puzzle input
--- @return number number of valid passwords
function M.part2(input)
	local lines = util.read_lines(input)
	local count = 0
	for _, line in ipairs(lines) do
		local pos1, pos2, char, password = line:match("(%d+)-(%d+) (%w+): (%w+)")
		pos1 = tonumber(pos1)
		pos2 = tonumber(pos2)
		local char1 = password:sub(pos1, pos1)
		local char2 = password:sub(pos2, pos2)
		local match1 = (char1 == char)
		local match2 = (char2 == char)
		if match1 ~= match2 then
			count = count + 1
		end
	end
	return count
end

return M
