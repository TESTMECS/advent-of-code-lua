--- @title: Day 18: Like a GIF For Your Yard ---
local M = {}

--- @function: Parse input grid into a 2D array
--- @param input string
--- @return table
local function parse_grid(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c == "#")
		end
		table.insert(grid, row)
	end
	return grid
end

--- @function: Count the number of neighbors for a given grid position
--- @param g table
--- @param i integer
--- @param j integer
--- @return integer
local function count_neighbors(g, i, j)
	local count = 0
	for di = -1, 1 do
		for dj = -1, 1 do
			if di ~= 0 or dj ~= 0 then
				local ni, nj = i + di, j + dj
				if ni >= 1 and ni <= 100 and nj >= 1 and nj <= 100 and g[ni][nj] then
					count = count + 1
				end
			end
		end
	end
	return count
end

--- @function: Step the lights on the grid
--- @param g table
--- @param stuck_corners boolean
--- @return table
local function step(g, stuck_corners)
	local new_g = {}
	for i = 1, 100 do
		new_g[i] = {}
		for j = 1, 100 do
			local n = count_neighbors(g, i, j)
			local on = g[i][j]
			local new_on
			if on then
				new_on = n == 2 or n == 3
			else
				new_on = n == 3
			end
			if
				stuck_corners
				and ((i == 1 and j == 1) or (i == 1 and j == 100) or (i == 100 and j == 1) or (i == 100 and j == 100))
			then
				new_on = true
			end
			new_g[i][j] = new_on
		end
	end
	return new_g
end

--- @function: Count the number of lights on the grid
--- @param g table
--- @return integer
local function count_lights(g)
	local count = 0
	for i = 1, 100 do
		for j = 1, 100 do
			if g[i][j] then
				count = count + 1
			end
		end
	end
	return count
end

--- @description: How many lights are on the grid after 100 steps?
--- @param input string
--- @return integer
function M.part1(input)
	local grid = parse_grid(input)
	local current = grid
	for _ = 1, 100 do
		current = step(current, false)
	end
	return count_lights(current)
end

--- @description: How many lights are on the grid after 100 steps?
--- @param input string
--- @return integer
function M.part2(input)
	local grid = parse_grid(input)
	-- Set corners to on
	grid[1][1] = true
	grid[1][100] = true
	grid[100][1] = true
	grid[100][100] = true
	local current = grid
	for _ = 1, 100 do
		current = step(current, true)
	end
	return count_lights(current)
end

return M
