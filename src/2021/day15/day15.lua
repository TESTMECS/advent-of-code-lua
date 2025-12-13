--- @title: Day 15: Title ---
local M = {}

--- @description: Find the path with the lowest total risk from top-left to bottom-right
--- @param input string: the puzzle input
--- @return number: the lowest total risk
function M.part1(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		table.insert(grid, row)
	end
	local rows = #grid
	if rows == 0 then
		return 0
	end
	local cols = #grid[1]
	if cols == 0 then
		return 0
	end
	local dist = {}
	for i = 1, rows do
		dist[i] = {}
		for j = 1, cols do
			dist[i][j] = math.huge
		end
	end
	dist[1][1] = 0
	local pq = { { i = 1, j = 1, cost = 0 } }
	local visited = {}
	for i = 1, rows do
		visited[i] = {}
		for j = 1, cols do
			visited[i][j] = false
		end
	end
	while #pq > 0 do
		table.sort(pq, function(a, b)
			return a.cost < b.cost
		end)
		local current = table.remove(pq, 1)
		local i, j = current.i, current.j
		if visited[i][j] then
			goto continue
		end
		visited[i][j] = true
		if i == rows and j == cols then
			return dist[i][j]
		end
		for _, dir in ipairs({ { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }) do
			local ni = i + dir[1]
			local nj = j + dir[2]
			if ni >= 1 and ni <= rows and nj >= 1 and nj <= cols and not visited[ni][nj] then
				local new_cost = dist[i][j] + grid[ni][nj]
				if new_cost < dist[ni][nj] then
					dist[ni][nj] = new_cost
					table.insert(pq, { i = ni, j = nj, cost = new_cost })
				end
			end
		end
		::continue::
	end
	return 0
end

--- @description: Find the path with the lowest total risk in the 5x5 expanded grid
--- @param input string: the puzzle input
--- @return number: the lowest total risk
function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		table.insert(grid, row)
	end
	local rows = #grid
	if rows == 0 then
		return 0
	end
	local cols = #grid[1]
	if cols == 0 then
		return 0
	end
	local big_grid = {}
	for bi = 0, 4 do
		for bj = 0, 4 do
			for i = 1, rows do
				for j = 1, cols do
					local risk = (grid[i][j] + bi + bj - 1) % 9 + 1
					local ni = (bi * rows) + i
					local nj = (bj * cols) + j
					if not big_grid[ni] then
						big_grid[ni] = {}
					end
					big_grid[ni][nj] = risk
				end
			end
		end
	end
	local big_rows = rows * 5
	local big_cols = cols * 5
	local dist = {}
	for i = 1, big_rows do
		dist[i] = {}
		for j = 1, big_cols do
			dist[i][j] = math.huge
		end
	end
	dist[1][1] = 0
	local pq = { { i = 1, j = 1, cost = 0 } }
	local visited = {}
	for i = 1, big_rows do
		visited[i] = {}
		for j = 1, big_cols do
			visited[i][j] = false
		end
	end
	while #pq > 0 do
		table.sort(pq, function(a, b)
			return a.cost < b.cost
		end)
		local current = table.remove(pq, 1)
		local i, j = current.i, current.j
		if visited[i][j] then
			goto continue
		end
		visited[i][j] = true
		if i == big_rows and j == big_cols then
			return dist[i][j]
		end
		for _, dir in ipairs({ { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }) do
			local ni = i + dir[1]
			local nj = j + dir[2]
			if ni >= 1 and ni <= big_rows and nj >= 1 and nj <= big_cols and not visited[ni][nj] then
				local new_cost = dist[i][j] + big_grid[ni][nj]
				if new_cost < dist[ni][nj] then
					dist[ni][nj] = new_cost
					table.insert(pq, { i = ni, j = nj, cost = new_cost })
				end
			end
		end
		::continue::
	end
	return 0
end

return M
