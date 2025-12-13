--- @title: Day 24: Planet of Discord ---
local M = {}

--- @function: Parses the input into a 2D grid table.
--- @param input string: The input string.
--- @return table: The 2D grid table.
local function parse_grid(input)
	local grid = {}
	for line in input:gmatch("[^\r\n]+") do
		local row = {}
		for char in line:gmatch(".") do
			table.insert(row, char)
		end
		table.insert(grid, row)
	end
	return grid
end

--- @function: Serializes a grid into a single string for use as a hash key.
--- @param grid table: The 2D grid table.
--- @return string: The serialized grid string.
local function grid_to_string(grid)
	local parts = {}
	for _, row in ipairs(grid) do
		table.insert(parts, table.concat(row))
	end
	return table.concat(parts)
end

--- @function: Calculates the biodiversity rating of a grid.
--- @param grid table: The 2D grid table.
--- @return number: The biodiversity rating.
local function calculate_biodiversity(grid)
	local rating, power = 0, 1
	for y = 1, 5 do
		for x = 1, 5 do
			if grid[y][x] == "#" then
				rating = rating + power
			end
			power = power * 2
		end
	end
	return rating
end

--- @description Find the biodiversity rating of the first layout that appears twice.
--- @param input string: The input string.
--- @return number: The answer to part 1.
function M.part1(input)
	local grid = parse_grid(input)
	local seen = {}

	while true do
		local state_str = grid_to_string(grid)
		if seen[state_str] then
			return calculate_biodiversity(grid)
		end
		seen[state_str] = true

		local next_grid = {}
		for y = 1, 5 do
			next_grid[y] = {}
			for x = 1, 5 do
				local neighbors = 0
				for _, d in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
					local nx, ny = x + d[1], y + d[2]
					if nx >= 1 and nx <= 5 and ny >= 1 and ny <= 5 and grid[ny][nx] == "#" then
						neighbors = neighbors + 1
					end
				end

				if grid[y][x] == "#" then
					next_grid[y][x] = (neighbors == 1) and "#" or "."
				else
					next_grid[y][x] = (neighbors == 1 or neighbors == 2) and "#" or "."
				end
			end
		end
		grid = next_grid
	end
end

--- @description Count the total number of bugs after 200 minutes in a recursive space.
function M.part2(input)
	local initial_grid = parse_grid(input)
	local levels = { [0] = initial_grid }
	local min_level, max_level = 0, 0

	local function count_neighbors_recursive(level, x, y)
		local count = 0
		local outer_grid = levels[level - 1]
		local inner_grid = levels[level + 1]

		for _, d in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
			local nx, ny = x + d[1], y + d[2]

			if nx == 3 and ny == 3 then -- Moving into the center
				if inner_grid then
					if x == 2 then
						for i = 1, 5 do
							if inner_grid[i][1] == "#" then
								count = count + 1
							end
						end -- From left
					elseif x == 4 then
						for i = 1, 5 do
							if inner_grid[i][5] == "#" then
								count = count + 1
							end
						end -- From right
					elseif y == 2 then
						for i = 1, 5 do
							if inner_grid[1][i] == "#" then
								count = count + 1
							end
						end -- From top
					elseif y == 4 then
						for i = 1, 5 do
							if inner_grid[5][i] == "#" then
								count = count + 1
							end
						end -- From bottom
					end
				end
			elseif nx < 1 or nx > 5 or ny < 1 or ny > 5 then -- Moving off an edge
				if outer_grid then
					if nx < 1 and outer_grid[3][2] == "#" then
						count = count + 1
					elseif nx > 5 and outer_grid[3][4] == "#" then
						count = count + 1
					elseif ny < 1 and outer_grid[2][3] == "#" then
						count = count + 1
					elseif ny > 5 and outer_grid[4][3] == "#" then
						count = count + 1
					end
				end
			else -- Normal adjacent tile
				if levels[level] and levels[level][ny][nx] == "#" then
					count = count + 1
				end
			end
		end
		return count
	end

	for _ = 1, 200 do
		local next_levels = {}
		-- Expand simulation space if needed
		min_level, max_level = min_level - 1, max_level + 1

		for level_idx = min_level, max_level do
			local new_grid = {}
			for y = 1, 5 do
				new_grid[y] = {}
				for x = 1, 5 do
					if x == 3 and y == 3 then
						new_grid[y][x] = "."
					else
						local neighbors = count_neighbors_recursive(level_idx, x, y)
						local current_char = (levels[level_idx] and levels[level_idx][y][x]) or "."

						if current_char == "#" then
							new_grid[y][x] = (neighbors == 1) and "#" or "."
						else
							new_grid[y][x] = (neighbors == 1 or neighbors == 2) and "#" or "."
						end
					end
				end
			end
			next_levels[level_idx] = new_grid
		end
		levels = next_levels
	end

	local total_bugs = 0
	for _, grid in pairs(levels) do
		for y = 1, 5 do
			for x = 1, 5 do
				if grid[y][x] == "#" then
					total_bugs = total_bugs + 1
				end
			end
		end
	end
	return total_bugs
end

return M
