--- @title: --- Day 9: Smoke Basin ---
local M = {}

--- @description: Find all low points and calculate the sum of their risk levels
--- @param input string: the puzzle input
--- @return number: the sum of risk levels
function M.part1(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("\r", "")
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		if #row > 0 then
			table.insert(grid, row)
		end
	end
	local rows = #grid
	if rows == 0 then
		return 0
	end
	local cols = #grid[1]
	if cols == 0 then
		return 0
	end
	local risk = 0
	for i = 1, rows do
		for j = 1, cols do
			local h = grid[i][j]
			local low = true
			if i > 1 and grid[i - 1][j] <= h then
				low = false
			end
			if i < rows and grid[i + 1][j] <= h then
				low = false
			end
			if j > 1 and grid[i][j - 1] <= h then
				low = false
			end
			if j < cols and grid[i][j + 1] <= h then
				low = false
			end
			if low then
				risk = risk + h + 1
			end
		end
	end
	return risk
end

--- @description: Find the three largest basins and multiply their sizes
--- @param input string: the puzzle input
--- @return number: the product of the three largest basin sizes
function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("\r", "")
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		if #row > 0 then
			table.insert(grid, row)
		end
	end
	local rows = #grid
	if rows == 0 then
		return 0
	end
	local cols = #grid[1]
	if cols == 0 then
		return 0
	end
	local basins = {}
	local visited = {}
	for i = 1, rows do
		visited[i] = {}
		for j = 1, cols do
			visited[i][j] = false
		end
	end
	local function dfs(i, j)
		if i < 1 or i > rows or j < 1 or j > cols or visited[i][j] or grid[i][j] == 9 then
			return 0
		end
		visited[i][j] = true
		local size = 1
		size = size + dfs(i - 1, j)
		size = size + dfs(i + 1, j)
		size = size + dfs(i, j - 1)
		size = size + dfs(i, j + 1)
		return size
	end
	for i = 1, rows do
		for j = 1, cols do
			if not visited[i][j] and grid[i][j] ~= 9 then
				local low = true
				if i > 1 and grid[i - 1][j] <= grid[i][j] then
					low = false
				end
				if i < rows and grid[i + 1][j] <= grid[i][j] then
					low = false
				end
				if j > 1 and grid[i][j - 1] <= grid[i][j] then
					low = false
				end
				if j < cols and grid[i][j + 1] <= grid[i][j] then
					low = false
				end
				if low then
					table.insert(basins, dfs(i, j))
				end
			end
		end
	end
	table.sort(basins)
	local n = #basins
	return basins[n] * basins[n - 1] * basins[n - 2]
end

return M
