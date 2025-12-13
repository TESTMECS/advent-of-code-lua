--- @title: --- Day 21: Step Counter ---
local M = {}

--- @description Parses the input into a 2D map and finds the start position
--- @param input string: the puzzle input
--- @return table: 2D map, number: start x, number: start y
local function read_map(input)
	local map = {}
	local sx, sy
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for i = 1, #line do
			local char = line:sub(i, i)
			if char == "S" then
				sx, sy = #map + 1, i
				char = "."
			end
			table.insert(row, char)
		end
		table.insert(map, row)
	end
	return map, sx, sy
end

--- @description Performs BFS to count reachable positions after max_steps
--- @param map table: 2D grid
--- @param sx number: start x
--- @param sy number: start y
--- @param max_steps number: maximum steps
--- @return number: count of reachable positions
local function bfs(map, sx, sy, max_steps)
	local dirs = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } }
	local q = { { sx, sy } }
	local step = 0
	while step < max_steps do
		local next_q = {}
		local vis = {}
		while #q > 0 do
			local curr = table.remove(q)
			local x, y = curr[1], curr[2]
			for _, d in ipairs(dirs) do
				local nx, ny = x + d[1], y + d[2]
				if nx >= 1 and nx <= #map and ny >= 1 and ny <= #map[1] then
					local key = nx .. "," .. ny
					if not vis[key] and map[nx][ny] == "." then
						vis[key] = true
						table.insert(next_q, { nx, ny })
					end
				end
			end
		end
		q = next_q
		step = step + 1
	end
	return #q
end

--- @description Counts garden plots reachable in exactly 64 steps
--- @param input string: the puzzle input
--- @return number: number of reachable plots
function M.part1(input)
	local map, sx, sy = read_map(input)
	return bfs(map, sx, sy, 64)
end

--- @description Computes reachable plots in infinite grid after 26501365 steps using grid repetition formula
--- @param input string: the puzzle input
--- @return number: total reachable plots
function M.part2(input)
	local grid = {}
	local sx, sy = 1, 1
	local s = {}

	-- Parse input into grid and find start
	for line in input:gmatch("[^\n]+") do
		local row = {}
		sy = 1
		for cell in line:gmatch("(%S)") do
			if cell == "S" then
				cell = "."
				s = { sx, sy }
			end
			table.insert(row, cell)
			sy = sy + 1
		end
		sx = sx + 1
		table.insert(grid, row)
	end

	local max_s = 26501365

	--- @description BFS to count reachable positions with correct parity
	--- @param pos table: {x, y}
	--- @param steps number: total steps
	--- @return number: count
	local function count_reach(pos, steps)
		local cnt = 0
		local vis = {}
		local key = function(p)
			return p[1] .. "|" .. p[2]
		end
		local q = { { pos, 0 } }
		while #q > 0 do
			local item = table.remove(q, 1)
			local p, st = item[1], item[2]
			if (steps - st) % 2 == 0 then
				local k = key(p)
				if vis[k] then
					goto continue
				end
				vis[k] = true
				cnt = cnt + 1
			end
			if st == steps then
				goto continue
			end
			local x, y = p[1], p[2]
			for _, d in ipairs({ -1, 1 }) do
				if grid[x + d] and grid[x + d][y] == "." then
					table.insert(q, { { x + d, y }, st + 1 })
				end
				if grid[x] and grid[x][y + d] == "." then
					table.insert(q, { { x, y + d }, st + 1 })
				end
			end
			::continue::
		end
		return cnt
	end

	-- Calculate grid size and counts for infinite grid formula
	local grid_sz = max_s // #grid - 1
	local odd_cnt = (grid_sz // 2 * 2 + 1) ^ 2
	local even_cnt = ((grid_sz + 1) // 2 * 2) ^ 2
	local odd_full = count_reach(s, #grid * 2 + 1)
	local even_full = count_reach(s, #grid * 2)
	local sides = count_reach({ #grid, s[2] }, #grid - 1)
		+ count_reach({ s[1], 1 }, #grid - 1)
		+ count_reach({ 1, s[2] }, #grid - 1)
		+ count_reach({ s[1], #grid }, #grid - 1)
	local small_sec = count_reach({ #grid, 1 }, #grid // 2 - 1)
		+ count_reach({ #grid, #grid }, #grid // 2 - 1)
		+ count_reach({ 1, 1 }, #grid // 2 - 1)
		+ count_reach({ 1, #grid }, #grid // 2 - 1)
	local large_sec = count_reach({ #grid, 1 }, #grid * 3 // 2 - 1)
		+ count_reach({ #grid, #grid }, #grid * 3 // 2 - 1)
		+ count_reach({ 1, 1 }, #grid * 3 // 2 - 1)
		+ count_reach({ 1, #grid }, #grid * 3 // 2 - 1)

	-- Apply formula for infinite grid
	local res = odd_cnt * odd_full + even_cnt * even_full + sides + (grid_sz + 1) * small_sec + grid_sz * large_sec
	return math.ceil(res)
end

return M
