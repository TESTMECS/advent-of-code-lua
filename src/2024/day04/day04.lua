--- @title: --- Day 4: Ceres Search ---
local M = {}

--- @description Count occurrences of XMAS in all directions
--- @param input string the puzzle input
--- @return number the count of XMAS
function M.part1(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(grid, row)
	end
	local rows = #grid
	local cols = #grid[1]
	local directions = {
		{0, 1}, {1, 0}, {1, 1}, {1, -1},
		{0, -1}, {-1, 0}, {-1, -1}, {-1, 1}
	}
	local count = 0
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == 'X' then
				for _, dir in ipairs(directions) do
					local dx, dy = dir[1], dir[2]
					if i + 3 * dx >= 1 and i + 3 * dx <= rows and j + 3 * dy >= 1 and j + 3 * dy <= cols then
						if grid[i + dx][j + dy] == 'M' and grid[i + 2 * dx][j + 2 * dy] == 'A' and grid[i + 3 * dx][j + 3 * dy] == 'S' then
							count = count + 1
						end
					end
				end
			end
		end
	end
	return count
end

--- @description Count X-MAS patterns
--- @param input string the puzzle input
--- @return number the count of X-MAS
function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(grid, row)
	end
	local rows = #grid
	local cols = #grid[1]
	local count = 0
	for i = 2, rows - 1 do
		for j = 2, cols - 1 do
			if grid[i][j] == 'A' then
				local d1 = grid[i - 1][j - 1] .. grid[i + 1][j + 1]
				local d2 = grid[i - 1][j + 1] .. grid[i + 1][j - 1]
				if (d1 == 'MS' or d1 == 'SM') and (d2 == 'MS' or d2 == 'SM') then
					count = count + 1
				end
			end
		end
	end
	return count
end

return M
