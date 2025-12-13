--- @title: Day 25: Four-Dimensional Adventure ---
local M = {}

--- @function: Calculates Manhattan distance between two points.
--- @param p1 table: the first point
--- @param p2 table: the second point
--- @return number: the Manhattan distance
local function manhattan(p1, p2)
	return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y) + math.abs(p1.z - p2.z) + math.abs(p1.w - p2.w)
end

--- @description: Find the number of constellations.
--- @param input string: the puzzle input
--- @return number: The number of constellations.
function M.part1(input)
	local points = {}
	for line in input:gmatch("[^\n]+") do
		local x, y, z, w = line:match("(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
		if x then
			table.insert(points, { x = tonumber(x), y = tonumber(y), z = tonumber(z), w = tonumber(w) })
		end
	end
	local n = #points
	local parent = {}
	for i = 1, n do
		parent[i] = i
	end
	local function find(i)
		if parent[i] ~= i then
			parent[i] = find(parent[i])
		end
		return parent[i]
	end
	local function union(i, j)
		local pi = find(i)
		local pj = find(j)
		if pi ~= pj then
			parent[pi] = pj
		end
	end
	for i = 1, n do
		for j = i + 1, n do
			if manhattan(points[i], points[j]) <= 3 then
				union(i, j)
			end
		end
	end
	local components = {}
	for i = 1, n do
		local p = find(i)
		components[p] = true
	end
	local count = 0
	for _ in pairs(components) do
		count = count + 1
	end
	return count
end

--- @description: Complete the 50 stars.
--- @return string: 0
function M.part2(_)
	return "press the button"
end

return M
