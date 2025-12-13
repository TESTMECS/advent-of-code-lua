--- @title: --- Day 6: Tuning Trouble ---
local M = {}

local function all_unique(s, start, n)
	local set = {}
	for i = start, start + n - 1 do
		local c = s:sub(i, i)
		if set[c] then return false end
		set[c] = true
	end
	return true
end

local function find_marker(input, n)
	for i = n, #input do
		if all_unique(input, i - n + 1, n) then
			return i
		end
	end
	return 0
end

--- @description: Find the start of the first packet marker (4 unique chars)
--- @param input string the puzzle input
--- @return number: the position
function M.part1(input)
	return find_marker(input, 4)
end

--- @description: Find the start of the first message marker (14 unique chars)
--- @param input string the puzzle input
--- @return number: the position
function M.part2(input)
	return find_marker(input, 14)
end

return M
