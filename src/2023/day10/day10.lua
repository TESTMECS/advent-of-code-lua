--- @title: Day 10: Pipe Maze
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local grid = {}
	local start
	local y = 1
	for line in input:gmatch("[^\n]+") do
		grid[y] = {}
		for x = 1, #line do
			grid[y][x] = line:sub(x, x)
			if grid[y][x] == "S" then
				start = { x, y }
			end
		end
		y = y + 1
	end
	local dirs = {
		N = { 0, -1 },
		S = { 0, 1 },
		E = { 1, 0 },
		W = { -1, 0 },
	}
	local pipes = {
		["|"] = { N = true, S = true },
		["-"] = { E = true, W = true },
		["L"] = { N = true, E = true },
		["J"] = { N = true, W = true },
		["7"] = { S = true, W = true },
		["F"] = { S = true, E = true },
		["."] = {},
		["S"] = { N = true, S = true, E = true, W = true },
	}
	local function valid(x, y)
		return x >= 1 and x <= #grid[1] and y >= 1 and y <= #grid
	end
	local function get_neighbors(x, y)
		local res = {}
		local p = grid[y][x]
		if pipes[p].N and valid(x, y - 1) and pipes[grid[y - 1][x]].S then
			table.insert(res, { x, y - 1 })
		end
		if pipes[p].S and valid(x, y + 1) and pipes[grid[y + 1][x]].N then
			table.insert(res, { x, y + 1 })
		end
		if pipes[p].E and valid(x + 1, y) and pipes[grid[y][x + 1]].W then
			table.insert(res, { x + 1, y })
		end
		if pipes[p].W and valid(x - 1, y) and pipes[grid[y][x - 1]].E then
			table.insert(res, { x - 1, y })
		end
		return res
	end
	local visited = {}
	local queue = { { start[1], start[2], 0 } }
	visited[start[2] .. "," .. start[1]] = true
	local max_dist = 0
	while #queue > 0 do
		local x, y, dist = table.unpack(table.remove(queue, 1))
		max_dist = math.max(max_dist, dist)
		for _, n in ipairs(get_neighbors(x, y)) do
			local nx, ny = n[1], n[2]
			local key = ny .. "," .. nx
			if not visited[key] then
				visited[key] = true
				table.insert(queue, { nx, ny, dist + 1 })
			end
		end
	end
	return max_dist
end

