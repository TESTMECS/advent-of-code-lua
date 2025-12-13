--- @title: Day 25: --- Day 25: Sea Cucumber ---
local M = {}

--- @description: Parses the input into a grid.
--- @param input string: The puzzle input.
--- @return table: The grid.
local function parse_input(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(grid, row)
	end
	return grid
end

--- @function: Performs a single step of the sea cucumber.
--- @param grid table: The grid.
--- @return table, boolean: The new grid and whether any moves were made.
local function step(grid)
	local rows = #grid
	local cols = #grid[1]
	local moved = false

	-- Move east
	local new_grid = {}
	for i = 1, rows do
		new_grid[i] = {}
		for j = 1, cols do
			new_grid[i][j] = grid[i][j]
		end
	end
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == ">" then
				local nj = j % cols + 1
				if grid[i][nj] == "." then
					new_grid[i][j] = "."
					new_grid[i][nj] = ">"
					moved = true
				end
			end
		end
	end
	grid = new_grid

	-- Move south
	new_grid = {}
	for i = 1, rows do
		new_grid[i] = {}
		for j = 1, cols do
			new_grid[i][j] = grid[i][j]
		end
	end
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == "v" then
				local ni = i % rows + 1
				if grid[ni][j] == "." then
					new_grid[i][j] = "."
					new_grid[ni][j] = "v"
					moved = true
				end
			end
		end
	end
	grid = new_grid

	return grid, moved
end

--- @description: Count the number of steps required to reach the bottom-right corner.
--- @param input string: The puzzle input.
--- @return number: The number of steps.
function M.part1(input)
	local grid = parse_input(input)
	local steps = 0
	while true do
		local new_grid, moved = step(grid)
		grid = new_grid
		steps = steps + 1
		if not moved then
			break
		end
	end
	return steps
end

function M.part2(_)
	return "press that button"
end

return M
