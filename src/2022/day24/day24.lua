--- @title: Day 24: Blizzard Basin (Optimized) ---
local M = {}

local grid = {}
local blizzards = {}
local height, width
local occupied_cache = {}
local cycle_length

local function parse(input)
	grid = {}
	blizzards = {}
	occupied_cache = {}

	local lines = {}
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("\r", "")
		table.insert(lines, line)
	end

	height = #lines
	width = #lines[1]

	-- Calculate cycle length for blizzard positions
	cycle_length = (height - 2) * (width - 2)

	for y = 1, height do
		local line = lines[y]
		grid[y] = {}
		for x = 1, width do
			local c = line:sub(x, x)
			grid[y][x] = c
			if c == "^" then
				table.insert(blizzards, { y = y - 2, x = x - 2, dy = -1, dx = 0 })
			elseif c == "v" then
				table.insert(blizzards, { y = y - 2, x = x - 2, dy = 1, dx = 0 })
			elseif c == "<" then
				table.insert(blizzards, { y = y - 2, x = x - 2, dy = 0, dx = -1 })
			elseif c == ">" then
				table.insert(blizzards, { y = y - 2, x = x - 2, dy = 0, dx = 1 })
			end
		end
	end
end

local function get_occupied(t)
	-- Use cycle-based caching
	local cache_key = t % cycle_length
	if occupied_cache[cache_key] then
		return occupied_cache[cache_key]
	end

	local occ = {}
	local h2 = height - 2
	local w2 = width - 2

	for _, b in ipairs(blizzards) do
		local y, x
		if b.dy ~= 0 then
			y = (b.y + b.dy * t) % h2
			x = b.x
		else
			y = b.y
			x = (b.x + b.dx * t) % w2
		end
		-- Convert back to grid coordinates and use numeric key
		local gy, gx = y + 2, x + 2
		occ[gy * 1000 + gx] = true
	end

	occupied_cache[cache_key] = occ
	return occ
end

local function bfs(sy, sx, ey, ex, start_t)
	-- Use arrays for queue (more efficient than table manipulation)
	local queue_y = {}
	local queue_x = {}
	local queue_t = {}
	local front = 1
	local back = 0

	local function enqueue(y, x, t)
		back = back + 1
		queue_y[back] = y
		queue_x[back] = x
		queue_t[back] = t
	end

	local function dequeue()
		if front > back then
			return nil, nil, nil
		end
		local y, x, t = queue_y[front], queue_x[front], queue_t[front]
		front = front + 1
		return y, x, t
	end

	enqueue(sy, sx, start_t)

	-- Use set for visited states with numeric keys
	local visited = {}
	visited[sy * 1000000 + sx * 1000 + (start_t % cycle_length)] = true

	-- Pre-calculate movement deltas
	local dirs = { { 0, 0 }, { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

	while front <= back do
		local y, x, t = dequeue()

		if y == ey and x == ex then
			return t
		end

		local nt = t + 1
		local occ = get_occupied(nt)

		for i = 1, 5 do
			local ny = y + dirs[i][1]
			local nx = x + dirs[i][2]

			-- Bounds check and wall check
			if
				ny >= 1
				and ny <= height
				and nx >= 1
				and nx <= width
				and grid[ny][nx] ~= "#"
				and not occ[ny * 1000 + nx]
			then
				local key = ny * 1000000 + nx * 1000 + (nt % cycle_length)
				if not visited[key] then
					visited[key] = true
					enqueue(ny, nx, nt)
				end
			end
		end
	end

	return -1
end

--- @description Find the minimum time to reach the end
--- @param input string the puzzle input
--- @return number the time
function M.part1(input)
	parse(input)
	return bfs(1, 2, height, width - 1, 0)
end

--- @description Find the time for round trip with snack
--- @param input string the puzzle input
--- @return number the total time
function M.part2(input)
	parse(input)
	local t1 = bfs(1, 2, height, width - 1, 0)
	local t2 = bfs(height, width - 1, 1, 2, t1)
	local t3 = bfs(1, 2, height, width - 1, t2)
	return t3
end

return M
