--- @title: Day 22: Grid Computing ---
local util = require("util")

local M = {}

--- @description: Count viable pairs of nodes for data movement
--- @param input string: The entire input file content
--- @return number: Number of viable pairs
function M.part1(input)
	local lines = util.read_lines(input)
	local nodes = {}
	for i = 3, #lines do
		local line = lines[i]
		if line and line ~= "" then
			local parts = {}
			for part in line:gmatch("%S+") do
				table.insert(parts, part)
			end
			if #parts >= 5 and parts[1]:match("/dev/grid/node") then
				local fs = parts[1]
				local x, y = fs:match("node%-x(%d+)%-y(%d+)")
				local size = parts[2]:match("(%d+)")
				local used = parts[3]:match("(%d+)")
				local avail = parts[4]:match("(%d+)")
				if x and y and size and used and avail then
					nodes[string.format("%d,%d", x, y)] = {
						size = tonumber(size),
						used = tonumber(used),
						avail = tonumber(avail),
					}
				end
			end
		end
	end

	local count = 0
	for k1, n1 in pairs(nodes) do
		if n1.used > 0 then
			for k2, n2 in pairs(nodes) do
				if k1 ~= k2 and n1.used <= n2.avail then
					count = count + 1
				end
			end
		end
	end
	return count
end

--- @description: Find minimum steps to move goal data to (0,0)
--- @param input string: The entire input file content
--- @return number: Minimum number of steps
function M.part2(input)
	local lines = util.read_lines(input)
	local nodes = {}
	local max_x = 0
	local max_y = 0
	local empty_x, empty_y

	for i = 3, #lines do
		local line = lines[i]
		if line and line ~= "" then
			local parts = {}
			for part in line:gmatch("%S+") do
				table.insert(parts, part)
			end
			if #parts >= 5 and parts[1]:match("/dev/grid/node") then
				local fs = parts[1]
				local x, y = fs:match("node%-x(%d+)%-y(%d+)")
				local size = parts[2]:match("(%d+)")
				local used = parts[3]:match("(%d+)")
				local avail = parts[4]:match("(%d+)")
				if x and y and size and used and avail then
					x = tonumber(x)
					y = tonumber(y)
					nodes[string.format("%d,%d", x, y)] = {
						size = tonumber(size),
						used = tonumber(used),
						avail = tonumber(avail),
					}
					if max_x < x then
						max_x = x
					end
					if max_y < y then
						max_y = y
					end
					if tonumber(used) == 0 then
						empty_x = x
						empty_y = y
					end
				end
			end
		end
	end

	-- Find walls: nodes with size > 500
	local walls = {}
	for k, n in pairs(nodes) do
		if n.size > 500 then
			walls[k] = true
		end
	end

	-- BFS to find distances from empty
	local distance_from_empty = {}
	local queue = { { x = empty_x, y = empty_y, dist = 0 } }
	local visited = {}
	visited[string.format("%d,%d", empty_x, empty_y)] = true

	while #queue > 0 do
		local curr = table.remove(queue, 1)
		local key = string.format("%d,%d", curr.x, curr.y)
		if not distance_from_empty[key] then
			distance_from_empty[key] = curr.dist

			-- Check adjacent positions
			local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
			for _, dir in ipairs(dirs) do
				local nx = curr.x + dir[1]
				local ny = curr.y + dir[2]
				local nkey = string.format("%d,%d", nx, ny)
				if nodes[nkey] and not walls[nkey] and not visited[nkey] then
					visited[nkey] = true
					table.insert(queue, { x = nx, y = ny, dist = curr.dist + 1 })
				end
			end
		end
	end

	-- Distance to beside goal
	local distance_to_goal = distance_from_empty[string.format("%d,%d", max_x - 1, 0)]

	-- Distance to move goal to zero: 5 steps per move except last costs 1
	local distance_to_zero = 5 * (max_x - 1) + 1

	return distance_to_goal + distance_to_zero
end

return M
