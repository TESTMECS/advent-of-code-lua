--- @title: Day 12: Digital Plumber ---
local M = {}
local util = require("util")

--- @description: Count programs in group containing program 0
--- @param input string: the program connections
--- @return table
local function parse_input(input)
	local graph = {}
	local lines = util.read_lines(input)

	for _, line in ipairs(lines) do
		-- normalize
		line = line:gsub("\r", ""):gsub("^%s+", ""):gsub("%s+$", "")

		local program_id_str, connections_str = line:match("(%d+)%s*<%-%>%s*(.+)")
		if not program_id_str then
			print("NO MATCH:", line)
		else
			local program_id = tonumber(program_id_str)
			graph[program_id] = graph[program_id] or {}

			for conn_str in connections_str:gmatch("%d+") do
				local connected_program_id = tonumber(conn_str)
				table.insert(graph[program_id], connected_program_id)

				-- bidirectional
				graph[connected_program_id] = graph[connected_program_id] or {}
				table.insert(graph[connected_program_id], program_id)
			end
		end
	end
	return graph
end

--- @function: Breadth-first search
--- @param graph table: the graph
--- @param start_node number: the start node
--- @param visited table: the visited nodes
--- @return number: the number of nodes visited
local function bfs(graph, start_node, visited)
	local queue = { start_node }
	visited[start_node] = true
	local count = 0

	local head = 1
	while head <= #queue do
		local current_node = queue[head]
		head = head + 1
		count = count + 1

		for _, neighbor in ipairs(graph[current_node] or {}) do
			if not visited[neighbor] then
				visited[neighbor] = true
				table.insert(queue, neighbor)
			end
		end
	end
	return count
end

--- @description: Count programs in group containing program 0
--- @param input string: the program connections
--- @return number: the count
function M.part1(input)
	local graph = parse_input(input)
	local visited = {}
	return bfs(graph, 0, visited)
end

--- @description: Count the number of groups
--- @param input string: the program connections
--- @return number: the number of groups
--- @todo:
function M.part2(input)
	local graph = parse_input(input)
	local visited = {}
	local group_count = 0

	-- Find the maximum program ID to iterate through all possible programs
	local max_program_id = 0
	for id, _ in pairs(graph) do
		if id > max_program_id then
			max_program_id = id
		end
	end

	for i = 0, max_program_id do
		if graph[i] and not visited[i] then -- Check if program exists and hasn't been visited
			group_count = group_count + 1
			bfs(graph, i, visited)
		end
	end
	return group_count
end

return M
