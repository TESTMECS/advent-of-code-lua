--- @title: Day 5: Binary Boarding ---
local M = {}

local util = require("util")

--- @description Calculates a seat ID from a boarding pass code using binary conversion.
--- @param pass_code string The 10-character code (e.g., "FBFBBFFRLR").
--- @return number The calculated seat ID.
local function get_seat_id(pass_code)
	-- Replace the letters with their binary equivalents.
	-- F, L -> 0
	-- B, R -> 1
	local binary_str = pass_code:gsub("F", "0"):gsub("B", "1"):gsub("L", "0"):gsub("R", "1")

	-- The first 7 characters are the row, the last 3 are the column.
	local row_binary = binary_str:sub(1, 7)
	local col_binary = binary_str:sub(8, 10)

	-- tonumber() with a second argument of 2 interprets the string as base-2 (binary).
	local row = tonumber(row_binary, 2)
	local col = tonumber(col_binary, 2)

	return row * 8 + col
end

--- @description Find the highest seat ID
--- @param input string the puzzle input
--- @return number the highest seat ID
function M.part1(input)
	local lines = util.read_lines(input)
	local max_id = 0
	for _, line in ipairs(lines) do
		-- A slightly more concise way to find the max. Your `if` statement is also perfectly fine.
		max_id = math.max(max_id, get_seat_id(line))
	end
	return max_id
end

--- @description Find the missing seat ID
--- @param input string the puzzle input
--- @return number the missing seat ID
function M.part2(input)
	local lines = util.read_lines(input)
	local seats = {}

	-- Collect all seat IDs into a set (a table with boolean flags).
	for _, line in ipairs(lines) do
		local id = get_seat_id(line)
		seats[id] = true
	end

	-- Iterate through all possible IDs.
	-- The problem implies the flight isn't full at the very front or back,
	-- so we don't need to worry about edge cases like ID 0 or the max ID.
	-- We are looking for a gap where our seat (id) is missing, but the
	-- seats next to it (id-1 and id+1) exist.
	for id = 1, 127 * 8 + 7 do
		if not seats[id] and seats[id - 1] and seats[id + 1] then
			return id
		end
	end

	return -1 -- Should not be reached if input is valid
end

return M
