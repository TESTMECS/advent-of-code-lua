--- @title: Day 11: Passage Pathing ---
local M = {}

--- @description: Parses the input into an adjacency list graph.
--- @param input string: The puzzle input.
--- @return table: The graph.
local function parse_graph(input)
	local graph = {}
	for line in input:gmatch("[^\r\n]+") do
		local a, b = line:match("([^-]+)-([^-]+)")
		graph[a] = graph[a] or {}
		graph[b] = graph[b] or {}
		table.insert(graph[a], b)
		table.insert(graph[b], a)
	end
	return graph
end

--- @description: Checks if a cave name is for a small cave (all lowercase).
--- @param cave string: The name of the cave.
--- @return boolean: True if the cave is small.
local function is_small(cave)
	return cave:match("^[a-z]+$")
end

--- @description: Count the number of paths from start to end visiting small caves at most once.
function M.part1(input)
	local graph = parse_graph(input)
	local path_count = 0

	-- visited is a set (table with boolean values)
	local function dfs(current_cave, visited)
		if current_cave == "end" then
			path_count = path_count + 1
			return
		end

		for _, neighbor in ipairs(graph[current_cave]) do
			if not (is_small(neighbor) and visited[neighbor]) then
				-- Standard DFS: modify state, recurse, then backtrack.
				visited[neighbor] = true
				dfs(neighbor, visited)
				visited[neighbor] = nil -- Backtrack
			end
		end
	end

	dfs("start", { start = true })
	return path_count
end

--- @description: Count paths allowing one small cave to be visited twice.
function M.part2(input)
	local graph = parse_graph(input)
	local path_count = 0

	-- visited is a set (table with boolean values)
	-- has_doubled is a boolean flag for the current path
	local function dfs(current_cave, visited, has_doubled)
		if current_cave == "end" then
			path_count = path_count + 1
			return
		end

		for _, neighbor in ipairs(graph[current_cave]) do
			if neighbor == "start" then
				-- We never revisit 'start'
				goto continue
			end

			if not is_small(neighbor) then
				-- Big caves can always be visited.
				dfs(neighbor, visited, has_doubled)
			else
				-- Logic for small caves
				if not visited[neighbor] then
					-- First time visiting this small cave. Mark, recurse, backtrack.
					visited[neighbor] = true
					dfs(neighbor, visited, has_doubled)
					visited[neighbor] = nil -- Backtrack
				elseif not has_doubled then
					-- This is a small cave we've seen before, but we haven't
					-- used our double-visit yet. Use it now.
					-- We don't need to modify/backtrack 'visited' because we are
					-- just passing a new 'true' value for has_doubled.
					dfs(neighbor, visited, true)
				end
			end
			::continue::
		end
	end

	dfs("start", { start = true }, false)
	return path_count
end

return M
