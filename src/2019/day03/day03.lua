--- @title: Day 3: Crossed Wires ---
local M = {}
local util = require("util")

--- @function: manhattan
--- @param p1 table: the first point
--- @param p2 table: the second point
--- @return number: the Manhattan distance
local function manhattan(p1, p2)
	return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

--- @function: parse_input
--- @param input string: the puzzle input
--- @return table: the wires
--- @return table: the wires
local function parse_input(input)
	local lines = util.split(input, "\n")
	local wire1 = util.split(lines[1], ",")
	local wire2 = util.split(lines[2], ",")
	return wire1, wire2
end

--- @function: simulate_wire
--- @param wire table: the wire
--- @return table: the path
local function simulate_wire(wire)
	local path = {}
	local pos = { x = 0, y = 0 }
	local steps = 0
	for _, move in ipairs(wire) do
		local dir = move:sub(1, 1)
		local dist = tonumber(move:sub(2))
		for i = 1, dist do
			if dir == "R" then
				pos.x = pos.x + 1
			elseif dir == "L" then
				pos.x = pos.x - 1
			elseif dir == "U" then
				pos.y = pos.y + 1
			elseif dir == "D" then
				pos.y = pos.y - 1
			end
			steps = steps + 1
			local key = pos.x .. "," .. pos.y
			path[key] = steps
		end
	end
	return path
end

--- @description Find the Manhattan distance from the central port to the closest intersection
--- @param input string the puzzle input
--- @return number the Manhattan distance
function M.part1(input)
	local wire1, wire2 = parse_input(input)
	local path1 = simulate_wire(wire1)
	local visited = {}
	for key in pairs(path1) do
		visited[key] = true
	end
	local path2 = simulate_wire(wire2)
	local min_dist = math.huge
	for key in pairs(path2) do
		if visited[key] then
			local x, y = key:match("([^,]+),([^,]+)")
			x = tonumber(x)
			y = tonumber(y)
			local dist = manhattan({ x = x, y = y }, { x = 0, y = 0 })
			if dist > 0 and dist < min_dist then
				min_dist = dist
			end
		end
	end
	return min_dist
end

--- @description Find the fewest combined steps the wires must take to reach an intersection
--- @param input string the puzzle input
--- @return number the fewest combined steps
function M.part2(input)
	local wire1, wire2 = parse_input(input)
	local path1 = simulate_wire(wire1)
	local path2 = simulate_wire(wire2)
	local min_steps = math.huge
	for key, steps1 in pairs(path1) do
		local steps2 = path2[key]
		if steps2 then
			local total = steps1 + steps2
			if total < min_steps then
				min_steps = total
			end
		end
	end
	return min_steps
end

return M
