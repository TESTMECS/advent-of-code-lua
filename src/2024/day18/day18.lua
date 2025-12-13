--- @title: --- Day 18: RAM Run ---
local M = {}

local unpack = unpack or table.unpack
--- @description Find the shortest path after 1024 bytes
--- @param input string the puzzle input
--- @return number the shortest path length
function M.part1(input)
	local bytes = {}
	for line in input:gmatch("[^\n]+") do
		local x, y = line:match("(%d+),(%d+)")
		table.insert(bytes, { tonumber(x), tonumber(y) })
	end
	local grid = {}
	for i = 0, 70 do
		grid[i] = {}
		for j = 0, 70 do
			grid[i][j] = false
		end
	end
	for i = 1, 1024 do
		local x, y = bytes[i][1], bytes[i][2]
		grid[x][y] = true
	end
	local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
	local visited = {}
	for i = 0, 70 do
		visited[i] = {}
	end
	local queue = { { 0, 0, 0 } } -- x, y, steps
	visited[0][0] = true
	while #queue > 0 do
		local x, y, steps = unpack(table.remove(queue, 1))
		if x == 70 and y == 70 then
			return steps
		end
		for _, d in ipairs(dirs) do
			local nx, ny = x + d[1], y + d[2]
			if nx >= 0 and nx <= 70 and ny >= 0 and ny <= 70 and not grid[nx][ny] and not visited[nx][ny] then
				visited[nx][ny] = true
				table.insert(queue, { nx, ny, steps + 1 })
			end
		end
	end
	return -1
end

--- @description Find the first byte that blocks the path
--- @param input string the puzzle input
--- @return string the coordinates of the blocking byte
function M.part2(input)
	local bytes = {}
	for line in input:gmatch("[^\n]+") do
		local x, y = line:match("(%d+),(%d+)")
		table.insert(bytes, { tonumber(x), tonumber(y) })
	end
	local function can_reach(n)
		local grid = {}
		for i = 0, 70 do
			grid[i] = {}
			for j = 0, 70 do
				grid[i][j] = false
			end
		end
		for i = 1, n do
			local x, y = bytes[i][1], bytes[i][2]
			grid[x][y] = true
		end
		local visited = {}
		for i = 0, 70 do
			visited[i] = {}
		end
		local queue = { { 0, 0 } }
		visited[0][0] = true
		while #queue > 0 do
			local x, y = unpack(table.remove(queue, 1))
			if x == 70 and y == 70 then
				return true
			end
			local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
			for _, d in ipairs(dirs) do
				local nx, ny = x + d[1], y + d[2]
				if nx >= 0 and nx <= 70 and ny >= 0 and ny <= 70 and not grid[nx][ny] and not visited[nx][ny] then
					visited[nx][ny] = true
					table.insert(queue, { nx, ny })
				end
			end
		end
		return false
	end
	local left, right = 1, #bytes
	while left < right do
		local mid = math.floor((left + right) / 2)
		if can_reach(mid) then
			left = mid + 1
		else
			right = mid
		end
	end
	local x, y = bytes[left][1], bytes[left][2]
	return x .. "," .. y
end

return M
