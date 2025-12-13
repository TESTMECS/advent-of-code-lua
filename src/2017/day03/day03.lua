---@title: Day 3: Spiral Memory ---
local M = {}

--- @description Calculate Manhattan distance from square 1 to the given square in spiral memory
--- @param input string the square number as a string
--- @return number the distance
function M.part1(input)
	local n = tonumber(input:match("%d+"))
	if n == 1 then
		return 0
	end
	-- Find the layer k where the square is located
	local k = 0
	while (2 * k + 1) ^ 2 < n do
		k = k + 1
	end
	-- The max in this layer
	local max_in_layer = (2 * k + 1) ^ 2
	-- The side length
	local side = 2 * k
	-- Distance from the center of the side
	local dist_from_center = math.abs((max_in_layer - n) % side - k)
	-- Total distance is layer + dist_from_center
	return k + dist_from_center
end

--- @description Find the first value in spiral memory that is larger than the input
--- @param input string the target value as a string
--- @return number the first value larger than input
function M.part2(input)
	local target = tonumber(input:match("%d+"))
	local grid = {}
	local function get(x, y)
		local key = x .. "," .. y
		return grid[key] or 0
	end
	local function set(x, y, val)
		local key = x .. "," .. y
		grid[key] = val
	end
	-- Start at 1
	set(0, 0, 1)
	if target < 1 then
		return 1
	end
	local x, y = 0, 0
	local directions = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } } -- right, up, left, down
	local dir = 1 -- start with right
	local steps = 1
	local step_count = 0
	local turn_count = 0
	while true do
		-- Move in current direction
		x = x + directions[dir][1]
		y = y + directions[dir][2]
		step_count = step_count + 1
		-- Calculate value as sum of neighbors
		local val = get(x - 1, y)
			+ get(x + 1, y)
			+ get(x, y - 1)
			+ get(x, y + 1)
			+ get(x - 1, y - 1)
			+ get(x - 1, y + 1)
			+ get(x + 1, y - 1)
			+ get(x + 1, y + 1)
		set(x, y, val)
		if val > target then
			return val
		end
		-- Check if need to turn
		if step_count == steps then
			dir = dir % 4 + 1
			step_count = 0
			turn_count = turn_count + 1
			if turn_count % 2 == 0 then
				steps = steps + 1
			end
		end
	end
end

return M
