---@title: Day 24: Air Duct Spelunking ---
local util = require("util")
local M = {}

--- @function: Parses the input file into a grid and a list of locations
--- @param input string: The entire input file content
--- @return table: The grid
--- @return table: The locations
local function parse_grid(input)
	local lines = util.read_lines(input)
	local grid = {}
	local locations = {}

	for y, line in ipairs(lines) do
		if line ~= "" then
			grid[y] = {}
			for x = 1, #line do
				local char = line:sub(x, x)
				grid[y][x] = char

				if char:match("%d") then
					locations[tonumber(char)] = { x = x, y = y }
				end
			end
		end
	end

	return grid, locations
end

--- @function: BFS to find the distance from a start location to a goal location
--- @param grid table: The grid
--- @param start table: The start location
--- @param goal table: The goal location
local function bfs_distance(grid, start, goal)
	local queue = { { x = start.x, y = start.y, dist = 0 } }
	local visited = {}
	visited[start.y .. "," .. start.x] = true

	while #queue > 0 do
		local curr = table.remove(queue, 1)

		if curr.x == goal.x and curr.y == goal.y then
			return curr.dist
		end

		local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
		for _, dir in ipairs(dirs) do
			local nx, ny = curr.x + dir[1], curr.y + dir[2]
			local key = ny .. "," .. nx

			if grid[ny] and grid[ny][nx] and grid[ny][nx] ~= "#" and not visited[key] then
				visited[key] = true
				table.insert(queue, { x = nx, y = ny, dist = curr.dist + 1 })
			end
		end
	end

	return math.huge -- unreachable
end

--- @function: Calculates the distances between all locations
--- @param grid table: The grid
--- @param locations table: The locations
--- @return table: The distances
--- @return table: The sorted list of numbers
local function calculate_distances(grid, locations)
	local distances = {}
	local nums = {}

	for num, _ in pairs(locations) do
		table.insert(nums, num)
	end
	table.sort(nums)

	for i = 1, #nums do
		for j = 1, #nums do
			local from, to = nums[i], nums[j]
			if from ~= to then
				distances[from .. "," .. to] = bfs_distance(grid, locations[from], locations[to])
			else
				distances[from .. "," .. to] = 0
			end
		end
	end

	return distances, nums
end

--- @function: TSP using dynamic programming
--- @param distances table: The distances
--- @param nums table: The sorted list of numbers
--- @param start integer: The start location
--- @return integer: The minimum cost
local function tsp_dp(distances, nums, start)
	local n = #nums
	local dp = {}
	local INF = math.huge

	-- Initialize DP table
	for mask = 0, (1 << n) - 1 do
		for i = 1, n do
			dp[mask * n + i] = INF
		end
	end

	-- Find start index
	local start_idx = 1
	for i, num in ipairs(nums) do
		if num == start then
			start_idx = i
			break
		end
	end

	-- Base case: starting from start location
	dp[(1 << (start_idx - 1)) * n + start_idx] = 0

	-- Fill DP table
	for mask = 0, (1 << n) - 1 do
		for i = 1, n do
			local cost = dp[mask * n + i]
			if cost < INF then
				for j = 1, n do
					if mask & (1 << (j - 1)) == 0 then
						local new_mask = mask | (1 << (j - 1))
						local dist = distances[nums[i] .. "," .. nums[j]]
						if dist and dist < INF then
							local new_cost = cost + dist
							local current_cost = dp[new_mask * n + j]
							if new_cost < current_cost then
								dp[new_mask * n + j] = new_cost
							end
						end
					end
				end
			end
		end
	end

	-- Find minimum cost to visit all locations
	local min_cost = INF
	local full_mask = (1 << n) - 1
	for i = 1, n do
		local cost = dp[full_mask * n + i]
		if cost < min_cost then
			min_cost = cost
		end
	end

	return min_cost
end

--- @description: Find shortest path visiting all numbered locations starting from 0
--- @param input string: The entire input file content
--- @return number: Minimum steps required
function M.part1(input)
	local grid, locations = parse_grid(input)
	local distances, nums = calculate_distances(grid, locations)

	-- Find path starting from 0
	return tsp_dp(distances, nums, 0)
end

--- @description: Find shortest path visiting all locations and returning to 0
--- @param input string: The entire input file content
--- @return number: Minimum steps required
function M.part2(input)
	local grid, locations = parse_grid(input)
	local distances, nums = calculate_distances(grid, locations)

	-- For part 2, we need to return to 0
	-- Modify TSP to include return to start
	local n = #nums
	local dp = {}
	local INF = math.huge

	-- Initialize DP table
	for mask = 0, (1 << n) - 1 do
		for i = 1, n do
			dp[mask * n + i] = INF
		end
	end

	-- Find start index
	local start_idx = 1
	for i, num in ipairs(nums) do
		if num == 0 then
			start_idx = i
			break
		end
	end

	-- Base case: starting from location 0
	dp[(1 << (start_idx - 1)) * n + start_idx] = 0

	-- Fill DP table
	for mask = 0, (1 << n) - 1 do
		for i = 1, n do
			local cost = dp[mask * n + i]
			if cost < INF then
				for j = 1, n do
					if mask & (1 << (j - 1)) == 0 then
						local new_mask = mask | (1 << (j - 1))
						local dist = distances[nums[i] .. "," .. nums[j]]
						if dist and dist < INF then
							local new_cost = cost + dist
							local current_cost = dp[new_mask * n + j]
							if new_cost < current_cost then
								dp[new_mask * n + j] = new_cost
							end
						end
					end
				end
			end
		end
	end

	-- Find minimum cost to visit all locations and return to start
	local min_cost = INF
	local full_mask = (1 << n) - 1
	for i = 1, n do
		if nums[i] ~= 0 then -- Don't return to 0 if we're already at 0
			local tsp_cost = dp[full_mask * n + i]
			local return_dist = distances[nums[i] .. ",0"]
			if tsp_cost < INF and return_dist < INF then
				local total_cost = tsp_cost + return_dist
				if total_cost < min_cost then
					min_cost = total_cost
				end
			end
		end
	end

	return min_cost
end

return M
