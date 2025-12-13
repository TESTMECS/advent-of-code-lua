--- @title: Day 18: Like a Rogue ---
local M = {}

--- @function: Generates the next row based on the current row. A new tile is a trap ('^') if its left and right predecessors are different.
--- @param current_row string: The current row of tiles.
--- @return string: The next row of tiles.
local function generate_next_row(current_row)
	local next_row = {}
	local width = #current_row
	-- Pad the current row with safe tiles for easier edge handling.
	local padded_row = "." .. current_row .. "."

	for i = 1, width do
		local left = padded_row:sub(i, i)
		local right = padded_row:sub(i + 2, i + 2)

		if left ~= right then
			table.insert(next_row, "^") -- It's a trap
		else
			table.insert(next_row, ".") -- It's safe
		end
	end
	return table.concat(next_row)
end

--- @function: Counts the number of safe tiles in a given number of rows.
--- @param first_row string: The first row of tiles.
--- @param num_rows integer: The number of rows to count.
--- @return number: The total number of safe tiles.
local function count_safe_tiles(first_row, num_rows)
	local safe_count = 0
	local current_row = first_row

	for _ = 1, num_rows do
		-- Count safe tiles in the current row
		for i = 1, #current_row do
			if current_row:sub(i, i) == "." then
				safe_count = safe_count + 1
			end
		end
		-- Generate the next row for the next iteration
		current_row = generate_next_row(current_row)
	end

	return safe_count
end

--- @description Counts the number of safe tiles in 40 rows.
--- @param input string The first row of the map.
--- @return number The total number of safe tiles.
function M.part1(input)
	local first_row = input:match("%S+")
	return count_safe_tiles(first_row, 40)
end

--- @description Counts the number of safe tiles in 400000 rows.
--- @param input string The first row of the map.
--- @return number The total number of safe tiles.
function M.part2(input)
	local first_row = input:match("%S+")
	return count_safe_tiles(first_row, 400000)
end

return M
