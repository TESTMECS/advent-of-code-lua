--- @title: --- Day 9: All in a Single Night ---
--- @description: After creating the city list and distances then we can simply visit all paths and find the max and min approaches.
local M = {}

--- @function: Parse input
--- @param input string
--- @return table city_list, table dist: dist distances between cities in matching index
local function parse_input(input)
	local cities = {}
	local dist = {}
	for line in input:gmatch("[^\n]+") do
		local a, b, d = line:match("(%w+) to (%w+) = (%d+)")
		if a and b and d then
			cities[a] = true
			cities[b] = true
			dist[a] = dist[a] or {}
			dist[a][b] = tonumber(d)
			dist[b] = dist[b] or {}
			dist[b][a] = tonumber(d)
		end
	end
	local city_list = {}
	for c in pairs(cities) do
		table.insert(city_list, c)
	end
	return city_list, dist
end

--- @function: Find the min and max distances
--- @param city_list table
--- @param dist table
--- @return number min_dist, number max_dist
local function find_extremes(city_list, dist)
	local min_dist = math.huge
	local max_dist = -math.huge
	local function recurse(current, visited, path_len, distance)
		if path_len == #city_list then
			if distance < min_dist then
				min_dist = distance
			end
			if distance > max_dist then
				max_dist = distance
			end
			return
		end
		for _, next_city in ipairs(city_list) do
			if not visited[next_city] then
				visited[next_city] = true
				recurse(next_city, visited, path_len + 1, distance + dist[current][next_city])
				visited[next_city] = false
			end
		end
	end
	for _, start in ipairs(city_list) do
		local visited = {}
		visited[start] = true
		recurse(start, visited, 1, 0)
	end
	return min_dist, max_dist
end

--- @description: Day 9 part 1 find shortest distance
--- @param input string
--- @return number
function M.part1(input)
	local city_list, dist = parse_input(input)
	local min_d, _ = find_extremes(city_list, dist)
	return min_d
end

--- @description: Day 9 part 2 find longest distance
--- @param input string
--- @return number
function M.part2(input)
	local city_list, dist = parse_input(input)
	local _, max_d = find_extremes(city_list, dist)
	return max_d
end

return M
