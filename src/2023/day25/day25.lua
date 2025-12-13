--- @title: --- Day 25: Snowverload ---
local M = {}

--- @description Find the product of the sizes of the two groups after removing the three wires with the minimum cut
--- @param input string the puzzle input
--- @return number the product of the group sizes
function M.part1(input)
	-- Parse graph into adjacency
	local graph = {}
	for line in input:gmatch("[^\n]+") do
		local node, rest = line:match("^(%w+):%s*(.*)")
		graph[node] = graph[node] or {}
		for neigh in rest:gmatch("%S+") do
			graph[neigh] = graph[neigh] or {}
			table.insert(graph[node], neigh)
			table.insert(graph[neigh], node)
		end
	end

	-- Assign integer ids for compact storage
	local id, rev, n = {}, {}, 0
	for node in pairs(graph) do
		n = n + 1
		id[node] = n
		rev[n] = node
	end

	-- Build capacity matrix
	local capacity = {}
	for i = 1, n do
		capacity[i] = {}
	end
	for u, adj in pairs(graph) do
		local ui = id[u]
		for _, v in ipairs(adj) do
			local vi = id[v]
			capacity[ui][vi] = 1
		end
	end

	-- Max-flow (Edmonds–Karp, optimized)
	local function max_flow(s, t)
		-- residual = copy of capacity
		local res = {}
		for i = 1, n do
			res[i] = {}
			for j, cap in pairs(capacity[i]) do
				res[i][j] = cap
			end
		end

		local flow = 0
		local parent = {}

		local function bfs()
			local q, head, tail = { s }, 1, 1
			local visited = { [s] = true }
			parent[s] = -1
			while head <= tail do
				local u = q[head]
				head = head + 1
				for v, cap in pairs(res[u]) do
					if not visited[v] and cap > 0 then
						visited[v] = true
						parent[v] = u
						tail = tail + 1
						q[tail] = v
						if v == t then
							return true
						end
					end
				end
			end
			return false
		end

		while bfs() do
			local path_flow = math.huge
			local v = t
			while v ~= s do
				local u = parent[v]
				path_flow = math.min(path_flow, res[u][v])
				v = u
			end
			v = t
			while v ~= s do
				local u = parent[v]
				res[u][v] = res[u][v] - path_flow
				res[v][u] = (res[v][u] or 0) + path_flow
				v = u
			end
			flow = flow + path_flow
			if flow > 3 then
				break
			end -- prune
		end

		return flow, res
	end

	-- Pick arbitrary source
	local nodes = {}
	for node in pairs(graph) do
		table.insert(nodes, node)
	end
	local source = id[nodes[1]]

	local cut_residual = nil
	local sink_found = nil
	for i = 2, #nodes do
		local sink = id[nodes[i]]
		local f, res = max_flow(source, sink)
		if f == 3 then
			cut_residual = res
			sink_found = sink
			break
		end
	end

	-- BFS on residual to find partition
	local visited = {}
	local q, head, tail = { source }, 1, 1
	visited[source] = true
	while head <= tail do
		local u = q[head]
		head = head + 1
		for v, cap in pairs(cut_residual[u]) do
			if cap > 0 and not visited[v] then
				visited[v] = true
				tail = tail + 1
				q[tail] = v
			end
		end
	end

	local group1, total = 0, 0
	for i = 1, n do
		total = total + 1
		if visited[i] then
			group1 = group1 + 1
		end
	end
	local group2 = total - group1
	return group1 * group2
end

--- @description No part 2 for day 25
--- @param input string the puzzle input
--- @return number 0
function M.part2(input)
	return 0
end

return M
