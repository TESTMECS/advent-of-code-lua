 --- @title: Day 12: Hill Climbing Algorithm ---
local M = {}

local function parse_input(input)
	local grid = {}
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local start_r, start_c, end_r, end_c
	for i, line in ipairs(lines) do
		grid[i] = {}
		for j = 1, #line do
			local c = line:sub(j, j)
			if c == 'S' then
				grid[i][j] = 1
				start_r, start_c = i, j
			elseif c == 'E' then
				grid[i][j] = 26
				end_r, end_c = i, j
			else
				grid[i][j] = string.byte(c) - string.byte('a') + 1
			end
		end
	end
	return grid, start_r, start_c, end_r, end_c
end

local directions = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

local function bfs(grid, sr, sc, er, ec, can_move)
	local rows, cols = #grid, #grid[1]
	local queue = { { sr, sc, 0 } }
	local visited = {}
	visited[sr .. ',' .. sc] = true
	while #queue > 0 do
		local r, c, dist = table.unpack(table.remove(queue, 1))
		if r == er and c == ec then
			return dist
		end
		for _, d in ipairs(directions) do
			local nr, nc = r + d[1], c + d[2]
			if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols and not visited[nr .. ',' .. nc] and can_move(grid[r][c], grid[nr][nc]) then
				visited[nr .. ',' .. nc] = true
				table.insert(queue, { nr, nc, dist + 1 })
			end
		end
	end
	return -1
end

local function bfs_part2(grid, sr, sc, can_move, target_func)
	local rows, cols = #grid, #grid[1]
	local queue = { { sr, sc, 0 } }
	local visited = {}
	visited[sr .. ',' .. sc] = true
	local min_dist = math.huge
	while #queue > 0 do
		local r, c, dist = table.unpack(table.remove(queue, 1))
		if target_func(grid, r, c) then
			min_dist = math.min(min_dist, dist)
		end
		for _, d in ipairs(directions) do
			local nr, nc = r + d[1], c + d[2]
			if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols and not visited[nr .. ',' .. nc] and can_move(grid[r][c], grid[nr][nc]) then
				visited[nr .. ',' .. nc] = true
				table.insert(queue, { nr, nc, dist + 1 })
			end
		end
	end
	return min_dist == math.huge and -1 or min_dist
end

--- @description Find shortest path from S to E
--- @param input string the puzzle input
--- @return number the shortest path length
function M.part1(input)
	local grid, start_r, start_c, end_r, end_c = parse_input(input)
	return bfs(grid, start_r, start_c, end_r, end_c, function(curr, next) return next <= curr + 1 end)
end

--- @description Find shortest path from any 'a' to E
--- @param input string the puzzle input
--- @return number the shortest path length
function M.part2(input)
	local grid, _, _, end_r, end_c = parse_input(input)
	return bfs_part2(grid, end_r, end_c, function(curr, next) return next >= curr - 1 end, function(g, r, c) return g[r][c] == 1 end)
end

return M
