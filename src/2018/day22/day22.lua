--- @title: Day 22: Mode Maze ---
local M = {}

-- Constants for clarity
local MOD = 20183
local ROCKY, WET, NARROW = 0, 1, 2
local TORCH, GEAR, NEITHER = 0, 1, 2

-- A simple priority queue implementation for Dijkstra's
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue
--- @function: Creates a new priority queue
--- @return table: the priority queue
function PriorityQueue.new()
	return setmetatable({ queue = {}, size = 0 }, PriorityQueue)
end
--- @function: Pushes a new value onto the queue
--- @param priority number: the priority of the value
--- @param value any: the value to push
--- @return nil
function PriorityQueue:push(priority, value)
	self.size = self.size + 1
	self.queue[self.size] = { p = priority, v = value }
	-- Bubble up
	local i = self.size
	while i > 1 and self.queue[i].p < self.queue[math.floor(i / 2)].p do
		self.queue[i], self.queue[math.floor(i / 2)] = self.queue[math.floor(i / 2)], self.queue[i]
		i = math.floor(i / 2)
	end
end
--- @function: Pops the top value from the queue
--- @return any, number|nil: the value and its priority
function PriorityQueue:pop()
	if self.size == 0 then
		return nil
	end
	local top = self.queue[1]
	self.queue[1] = self.queue[self.size]
	self.queue[self.size] = nil
	self.size = self.size - 1
	-- Bubble down
	local i = 1
	while true do
		local smallest = i
		local left = 2 * i
		local right = 2 * i + 1
		if left <= self.size and self.queue[left].p < self.queue[smallest].p then
			smallest = left
		end
		if right <= self.size and self.queue[right].p < self.queue[smallest].p then
			smallest = right
		end
		if smallest == i then
			break
		end
		self.queue[i], self.queue[smallest] = self.queue[smallest], self.queue[i]
		i = smallest
	end
	return top.v, top.p
end
--- @function: Checks if the queue is empty
--- @return boolean: true if the queue is empty, false otherwise
function PriorityQueue:is_empty()
	return self.size == 0
end

--- @function: Parses the depth and target coordinates from the input string.
--- @param input string: the puzzle input
--- @return number|nil, number|nil, number|nil: the depth, target x, and target y
local function parse_input(input)
	local depth = tonumber(input:match("depth: (%d+)"))
	local tx, ty = input:match("target: (%d+),(%d+)")
	return depth, tonumber(tx), tonumber(ty)
end

--- @function: Generates the cave system grid (erosion levels and types).
--- @param depth number: the depth of the cave system
--- @param target_x number: the x coordinate of the target
--- @param target_y number: the y coordinate of the target
--- @param width number: the width of the grid
--- @param height number: the height of the grid
--- @return table: the cave system grid
local function generate_cave_system(depth, target_x, target_y, width, height)
	local erosion_levels = {}
	local region_types = {}

	for y = 0, height do
		erosion_levels[y] = {}
		region_types[y] = {}
		for x = 0, width do
			local geo_index
			if (x == 0 and y == 0) or (x == target_x and y == target_y) then
				geo_index = 0
			elseif y == 0 then
				geo_index = x * 16807
			elseif x == 0 then
				geo_index = y * 48271
			else
				geo_index = erosion_levels[y][x - 1] * erosion_levels[y - 1][x]
			end
			erosion_levels[y][x] = (geo_index + depth) % MOD
			region_types[y][x] = erosion_levels[y][x] % 3
		end
	end
	return region_types
end

--- @description Calculate the total risk level for the area between (0,0) and the target.
--- @param input string the puzzle input
--- @return number The total risk level.
function M.part1(input)
	local depth, target_x, target_y = parse_input(input)
	local region_types = generate_cave_system(depth, target_x, target_y, target_x, target_y)

	local total_risk = 0
	for y = 0, target_y do
		for x = 0, target_x do
			total_risk = total_risk + region_types[y][x]
		end
	end
	return total_risk
end

--- @description Find the shortest time to travel from (0,0) to the target with a torch.
--- @param input string the puzzle input
--- @return number The minimum time in minutes.
function M.part2(input)
	local depth, target_x, target_y = parse_input(input)

	-- We might need to go outside the target bounds, so make the map larger.
	local map_width = target_x + 50
	local map_height = target_y + 50
	local region_types = generate_cave_system(depth, target_x, target_y, map_width, map_height)

	-- Maps region type to a list of allowed tools
	local allowed_tools = {
		[ROCKY] = { [TORCH] = true, [GEAR] = true },
		[WET] = { [GEAR] = true, [NEITHER] = true },
		[NARROW] = { [TORCH] = true, [NEITHER] = true },
	}

	local pq = PriorityQueue.new()
	local dist = {} -- dist[y][x][tool] = min_time

	-- Initialize distances to infinity
	for y = 0, map_height do
		dist[y] = {}
		for x = 0, map_width do
			dist[y][x] = { [TORCH] = math.huge, [GEAR] = math.huge, [NEITHER] = math.huge }
		end
	end

	-- Starting state
	dist[0][0][TORCH] = 0
	pq:push(0, { x = 0, y = 0, tool = TORCH })

	while not pq:is_empty() do
		local state, time = pq:pop()
		local x, y, tool = state.x, state.y, state.tool

		if time > dist[y][x][tool] then
			goto continue_loop
		end

		if x == target_x and y == target_y and tool == TORCH then
			return time
		end

		-- 1. Try to switch tools (cost: 7 minutes)
		for other_tool = 0, 2 do
			if other_tool ~= tool and allowed_tools[region_types[y][x]][other_tool] then
				local new_time = time + 7
				if new_time < dist[y][x][other_tool] then
					dist[y][x][other_tool] = new_time
					pq:push(new_time, { x = x, y = y, tool = other_tool })
				end
			end
		end

		-- 2. Try to move to adjacent regions (cost: 1 minute)
		for _, offset in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
			local nx, ny = x + offset[1], y + offset[2]
			if nx >= 0 and nx <= map_width and ny >= 0 and ny <= map_height then
				if allowed_tools[region_types[ny][nx]][tool] then
					local new_time = time + 1
					if new_time < dist[ny][nx][tool] then
						dist[ny][nx][tool] = new_time
						pq:push(new_time, { x = nx, y = ny, tool = tool })
					end
				end
			end
		end

		::continue_loop::
	end
	return -1 -- Should not be reached
end

return M
