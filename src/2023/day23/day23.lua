--- @title: Day 23: A Long Walk
local M = {}

--- @description Finds the longest path from start to end following slope rules
--- @param input string: the puzzle input
--- @return number: length of the longest path
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
	if rows == 0 then
		return 0
	end
	local cols = #grid[1]
	local start = { 1, 1 }
	for j = 1, cols do
		if grid[1][j] == "." then
			start = { 1, j }
			break
		end
	end
	local goal = { rows, 1 }
	for j = 1, cols do
		if grid[rows][j] == "." then
			goal = { rows, j }
			break
		end
	end
	local visited = {}
	local stack = { { start[1], start[2], 0 } }
	local max_len = 0
	while #stack > 0 do
		local curr = stack[#stack]
		local x, y, len = curr[1], curr[2], curr[3]
		local key = x .. "," .. y
		if x == goal[1] and y == goal[2] then
			max_len = math.max(max_len, len)
			table.remove(stack)
			visited[key] = nil
			goto continue
		end
		if visited[key] then
			table.remove(stack)
			visited[key] = nil
			goto continue
		end
		visited[key] = true
		local dirs = {}
		local cell = grid[x][y]
		if cell == "^" then
			dirs = { { -1, 0 } }
		elseif cell == ">" then
			dirs = { { 0, 1 } }
		elseif cell == "v" then
			dirs = { { 1, 0 } }
		elseif cell == "<" then
			dirs = { { 0, -1 } }
		else
			dirs = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } }
		end
		local pushed = false
		for _, d in ipairs(dirs) do
			local nx, ny = x + d[1], y + d[2]
			local nkey = nx .. "," .. ny
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] ~= "#" and not visited[nkey] then
				table.insert(stack, { nx, ny, len + 1 })
				pushed = true
			end
		end
		if not pushed then
			table.remove(stack)
			visited[key] = nil
		end
		::continue::
	end
	return max_len
end
local function build_graph(grid, start, goal)
	local rows, cols = #grid, #grid[1]
	local function neighbors(x, y)
		local res = {}
		for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
			local nx, ny = x + d[1], y + d[2]
			if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] ~= "#" then
				table.insert(res, { nx, ny })
			end
		end
		return res
	end

	-- identify junctions
	local is_junction = {}
	local junctions = {}
	local function mark(x, y)
		local k = x .. "," .. y
		if not is_junction[k] then
			is_junction[k] = true
			table.insert(junctions, { x, y })
		end
	end
	mark(start[1], start[2])
	mark(goal[1], goal[2])
	for i = 1, rows do
		for j = 1, cols do
			if grid[i][j] ~= "#" then
				local deg = #neighbors(i, j)
				if deg ~= 2 then
					mark(i, j)
				end
			end
		end
	end

	-- build edges
	local graph = {}
	local function key(x, y)
		return x .. "," .. y
	end
	for _, junc in ipairs(junctions) do
		local x, y = junc[1], junc[2]
		local k = key(x, y)
		graph[k] = {}
		for _, nb in ipairs(neighbors(x, y)) do
			local px, py = x, y
			local cx, cy = nb[1], nb[2]
			local dist = 1
			while not is_junction[key(cx, cy)] do
				local nbs = neighbors(cx, cy)
				local nx, ny = nbs[1][1], nbs[1][2]
				if nx == px and ny == py then
					nx, ny = nbs[2][1], nbs[2][2]
				end
				px, py = cx, cy
				cx, cy = nx, ny
				dist = dist + 1
			end
			table.insert(graph[k], { key(cx, cy), dist })
		end
	end
	return graph, key(start[1], start[2]), key(goal[1], goal[2])
end

local function dfs(graph, node, goal, visited, dist)
	if node == goal then
		return dist
	end
	visited[node] = true
	local best = -math.huge
	for _, edge in ipairs(graph[node]) do
		local nxt, w = edge[1], edge[2]
		if not visited[nxt] then
			best = math.max(best, dfs(graph, nxt, goal, visited, dist + w))
		end
	end
	visited[node] = nil
	return best
end

function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(grid, row)
	end
	local rows, cols = #grid, #grid[1]
	local start, goal
	for j = 1, cols do
		if grid[1][j] == "." then
			start = { 1, j }
		end
	end
	for j = 1, cols do
		if grid[rows][j] == "." then
			goal = { rows, j }
		end
	end

	local graph, skey, gkey = build_graph(grid, start, goal)
	return dfs(graph, skey, gkey, {}, 0)
end
return M
