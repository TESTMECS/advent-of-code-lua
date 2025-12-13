--- @title: --- Day 12: Garden Groups ---
local M = {}
local util = require("util")

--- @description Calculate the total price of fencing
--- @param input string the puzzle input
--- @return number the total price
function M.part1(input)
	local grid = {}
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			grid[row][col] = line:sub(col, col)
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local visited = {}
	local dx = { -1, 0, 1, 0 }
	local dy = { 0, 1, 0, -1 }
	local function dfs(x, y, plant, region)
		if x < 1 or x > rows or y < 1 or y > cols or visited[x][y] or grid[x][y] ~= plant then
			return 0, 0
		end
		visited[x][y] = true
		table.insert(region, { x, y })
		local area = 1
		local perimeter = 0
		for d = 1, 4 do
			local nx, ny = x + dx[d], y + dy[d]
			if nx < 1 or nx > rows or ny < 1 or ny > cols or grid[nx][ny] ~= plant then
				perimeter = perimeter + 1
			else
				local a, p = dfs(nx, ny, plant, region)
				area = area + a
				perimeter = perimeter + p
			end
		end
		return area, perimeter
	end
	local total = 0
	for i = 1, rows do
		visited[i] = {}
	end
	for i = 1, rows do
		for j = 1, cols do
			if not visited[i][j] then
				local region = {}
				local area, perimeter = dfs(i, j, grid[i][j], region)
				total = total + area * perimeter
			end
		end
	end
	return total
end

--- @description Calculate the total price with bulk discount
--- @param input string the puzzle input
--- @return number the total price
function M.part2(input)
	local map = {}
	local seen = {}
	local row, col = 1, 1
	for _, line in ipairs(util.read_lines(input)) do
		map[row] = {}
		seen[row] = {}
		col = 1
		for c in string.gmatch(line, ".") do
			map[row][col] = c
			seen[row][col] = false
			col = col + 1
		end
		row = row + 1
	end
	row = row - 1
	col = col - 1

	local dir4 = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } }
	local dir4diag = { { 1, 1 }, { -1, 1 }, { -1, -1 }, { 1, -1 } }
	local function calculate(sr, sc)
		local flower = map[sr][sc]
		local queue = { { sr, sc } }
		local perimeter = 0
		local area = 0
		local corner = 0
		while #queue > 0 do
			local px, py = table.unpack(queue[1])
			table.remove(queue, 1)
			if seen[px] == nil or seen[px][py] or map[px] == nil or map[px][py] ~= flower then
				goto continue
			end
			seen[px][py] = true
			area = area + 1
			for i = 1, 4 do
				local dx, dy = table.unpack(dir4[i])
				local nx, ny = px + dx, py + dy

				if map[nx] == nil or map[px][py] ~= map[nx][ny] then
					perimeter = perimeter + 1
				end

				local rightindex = (i % 4) + 1
				local topx, topy = nx, ny
				dx, dy = table.unpack(dir4diag[i])
				local diagx, diagy = px + dx, py + dy
				dx, dy = table.unpack(dir4[rightindex])
				local rightx, righty = px + dx, py + dy
				if
					(map[topx] ~= nil and map[topx][topy] == flower)
					and (map[diagx] == nil or map[diagx][diagy] ~= flower)
					and (map[rightx] ~= nil and map[rightx][righty] == flower)
				then
					corner = corner + 1
				elseif
					(map[topx] == nil or map[topx][topy] ~= flower)
					and (map[rightx] == nil or map[rightx][righty] ~= flower)
				then
					corner = corner + 1
				end

				queue[#queue + 1] = { nx, ny }
			end
			::continue::
		end
		return area, perimeter, corner
	end

	local sum = 0
	for r = 1, row do
		for c = 1, col do
			if not seen[r][c] then
				local area, _, corner = calculate(r, c)
				sum = sum + area * corner
			end
		end
	end
	return sum
end

return M
