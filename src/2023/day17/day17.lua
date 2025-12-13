--- @title: --- Day 17: Clumsy Crucible ---
local M = {}

-- Solves the clumsy crucible pathfinding problem using Dijkstra's algorithm.
-- The state in the search is defined by (y, x, direction, consecutive_steps).
local function solve(input, min_straight, max_straight)
	-- 1. Parse the input into a 1-indexed grid of numbers.
	local grid = {}
	do
		local y = 1
		for line in input:gmatch("[^\n]+") do
			grid[y] = {}
			for x = 1, #line do
				grid[y][x] = tonumber(line:sub(x, x))
			end
			y = y + 1
		end
	end

	local rows = #grid
	local cols = #grid[1]

	-- 2. Define directions and their opposites for clear and robust movement logic.
	-- Directions: 1:Right, 2:Down, 3:Left, 4:Up
	-- Deltas are {dy, dx} for grid[y][x] coordinates.
	local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
	local opposites = { [1] = 3, [3] = 1, [2] = 4, [4] = 2 }

	-- 3. Min-priority queue implementation (binary heap).
	local pq = {}
	local function push(item)
		table.insert(pq, item)
		local i = #pq
		while i > 1 do
			local p = math.floor(i / 2)
			if pq[i][1] < pq[p][1] then
				pq[i], pq[p] = pq[p], pq[i]
				i = p
			else
				break
			end
		end
	end

	local function pop()
		if #pq == 0 then
			return nil
		end
		local item = pq[1]
		local last = table.remove(pq)
		if #pq > 0 then
			pq[1] = last
			local i = 1
			local size = #pq
			while true do
				local l, r = i * 2, i * 2 + 1
				local smallest = i
				if l <= size and pq[l][1] < pq[smallest][1] then
					smallest = l
				end
				if r <= size and pq[r][1] < pq[smallest][1] then
					smallest = r
				end
				if smallest ~= i then
					pq[i], pq[smallest] = pq[smallest], pq[i]
					i = smallest
				else
					break
				end
			end
		end
		return item
	end

	-- 4. Set up Dijkstra's algorithm.
	-- The `dist` table stores the minimum heat found to reach a state.
	-- The key is a string "y,x,dir,steps" to uniquely identify a state.
	local dist = {}

	-- Initialize the search from (1,1) by pushing the first two possible moves.
	-- The starting block's heat loss is not incurred.
	-- PQ item format: {heat, y, x, direction_index, steps_in_direction}

	-- Move Right to (1,2)
	local heat_r = grid[1][2]
	push({ heat_r, 1, 2, 1, 1 })
	dist["1,2,1,1"] = heat_r

	-- Move Down to (2,1)
	local heat_d = grid[2][1]
	push({ heat_d, 2, 1, 2, 1 })
	dist["2,1,2,1"] = heat_d

	-- 5. Main Dijkstra loop.
	while #pq > 0 do
		local heat, y, x, dir, steps = table.unpack(pop())

		-- OPTIMIZATION: First time we reach the destination, we're done.
		if y == rows and x == cols and steps >= min_straight then
			return heat
		end

		-- CORRECTION: Skip if we've already found a shorter path to this exact state.
		local key = y .. "," .. x .. "," .. dir .. "," .. steps
		if heat > (dist[key] or math.huge) then
			goto continue
		end

		-- Explore neighbors:
		-- Option A: Continue straight (if allowed).
		if steps < max_straight then
			local dy, dx = table.unpack(dirs[dir])
			local ny, nx = y + dy, x + dx

			if ny >= 1 and ny <= rows and nx >= 1 and nx <= cols then
				local nheat = heat + grid[ny][nx]
				local nsteps = steps + 1
				local nkey = ny .. "," .. nx .. "," .. dir .. "," .. nsteps
				if nheat < (dist[nkey] or math.huge) then
					dist[nkey] = nheat
					push({ nheat, ny, nx, dir, nsteps })
				end
			end
		end

		-- Option B: Turn left or right (if allowed).
		if steps >= min_straight then
			for ndir = 1, 4 do
				if ndir ~= dir and ndir ~= opposites[dir] then -- Not straight, not reverse
					local dy, dx = table.unpack(dirs[ndir])
					local ny, nx = y + dy, x + dx

					if ny >= 1 and ny <= rows and nx >= 1 and nx <= cols then
						local nheat = heat + grid[ny][nx]
						local nsteps = 1
						local nkey = ny .. "," .. nx .. "," .. ndir .. "," .. nsteps
						if nheat < (dist[nkey] or math.huge) then
							dist[nkey] = nheat
							push({ nheat, ny, nx, ndir, nsteps })
						end
					end
				end
			end
		end
		::continue::
	end

	return -1 -- Should not be reached for valid puzzle inputs
end

--- @description Calculates the least heat loss for the crucible to reach the factory, moving at most three blocks in a single direction before turning.
--- @param input string the puzzle input
--- @return number The minimum heat loss incurred.
function M.part1(input)
	-- Min straight moves: 1 (implicit), Max straight moves: 3
	return solve(input, 1, 3)
end

--- @description Calculates the least heat loss for the ultra crucible, which must move at least four and at most ten blocks in a single direction.
--- @param input string the puzzle input
--- @return number The minimum heat loss incurred for the ultra crucible.
function M.part2(input)
	-- Min straight moves: 4, Max straight moves: 10
	return solve(input, 4, 10)
end

return M
