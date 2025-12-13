--- @title: Day 2: Inventory Management System ---
local M = {}
local util = require("util")

--- @description: Calculates the checksum by counting IDs with exactly two or three of any letter
--- @param input string: the puzzle input
--- @return number: the checksum
function M.part1(input)
	local lines = util.read_lines(input)
	local twicer = 0
	local threer = 0
	for i = 1, #lines do
		local line = lines[i]
		local counts = util.count_char_freq(line)
		local has_two = false
		local has_three = false
		for _, count in pairs(counts) do
			if count == 2 then
				has_two = true
			elseif count == 3 then
				has_three = true
			end
		end
		if has_two then
			twicer = twicer + 1
		end
		if has_three then
			threer = threer + 1
		end
	end
	return twicer * threer
end

--- @description: Finds the common letters between two IDs that differ by exactly one character
--- @param input string: the puzzle input
--- @return string: the common letters
function M.part2(input)
	local lines = util.read_lines(input)
	for i = 1, #lines do
		for j = i + 1, #lines do
			local id1 = lines[i]
			local id2 = lines[j]
			local diff_count = 0
			local diff_pos = 0
			for k = 1, #id1 do
				if id1:sub(k, k) ~= id2:sub(k, k) then
					diff_count = diff_count + 1
					diff_pos = k
				end
			end
			if diff_count == 1 then
				return id1:sub(1, diff_pos - 1) .. id1:sub(diff_pos + 1)
			end
		end
	end
	return ""
end

return M
