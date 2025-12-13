--- @title: Day 17: Reservoir Research ---
local M = {}

--- @function: A helper to parse the input and set up the grid
--- @param input string
--- @return table, table
local function parse_and_setup_grid(input)
	local grid = {}
	local clay_veins = {}

	local min_x, max_x = math.huge, -math.huge
	local min_y, max_y = math.huge, -math.huge

	-- First pass: parse and find boundaries
	for line in input:gmatch("[^\n]+") do
		local axis1, val1, _, range_start, range_end = line:match("([xy])=(%d+), ([xy])=(%d+)%.%.(%d+)")
		val1, range_start, range_end = tonumber(val1), tonumber(range_start), tonumber(range_end)

		local vein = {}
		if axis1 == "x" then
			vein = { x1 = val1, x2 = val1, y1 = range_start, y2 = range_end }
			min_x = math.min(min_x, val1)
			max_x = math.max(max_x, val1)
			min_y = math.min(min_y, range_start)
			max_y = math.max(max_y, range_end)
		else
			vein = { y1 = val1, y2 = val1, x1 = range_start, x2 = range_end }
			min_y = math.min(min_y, val1)
			max_y = math.max(max_y, val1)
			min_x = math.min(min_x, range_start)
			max_x = math.max(max_x, range_end)
		end
		table.insert(clay_veins, vein)
	end

	-- Pad x-range for water to flow around the edges
	min_x = min_x - 1
	max_x = max_x + 1

	-- Second pass: create grid and populate clay
	for y = 0, max_y do
		grid[y] = {}
		for x = min_x, max_x do
			grid[y][x] = "."
		end
	end

	for _, vein in ipairs(clay_veins) do
		for y = vein.y1, vein.y2 do
			for x = vein.x1, vein.x2 do
				grid[y][x] = "#"
			end
		end
	end

	return grid, min_x, max_x, min_y, max_y
end

--- @function: The main simulation function
--- @param grid table
--- @param max_y number
--- @return table
local function run_simulation(grid, _, _, _, max_y)
	local stack = { { x = 500, y = 0 } }

	local function is_solid(x, y)
		if not grid[y] then
			return false
		end
		local tile = grid[y][x]
		return tile == "#" or tile == "~"
	end

	while #stack > 0 do
		local source = table.remove(stack)
		local x, y = source.x, source.y

		-- 1. Fall down
		while y + 1 <= max_y and grid[y + 1][x] == "." do
			y = y + 1
			grid[y][x] = "|"
		end

		-- If we fell off the map or hit flowing water, this stream is done
		if y + 1 > max_y or grid[y + 1][x] == "|" then
			goto continue_loop
		end

		-- 2. Spread and fill upwards
		while true do
			local left_wall, right_wall = false, false
			local left_x, right_x = x, x

			-- Spread left
			while true do
				if is_solid(left_x - 1, y) then
					left_wall = true
					break
				end
				left_x = left_x - 1
				if not is_solid(left_x, y + 1) then
					break -- Found a ledge
				end
			end

			-- Spread right
			while true do
				if is_solid(right_x + 1, y) then
					right_wall = true
					break
				end
				right_x = right_x + 1
				if not is_solid(right_x, y + 1) then
					break -- Found a ledge
				end
			end

			local fill_char = (left_wall and right_wall) and "~" or "|"
			for fx = left_x, right_x do
				grid[y][fx] = fill_char
			end

			if fill_char == "|" then
				-- If we didn't find a left wall, the ledge is a new source
				if not left_wall then
					table.insert(stack, { x = left_x, y = y })
				end
				-- If we didn't find a right wall, the ledge is a new source
				if not right_wall then
					table.insert(stack, { x = right_x, y = y })
				end
				break -- Stop filling upwards
			end

			-- If we settled, move up one level and repeat
			y = y - 1
			if y < 0 then
				break
			end
		end

		::continue_loop::
	end

	return grid
end

--- @description Counts how many tiles the water can reach, including flowing and settled water.
--- @param input string the puzzle input
--- @return number The total number of reachable water tiles.
function M.part1(input)
	local grid, min_x, max_x, min_y, max_y = parse_and_setup_grid(input)
	grid = run_simulation(grid, min_x, max_x, min_y, max_y)

	local water_count = 0
	for y = min_y, max_y do
		for x = min_x, max_x do
			local tile = grid[y][x]
			if tile == "~" or tile == "|" then
				water_count = water_count + 1
			end
		end
	end

	return water_count
end

--- @description Counts how many tiles of water will be retained as settled water at rest.
--- @param input string the puzzle input
--- @return number The number of settled water tiles.
function M.part2(input)
	local grid, min_x, max_x, min_y, max_y = parse_and_setup_grid(input)
	grid = run_simulation(grid, min_x, max_x, min_y, max_y)

	local settled_water_count = 0
	for y = min_y, max_y do
		for x = min_x, max_x do
			if grid[y][x] == "~" then
				settled_water_count = settled_water_count + 1
			end
		end
	end

	return settled_water_count
end

return M
