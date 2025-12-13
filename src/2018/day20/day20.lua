--- @title: Day 20: A Regular Map
local M = {}

--- @description: Parses the input into a map of doors
--- @param input string: the puzzle input
--- @return table: the doors
local function parse(input)
	local regex = input:match("^(.*)$")
	local doors = {}
	local stack = {}
	local x, y = 0, 0
	local i = 1
	while i <= #regex do
		local c = regex:sub(i, i)
		if c == "N" then
			doors[y .. "," .. x .. ",N"] = true
			y = y - 1
		elseif c == "S" then
			doors[y .. "," .. x .. ",S"] = true
			y = y + 1
		elseif c == "E" then
			doors[y .. "," .. x .. ",E"] = true
			x = x + 1
		elseif c == "W" then
			doors[y .. "," .. x .. ",W"] = true
			x = x - 1
		elseif c == "(" then
			table.insert(stack, { x, y })
		elseif c == "|" then
			local pos = stack[#stack]
			x, y = pos[1], pos[2]
		elseif c == ")" then
			local pos = table.remove(stack)
			x, y = pos[1], pos[2]
		end
		i = i + 1
	end
	return doors
end

--- @description: Gets the neighbors of a given position
--- @param x number: the x coordinate
--- @param y number: the y coordinate
--- @param doors table: the doors
--- @return table: the neighbors
local function get_neighbors(x, y, doors)
	local neighbors = {}
	if doors[y .. "," .. x .. ",N"] then
		table.insert(neighbors, { x, y - 1 })
	end
	if doors[y .. "," .. x .. ",S"] then
		table.insert(neighbors, { x, y + 1 })
	end
	if doors[y .. "," .. x .. ",E"] then
		table.insert(neighbors, { x + 1, y })
	end
	if doors[y .. "," .. x .. ",W"] then
		table.insert(neighbors, { x - 1, y })
	end
	return neighbors
end

--- @function: Calculates the distances from the starting position
--- @param doors table: the doors
--- @return number: the max distance
--- @return number: the count of rooms with distance >= 1000
local function distances(doors)
	local queue = { { 0, 0, 0 } } -- x, y, d
	local visited = {}
	visited["0,0"] = true
	local max_d = 0
	local count_1000 = 0
	while #queue > 0 do
		local curr = table.remove(queue, 1)
		local x, y, d = curr[1], curr[2], curr[3]
		visited[y .. "," .. x] = true
		max_d = math.max(max_d, d)
		if d >= 1000 then
			count_1000 = count_1000 + 1
		end
		for _, n in ipairs(get_neighbors(x, y, doors)) do
			local nx, ny = n[1], n[2]
			local key = ny .. "," .. nx
			if not visited[key] then
				visited[key] = true
				table.insert(queue, { nx, ny, d + 1 })
			end
		end
	end
	return max_d, count_1000
end

--- @description: Finds the max distance
--- @param input string: the puzzle input
--- @return number: the max distance
function M.part1(input)
	local doors = parse(input)
	local max_d, _ = distances(doors)
	return max_d
end

--- @description: Counts rooms with distance >=1000
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local doors = parse(input)
	local _, count = distances(doors)
	return count
end

return M
