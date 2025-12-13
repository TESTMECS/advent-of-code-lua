--- @title: Day 16: Proboscidea Volcanium
local M = {}

local function parse_input(input)
	local valves = {}
	local graph = {}
	for line in input:gmatch("[^\n]+") do
		local name, flow, tunnels = line:match("Valve (%w+) has flow rate=(%d+); tunnels? leads? to valves? (.+)")
		flow = tonumber(flow)
		local adj = {}
		for t in tunnels:gmatch("(%w+)") do
			table.insert(adj, t)
		end
		valves[name] = { flow = flow, adj = adj }
		graph[name] = adj
	end
	return valves, graph
end

local function compute_distances(graph, useful)
	local dist = {}
	for _, u in ipairs(useful) do
		dist[u] = {}
		local queue = { { u, 0 } }
		local visited = { [u] = true }
		while #queue > 0 do
			local curr, d = table.unpack(table.remove(queue, 1))
			dist[u][curr] = d
			for _, nei in ipairs(graph[curr]) do
				if not visited[nei] then
					visited[nei] = true
					table.insert(queue, { nei, d + 1 })
				end
			end
		end
	end
	return dist
end

local function get_useful(valves)
	local useful = {}
	for name, v in pairs(valves) do
		if v.flow > 0 or name == "AA" then
			table.insert(useful, name)
		end
	end
	return useful
end

local function get_useful_no_aa(useful)
	local useful_no_aa = {}
	for _, u in ipairs(useful) do
		if u ~= "AA" then
			table.insert(useful_no_aa, u)
		end
	end
	return useful_no_aa
end

local memo = {}

local function get_max(valves, dist, useful_no_aa, mask, curr, time)
	if time <= 0 then
		return 0
	end
	local key = mask .. "," .. curr .. "," .. time
	if memo[key] then
		return memo[key]
	end
	local max_p = 0
	for i, next in ipairs(useful_no_aa) do
		local bit = 1 << (i - 1)
		if (mask & bit) == 0 then
			local d = dist[curr][next]
			if time > d + 1 then
				local new_mask = mask | bit
				local new_time = time - d - 1
				local p = valves[next].flow * new_time + get_max(valves, dist, useful_no_aa, new_mask, next, new_time)
				if p > max_p then
					max_p = p
				end
			end
		end
	end
	memo[key] = max_p
	return max_p
end

--- @description Maximize pressure in 30 minutes
--- @param input string the puzzle input
--- @return number the max pressure
function M.part1(input)
	local valves, graph = parse_input(input)
	local useful = get_useful(valves)
	local dist = compute_distances(graph, useful)
	local useful_no_aa = get_useful_no_aa(useful)
	memo = {}
	return get_max(valves, dist, useful_no_aa, 0, "AA", 30)
end

--- @description Maximize pressure with elephant in 26 minutes each
--- @param input string the puzzle input
--- @return number the max pressure
function M.part2(input)
	local valves, graph = parse_input(input)
	local useful = get_useful(valves)
	local dist = compute_distances(graph, useful)
	local useful_no_aa = get_useful_no_aa(useful)
	local n = #useful_no_aa
	local max_total = 0
	for mask = 0, (1 << n) - 1 do
		memo = {}
		local p1 = get_max(valves, dist, useful_no_aa, mask, "AA", 26)
		local p2 = get_max(valves, dist, useful_no_aa, ((1 << n) - 1) ~ mask, "AA", 26)
		if p1 + p2 > max_total then
			max_total = p1 + p2
		end
	end
	return max_total
end

return M
