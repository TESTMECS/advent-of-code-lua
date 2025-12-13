--- @title: --- Day 6: Guard Gallivant ---
local M = {}

--- @description Count distinct positions visited by the guard
--- @param input string the puzzle input
--- @return number the count of distinct positions
function M.part1(input)
	local grid = {}
	local start_x, start_y
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			local c = line:sub(col, col)
			grid[row][col] = c
			if c == "^" then
				start_x, start_y = row, col
			end
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dx = { -1, 0, 1, 0 }
	local dy = { 0, 1, 0, -1 }
	local visited = {}
	local x, y, dir = start_x, start_y, 0
	visited[x .. "," .. y] = true
	while true do
		local nx, ny = x + dx[dir + 1], y + dy[dir + 1]
		if nx < 1 or nx > rows or ny < 1 or ny > cols then
			break
		end
		if grid[nx][ny] == "#" then
			dir = (dir + 1) % 4
		else
			x, y = nx, ny
			visited[x .. "," .. y] = true
		end
	end
	local count = 0
	for _ in pairs(visited) do
		count = count + 1
	end
	return count
end

--- @description Count positions that cause a loop when obstructed
--- @param input string the puzzle input
--- @return number the count of such positions
function M.part2(input)
	local grid = {}
	local start_x, start_y
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			local c = line:sub(col, col)
			grid[row][col] = c
			if c == "^" then
				start_x, start_y = row, col
			end
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dx = { -1, 0, 1, 0 }
	local dy = { 0, 1, 0, -1 }

	local function has_loop(ob_x, ob_y)
		local visited = {}
		local x, y, dir = start_x, start_y, 0
		while true do
			local state = x .. "," .. y .. "," .. dir
			if visited[state] then
				return true
			end
			visited[state] = true
			local nx, ny = x + dx[dir + 1], y + dy[dir + 1]
			if nx < 1 or nx > rows or ny < 1 or ny > cols then
				return false
			end
			if (nx == ob_x and ny == ob_y) or grid[nx][ny] == "#" then
				dir = (dir + 1) % 4
			else
				x, y = nx, ny
			end
		end
	end

	local count = 0
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] == "." and (i ~= start_x or j ~= start_y) then
				if has_loop(i, j) then
					count = count + 1
				end
			end
		end
	end
	return count
end

return M