function M.part2(input)
	-- Parse grid and find S
	local grid = {}
	local start
	local y = 1
	for line in input:gmatch("[^\n]+") do
		grid[y] = {}
		for x = 1, #line do
			grid[y][x] = line:sub(x, x)
			if grid[y][x] == "S" then
				start = { x, y }
			end
		end
		y = y + 1
	end
	local H, W = #grid, #grid[1]

	if not start then
		error("Start 'S' not found in input")
	end

	-- Directions and pipe connectivity (same as part1)
	local dirs = { N = { 0, -1 }, S = { 0, 1 }, E = { 1, 0 }, W = { -1, 0 } }
	local opposite = { N = "S", S = "N", E = "W", W = "E" }

	local pipes = {
		["|"] = { N = true, S = true },
		["-"] = { E = true, W = true },
		["L"] = { N = true, E = true },
		["J"] = { N = true, W = true },
		["7"] = { S = true, W = true },
		["F"] = { S = true, E = true },
		["."] = {},
		["S"] = { N = true, S = true, E = true, W = true },
	}

	local function valid(x, y)
		return x >= 1 and x <= W and y >= 1 and y <= H
	end

	-- Build adjacency for all pipe tiles
	local adj = {}
	local function key(x, y)
		return x .. "," .. y
	end

	for yy = 1, H do
		for xx = 1, W do
			local ch = grid[yy][xx]
			if ch and ch ~= "." then
				local k = key(xx, yy)
				adj[k] = adj[k] or {}
				for dir, d in pairs(dirs) do
					if pipes[ch][dir] then
						local nx, ny = xx + d[1], yy + d[2]
						if valid(nx, ny) then
							local nch = grid[ny][nx]
							if nch and pipes[nch][opposite[dir]] then
								table.insert(adj[k], key(nx, ny))
							end
						end
					end
				end
			end
		end
	end

	-- Get component reachable from S (so we only trim within that component)
	local startk = key(start[1], start[2])
	local comp = {}
	local q = { startk }
	comp[startk] = true
	while #q > 0 do
		local kk = table.remove(q, 1)
		for _, nb in ipairs(adj[kk] or {}) do
			if not comp[nb] then
				comp[nb] = true
				table.insert(q, nb)
			end
		end
	end

	-- Leaf-trim to find cycle nodes: remove nodes with degree <= 1 iteratively
	local deg = {}
	for k in pairs(comp) do
		deg[k] = #adj[k]
	end

	local removed = {}
	local trimq = {}
	for k, d in pairs(deg) do
		if d <= 1 then
			table.insert(trimq, k)
		end
	end

	while #trimq > 0 do
		local kk = table.remove(trimq, 1)
		if not removed[kk] then
			removed[kk] = true
			for _, nb in ipairs(adj[kk] or {}) do
				if comp[nb] and not removed[nb] then
					deg[nb] = deg[nb] - 1
					if deg[nb] <= 1 then
						table.insert(trimq, nb)
					end
				end
			end
		end
	end

	-- Nodes that remain in comp and not removed are part of the cycle(s)
	local cycle = {}
	for k in pairs(comp) do
		if not removed[k] then
			cycle[k] = true
		end
	end

	-- EXPANDED GRID (2x): centers at (2*x-1, 2*y-1), edges at +/-1
	local EW, EH = W * 2, H * 2
	local exp = {}
	for ry = 1, EH do
		exp[ry] = {}
		for rx = 1, EW do
			exp[ry][rx] = "."
		end
	end

	-- Mark walls for every pipe tile (all pipes block movement)
	for yy = 1, H do
		for xx = 1, W do
			local ch = grid[yy][xx]
			if ch and ch ~= "." then
				local cx, cy = xx * 2 - 1, yy * 2 - 1
				if cx >= 1 and cx <= EW and cy >= 1 and cy <= EH then
					exp[cy][cx] = "#" -- center
				end
				for dir, d in pairs(dirs) do
					if pipes[ch][dir] then
						local ex, ey = cx + d[1], cy + d[2]
						if ex >= 1 and ex <= EW and ey >= 1 and ey <= EH then
							exp[ey][ex] = "#" -- connection cell
						end
					end
				end
			end
		end
	end

	-- Flood fill from outside border cells (all free border cells)
	local outside = {}
	local borderq = {}
	for rx = 1, EW do
		if exp[1][rx] == "." then
			outside["1," .. rx] = true
			table.insert(borderq, { rx, 1 })
		end
		if exp[EH][rx] == "." then
			outside[EH .. "," .. rx] = true
			table.insert(borderq, { rx, EH })
		end
	end
	for ry = 1, EH do
		if exp[ry][1] == "." then
			outside[ry .. ",1"] = true
			table.insert(borderq, { 1, ry })
		end
		if exp[ry][EW] == "." then
			outside[ry .. "," .. EW] = true
			table.insert(borderq, { EW, ry })
		end
	end

	while #borderq > 0 do
		local p = table.remove(borderq, 1)
		local x, y = p[1], p[2]
		for _, d in pairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
			local nx, ny = x + d[1], y + d[2]
			if nx >= 1 and nx <= EW and ny >= 1 and ny <= EH then
				local k = ny .. "," .. nx
				if not outside[k] and exp[ny][nx] == "." then
					outside[k] = true
					table.insert(borderq, { nx, ny })
				end
			end
		end
	end

	-- Count original tiles that are NOT in the cycle and whose center is NOT reachable from outside
	local count = 0
	for yy = 1, H do
		for xx = 1, W do
			local k = key(xx, yy)
			local cx, cy = xx * 2 - 1, yy * 2 - 1
			local ok = true
			if cycle[k] then
				ok = false
			end
			if outside[cy .. "," .. cx] then
				ok = false
			end
			if ok then
				count = count + 1
			end
		end
	end

	return count
end

return M
