--- @title: Day 18: Many-Worlds Interpretation ---
local M = {}

-- A standard min-priority queue implementation
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue
function PriorityQueue.new()
	return setmetatable({ q = {}, n = 0 }, PriorityQueue)
end
function PriorityQueue:push(priority, value)
	self.n = self.n + 1
	self.q[self.n] = { p = priority, v = value }
	local i = self.n
	while i > 1 and self.q[i].p < self.q[math.floor(i / 2)].p do
		self.q[i], self.q[math.floor(i / 2)] = self.q[math.floor(i / 2)], self.q[i]
		i = math.floor(i / 2)
	end
end
function PriorityQueue:pop()
	if self.n == 0 then
		return nil
	end
	local top = self.q[1]
	self.q[1] = self.q[self.n]
	self.q[self.n] = nil
	self.n = self.n - 1
	if self.n == 0 then
		return top.v, top.p
	end
	local i = 1
	while true do
		local s, l, r = i, 2 * i, 2 * i + 1
		if l <= self.n and self.q[l].p < self.q[s].p then
			s = l
		end
		if r <= self.n and self.q[r].p < self.q[s].p then
			s = r
		end
		if s == i then
			break
		end
		self.q[i], self.q[s] = self.q[s], self.q[i]
		i = s
	end
	return top.v, top.p
end
function PriorityQueue:is_empty()
	return self.n == 0
end

--- Parses map, finds locations of start points and keys.
local function parse_map(input)
	local grid, starts, keys = {}, {}, {}
	local y = 1
	for line in input:gmatch("[^\r\n]+") do
		grid[y] = {}
		local x = 1
		for char in line:gmatch(".") do
			grid[y][x] = char
			if char == "@" then
				table.insert(starts, { id = "@" .. #starts + 1, x = x, y = y })
			elseif char:match("[a-z]") then
				keys[char] = { x = x, y = y }
			end
			x = x + 1
		end
		y = y + 1
	end
	return grid, starts, keys
end

--- Pre-computation: Run BFS from each point of interest to find paths to other keys.
local function build_key_graph(grid, starts, keys)
	local points_of_interest = {}
	for _, s in ipairs(starts) do
		points_of_interest[s.id] = { x = s.x, y = s.y }
	end
	for k, p in pairs(keys) do
		points_of_interest[k] = { x = p.x, y = p.y }
	end

	local key_graph = {}
	for id, pos in pairs(points_of_interest) do
		key_graph[id] = {}
		local q = { { x = pos.x, y = pos.y, dist = 0, doors = 0 } }
		local visited = { [pos.y .. "," .. pos.x] = true }

		while #q > 0 do
			local curr = table.remove(q, 1)
			local char = grid[curr.y][curr.x]

			if char:match("[a-z]") and char ~= id then
				key_graph[id][char] = { dist = curr.dist, req = curr.doors }
			end

			for _, d in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
				local nx, ny = curr.x + d[1], curr.y + d[2]
				local key = ny .. "," .. nx
				if not visited[key] and grid[ny] and grid[ny][nx] and grid[ny][nx] ~= "#" then
					visited[key] = true
					local next_doors = curr.doors
					local next_char = grid[ny][nx]
					if next_char:match("[A-Z]") then
						next_doors = next_doors | (1 << (next_char:lower():byte() - ("a"):byte()))
					end
					table.insert(q, { x = nx, y = ny, dist = curr.dist + 1, doors = next_doors })
				end
			end
		end
	end
	return key_graph
end

--- Converts a key character to its bitmask representation.
local function key_to_bit(key)
	return 1 << (key:byte() - ("a"):byte())
end

--- Main solver using Dijkstra's algorithm.
local function solve(key_graph, starts, num_keys)
	local all_keys_mask = (1 << num_keys) - 1

	local start_locs = {}
	for _, s in ipairs(starts) do
		table.insert(start_locs, s.id)
	end
	table.sort(start_locs)

	local start_state = { dist = 0, locs = start_locs, keys = 0 }

	local pq = PriorityQueue.new()
	pq:push(0, start_state)

	local visited = {}

	while not pq:is_empty() do
		local state = pq:pop()

		if state.keys == all_keys_mask then
			return state.dist
		end

		local visited_key = table.concat(state.locs, ",") .. ":" .. state.keys
		if visited[visited_key] and visited[visited_key] <= state.dist then
			goto continue_loop
		end
		visited[visited_key] = state.dist

		-- Try moving each robot
		for i, robot_loc in ipairs(state.locs) do
			for next_key, path in pairs(key_graph[robot_loc]) do
				local key_bit = key_to_bit(next_key)
				-- If we don't have this key yet and we can open all doors on the path
				if (state.keys & key_bit) == 0 and (state.keys & path.req) == path.req then
					local new_locs = {}
					for _, l in ipairs(state.locs) do
						table.insert(new_locs, l)
					end
					new_locs[i] = next_key
					table.sort(new_locs)

					local new_state = {
						dist = state.dist + path.dist,
						locs = new_locs,
						keys = (state.keys | key_bit),
					}
					pq:push(new_state.dist, new_state)
				end
			end
		end
		::continue_loop::
	end
	return -1 -- Should not be reached
end

function M.part1(input)
	local grid, starts, keys = parse_map(input)
	local num_keys = 0
	for _ in pairs(keys) do
		num_keys = num_keys + 1
	end
	local key_graph = build_key_graph(grid, starts, keys)
	return solve(key_graph, starts, num_keys)
end

function M.part2(input)
	local grid, starts, keys = parse_map(input)

	-- Modify the map for Part 2
	local sx, sy = starts[1].x, starts[1].y
	grid[sy][sx] = "#"
	grid[sy - 1][sx] = "#"
	grid[sy + 1][sx] = "#"
	grid[sy][sx - 1] = "#"
	grid[sy][sx + 1] = "#"

	-- Create the four new start positions manually
	local new_starts = {
		{ id = "@1", x = sx - 1, y = sy - 1 },
		{ id = "@2", x = sx + 1, y = sy - 1 },
		{ id = "@3", x = sx - 1, y = sy + 1 },
		{ id = "@4", x = sx + 1, y = sy + 1 },
	}
	for _, s in ipairs(new_starts) do
		grid[s.y][s.x] = "@"
	end

	local num_keys = 0
	for _ in pairs(keys) do
		num_keys = num_keys + 1
	end

	local key_graph = build_key_graph(grid, new_starts, keys)
	return solve(key_graph, new_starts, num_keys)
end

return M
