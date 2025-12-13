--- @title: Day 18: Settlers of The North Pole ---
local M = {}

--- @function: Parses the input string into a 2D grid (table of tables).
--- @param input string: the puzzle input
--- @return table: the grid
local function parse_grid(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		if #line > 0 then
			local row = {}
			for i = 1, #line do
				table.insert(row, line:sub(i, i))
			end
			table.insert(grid, row)
		end
	end
	return grid
end

--- @function: Counts the number of adjacent trees and lumberyards for a given acre.
--- @param grid table: the grid
--- @param x number: the x coordinate
--- @param y number: the y coordinate
--- @param width number: the width of the grid
--- @param height number: the height of the grid
--- @return table: a table with the counts of trees and lumberyards
local function count_neighbors(grid, x, y, width, height)
	local counts = { trees = 0, lumberyards = 0 }
	for dy = -1, 1 do
		for dx = -1, 1 do
			if dx == 0 and dy == 0 then
				goto continue_loop
			end -- Skip self

			local nx, ny = x + dx, y + dy
			if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
				local neighbor = grid[ny][nx]
				if neighbor == "|" then
					counts.trees = counts.trees + 1
				elseif neighbor == "#" then
					counts.lumberyards = counts.lumberyards + 1
				end
			end
			::continue_loop::
		end
	end
	return counts
end

--- @function: Simulates the next step of the game.
--- @param grid table: the grid
--- @return table: the new grid
local function step(grid)
	local height = #grid
	local width = #grid[1]
	local new_grid = {}

	for y = 1, height do
		new_grid[y] = {}
		for x = 1, width do
			local current_acre = grid[y][x]
			local neighbors = count_neighbors(grid, x, y, width, height)
			local next_acre = current_acre

			if current_acre == "." then -- Open ground
				if neighbors.trees >= 3 then
					next_acre = "|"
				end
			elseif current_acre == "|" then -- Trees
				if neighbors.lumberyards >= 3 then
					next_acre = "#"
				end
			elseif current_acre == "#" then -- Lumberyard
				if neighbors.lumberyards >= 1 and neighbors.trees >= 1 then
					next_acre = "#"
				else
					next_acre = "."
				end
			end
			new_grid[y][x] = next_acre
		end
	end
	return new_grid
end

--- @function: Calculates the resource value of the grid.
--- @param grid table: the grid
--- @return number: the resource value
local function calculate_resource_value(grid)
	local tree_count = 0
	local lumberyard_count = 0
	for _, row in ipairs(grid) do
		for _, acre in ipairs(row) do
			if acre == "|" then
				tree_count = tree_count + 1
			elseif acre == "#" then
				lumberyard_count = lumberyard_count + 1
			end
		end
	end
	return tree_count * lumberyard_count
end

--- @function: Serializes a grid into a single string to use as a hash key.
--- @param grid table: the grid
--- @return string: the serialized grid
local function grid_to_string(grid)
	local parts = {}
	for _, row in ipairs(grid) do
		table.insert(parts, table.concat(row))
	end
	return table.concat(parts, "\n")
end

--- @description: Calculate the resource value after 10 minutes.
--- @param input string: the puzzle input
--- @return number: The total resource value.
function M.part1(input)
	local grid = parse_grid(input)
	for _ = 1, 10 do
		grid = step(grid)
	end
	return calculate_resource_value(grid)
end

--- @description: Calculate the resource value after 1,000,000,000 minutes by finding a cycle.
--- @param input string: the puzzle input
--- @return number: The total resource value.
function M.part2(input)
	local grid = parse_grid(input)
	local target_minutes = 1000000000

	local seen = {}
	local scores = {} -- Store scores by minute

	for minute = 0, target_minutes - 1 do
		local grid_str = grid_to_string(grid)

		if seen[grid_str] then
			-- Cycle detected!
			local start_of_cycle = seen[grid_str]
			local cycle_len = minute - start_of_cycle

			local remaining_minutes = target_minutes - minute
			local steps_into_cycle = remaining_minutes % cycle_len

			local final_minute_equivalent = start_of_cycle + steps_into_cycle
			return scores[final_minute_equivalent]
		end

		seen[grid_str] = minute
		scores[minute] = calculate_resource_value(grid)

		grid = step(grid)
	end

	-- This part should not be reached if a cycle is found, but is the fallback.
	return calculate_resource_value(grid)
end

return M
