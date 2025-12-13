--- @title: Day 23: Experimental Emergency Teleportation ---
local M = {}

--- A simple MIN-priority queue implementation for Dijkstra's / A*
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue
--- @function: Creates a new priority queue
--- @return table: the priority queue
function PriorityQueue.new()
	return setmetatable({ queue = {}, size = 0 }, PriorityQueue)
end
--- @function: Pushes a new value onto the queue
--- @param priority_tbl table: the priority of the value
--- @param value any: the value to push
--- @return nil
function PriorityQueue:push(priority_tbl, value)
	self.size = self.size + 1
	self.queue[self.size] = { p = priority_tbl, v = value }
	local i = self.size
	while i > 1 do
		local parent_i = math.floor(i / 2)
		local p_curr = self.queue[i].p
		local p_parent = self.queue[parent_i].p
		-- Lexicographical comparison for min-heap
		if
			p_curr[1] > p_parent[1]
			or (p_curr[1] == p_parent[1] and p_curr[2] > p_parent[2])
			or (p_curr[1] == p_parent[1] and p_curr[2] == p_parent[2] and p_curr[3] > p_parent[3])
		then
			break
		end
		self.queue[i], self.queue[parent_i] = self.queue[parent_i], self.queue[i]
		i = parent_i
	end
end
--- @function: Pops the top value from the queue
--- @return any, table|nil: the value and its priority
function PriorityQueue:pop()
	if self.size == 0 then
		return nil
	end
	local top = self.queue[1]
	self.queue[1] = self.queue[self.size]
	self.queue[self.size] = nil
	self.size = self.size - 1
	if self.size == 0 then
		return top.v
	end
	local i = 1
	while true do
		local smallest = i
		local left = 2 * i
		local right = 2 * i + 1
		if
			left <= self.size
			and (
				self.queue[left].p[1] < self.queue[smallest].p[1]
				or (self.queue[left].p[1] == self.queue[smallest].p[1] and self.queue[left].p[2] < self.queue[smallest].p[2])
				or (
					self.queue[left].p[1] == self.queue[smallest].p[1]
					and self.queue[left].p[2] == self.queue[smallest].p[2]
					and self.queue[left].p[3] < self.queue[smallest].p[3]
				)
			)
		then
			smallest = left
		end
		if
			right <= self.size
			and (
				self.queue[right].p[1] < self.queue[smallest].p[1]
				or (self.queue[right].p[1] == self.queue[smallest].p[1] and self.queue[right].p[2] < self.queue[smallest].p[2])
				or (
					self.queue[right].p[1] == self.queue[smallest].p[1]
					and self.queue[right].p[2] == self.queue[smallest].p[2]
					and self.queue[right].p[3] < self.queue[smallest].p[3]
				)
			)
		then
			smallest = right
		end
		if smallest == i then
			break
		end
		self.queue[i], self.queue[smallest] = self.queue[smallest], self.queue[i]
		i = smallest
	end
	return top.v
end
--- @function: Checks if the queue is empty
--- @return boolean: true if the queue is empty, false otherwise
function PriorityQueue:is_empty()
	return self.size == 0
end

--- @function: Parses the input into a list of nanobot tables.
--- @param input string: the puzzle input
--- @return table: the list of nanobots
local function parse_nanobots(input)
	local bots = {}
	for x, y, z, r in input:gmatch("pos=<([%-%d]+),([%-%d]+),([%-%d]+)>, r=(%d+)") do
		table.insert(bots, { x = tonumber(x), y = tonumber(y), z = tonumber(z), r = tonumber(r) })
	end
	return bots
end

--- @function: Calculates Manhattan distance between two points.
--- @param p1 table: the first point
--- @param p2 table: the second point
--- @return number: the Manhattan distance
local function manhattan(p1, p2)
	return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y) + math.abs(p1.z - p2.z)
end

