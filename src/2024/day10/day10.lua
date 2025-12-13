--- @title: --- Day 10: Hoof It ---
local M = {}

--- @description Sum the scores of all trailheads
--- @param input string the puzzle input
--- @return number the total score
function M.part1(input)
	local grid = {}
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			grid[row][col] = tonumber(line:sub(col, col))
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dx = { -1, 0, 1, 0 }
	local dy = { 0, 1, 0, -1 }
	local function dfs(x, y, visited)
		if grid[x][y] == 9 then
			if not visited[x .. "," .. y] then
				visited[x .. "," .. y] = true
				return 1
			end
			return 0
		end
		local count = 0
		for d = 1, 4 do
			local nx, ny = x + dx[d], y + dy[d]
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] == grid[x][y] + 1 then
				count = count + dfs(nx, ny, visited)
			end
		end
		return count
	end
	local total = 0
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == 0 then
				local visited = {}
				total = total + dfs(i, j, visited)
			end
		end
	end
	return total
end

--- @description Sum the ratings of all trailheads
--- @param input string the puzzle input
--- @return number the total rating
function M.part2(input)
	local grid = {}
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			grid[row][col] = tonumber(line:sub(col, col))
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dx = { -1, 0, 1, 0 }
	local dy = { 0, 1, 0, -1 }
	local function dfs(x, y)
		if grid[x][y] == 9 then
			return 1
		end
		local count = 0
		for d = 1, 4 do
			local nx, ny = x + dx[d], y + dy[d]
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] == grid[x][y] + 1 then
				count = count + dfs(nx, ny)
			end
		end
		return count
	end
	local total = 0
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == 0 then
				total = total + dfs(i, j)
			end
		end
	end
	return total
end

return M
