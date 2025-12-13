--- @title: --- Day 20: Race Condition ---
local M = {}

--- @description Count shortcuts that save at least 100 picoseconds
--- @param input string the puzzle input
--- @return number the count
function M.part1(input)
	local grid = {}
	local row = 1
	local start, goal
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			local c = line:sub(col, col)
			grid[row][col] = c
			if c == "S" then
				start = { row, col }
			end
			if c == "E" then
				goal = { row, col }
			end
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
	local path = {}
	local visited = {}
	for i = 1, rows do
		visited[i] = {}
	end
	local function dfs(x, y, steps)
		if x == goal[1] and y == goal[2] then
			path[steps] = { x, y }
			return true
		end
		for _, d in ipairs(dirs) do
			local nx, ny = x + d[1], y + d[2]
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] ~= "#" and not visited[nx][ny] then
				visited[nx][ny] = true
				if dfs(nx, ny, steps + 1) then
					path[steps] = { x, y }
					return true
				end
				visited[nx][ny] = false
			end
		end
		return false
	end
	visited[start[1]][start[2]] = true
	dfs(start[1], start[2], 0)
	local count = 0
	for i = 0, #path - 1 do
		for j = i + 1, #path do
			local p1, p2 = path[i], path[j]
			local dist = math.abs(p1[1] - p2[1]) + math.abs(p1[2] - p2[2])
			if dist <= 2 and j - i - dist >= 100 then
				count = count + 1
			end
		end
	end
	return count
end

--- @description Count shortcuts that save at least 100 picoseconds with longer cheats
--- @param input string the puzzle input
--- @return number the count
function M.part2(input)
	local grid = {}
	local row = 1
	local start, goal
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			local c = line:sub(col, col)
			grid[row][col] = c
			if c == "S" then
				start = { row, col }
			end
			if c == "E" then
				goal = { row, col }
			end
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
	local path = {}
	local visited = {}
	for i = 1, rows do
		visited[i] = {}
	end
	local function dfs(x, y, steps)
		if x == goal[1] and y == goal[2] then
			path[steps] = { x, y }
			return true
		end
		for _, d in ipairs(dirs) do
			local nx, ny = x + d[1], y + d[2]
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] ~= "#" and not visited[nx][ny] then
				visited[nx][ny] = true
				if dfs(nx, ny, steps + 1) then
					path[steps] = { x, y }
					return true
				end
				visited[nx][ny] = false
			end
		end
		return false
	end
	visited[start[1]][start[2]] = true
	dfs(start[1], start[2], 0)
	local count = 0
	for i = 0, #path - 1 do
		for j = i + 1, #path do
			local p1, p2 = path[i], path[j]
			local dist = math.abs(p1[1] - p2[1]) + math.abs(p1[2] - p2[2])
			if dist <= 20 and j - i - dist >= 100 then
				count = count + 1
			end
		end
	end
	return count
end

return M