--- @description Find the number of nanobots in range of the nanobot with the largest signal radius.
--- @param input string the puzzle input
--- @return number The count of nanobots in range.
function M.part1(input)
	local bots = parse_nanobots(input)
	if #bots == 0 then
		return 0
	end

	local strongest_bot = bots[1]
	for i = 2, #bots do
		if bots[i].r > strongest_bot.r then
			strongest_bot = bots[i]
		end
	end

	local in_range_count = 0
	for _, bot in ipairs(bots) do
		if manhattan(strongest_bot, bot) <= strongest_bot.r then
			in_range_count = in_range_count + 1
		end
	end
	return in_range_count
end

--- @description Find the point in range of the most nanobots and return its distance to the origin.
--- @param input string the puzzle input
--- @return number The Manhattan distance of the optimal point to the origin.
function M.part2(input)
	local bots = parse_nanobots(input)

	local min_coord, max_coord = 0, 0
	for _, b in ipairs(bots) do
		min_coord = math.min(min_coord, b.x, b.y, b.z)
		max_coord = math.max(max_coord, b.x, b.y, b.z)
	end

	local size = 1
	while size < (max_coord - min_coord) do
		size = size * 2
	end

	local function box_intersects_bot(box, bot)
		local dist = 0
		if bot.x < box.x then
			dist = dist + (box.x - bot.x)
		elseif bot.x > box.x + box.size - 1 then
			dist = dist + (bot.x - (box.x + box.size - 1))
		end
		if bot.y < box.y then
			dist = dist + (box.y - bot.y)
		elseif bot.y > box.y + box.size - 1 then
			dist = dist + (bot.y - (box.y + box.size - 1))
		end
		if bot.z < box.z then
			dist = dist + (box.z - bot.z)
		elseif bot.z > box.z + box.size - 1 then
			dist = dist + (bot.z - (box.z + box.size - 1))
		end
		return dist <= bot.r
	end

	local pq = PriorityQueue.new()

	local initial_box = { x = min_coord, y = min_coord, z = min_coord, size = size }

	-- Priority for MIN-PQ: {-bots_in_range, dist_to_origin, size}
	-- 1. Maximize bots (minimize -bots)
	-- 2. Minimize distance to origin
	-- 3. Minimize box size (to zoom in)
	pq:push({ -#bots, manhattan({ x = 0, y = 0, z = 0 }, initial_box), size }, initial_box)

	while not pq:is_empty() do
		local box = pq:pop()
		if box.size == 1 then
			return manhattan({ x = 0, y = 0, z = 0 }, box)
		end

		local new_size = math.floor(box.size / 2)
		for dx = 0, 1 do
			for dy = 0, 1 do
				for dz = 0, 1 do
					local sub_box = {
						x = box.x + dx * new_size,
						y = box.y + dy * new_size,
						z = box.z + dz * new_size,
						size = new_size,
					}

					local bot_count = 0
					for _, bot in ipairs(bots) do
						if box_intersects_bot(sub_box, bot) then
							bot_count = bot_count + 1
						end
					end

					local dist_origin = 0
					if 0 < sub_box.x then
						dist_origin = dist_origin + sub_box.x
					elseif 0 > sub_box.x + new_size - 1 then
						dist_origin = dist_origin - (sub_box.x + new_size - 1)
					end
					if 0 < sub_box.y then
						dist_origin = dist_origin + sub_box.y
					elseif 0 > sub_box.y + new_size - 1 then
						dist_origin = dist_origin - (sub_box.y + new_size - 1)
					end
					if 0 < sub_box.z then
						dist_origin = dist_origin + sub_box.z
					elseif 0 > sub_box.z + new_size - 1 then
						dist_origin = dist_origin - (sub_box.z + new_size - 1)
					end

					pq:push({ -bot_count, dist_origin, new_size }, sub_box)
				end
			end
		end
	end

	return -1 -- Should not be reached
end

return M
