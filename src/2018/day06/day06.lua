--- @title: Day 06: Chronal Coordinates ---
local M = {}
local util = require("util")

--- @description: Finds the size of the largest finite area closest to a coordinate
--- @param input string: the puzzle input
--- @return number: the size of the largest area
function M.part1(input)
	local lines = util.read_lines(input)
	local points = {}
	local min_x, max_x = math.huge, -math.huge
	local min_y, max_y = math.huge, -math.huge
	for _, line in ipairs(lines) do
		local x, y = line:match("(%d+), (%d+)")
		x, y = tonumber(x), tonumber(y)
		table.insert(points, { x = x, y = y })
		min_x = math.min(min_x, x)
		max_x = math.max(max_x, x)
		min_y = math.min(min_y, y)
		max_y = math.max(max_y, y)
	end
	local function get_closest(x, y)
		local min_dist = math.huge
		local closest = nil
		local tie = false
		for i, p in ipairs(points) do
			local dist = math.abs(x - p.x) + math.abs(y - p.y)
			if dist < min_dist then
				min_dist = dist
				closest = i
				tie = false
			elseif dist == min_dist then
				tie = true
			end
		end
		if tie then
			return nil
		end
		return closest
	end
	local infinite = {}
	for x = min_x, max_x do
		local c = get_closest(x, min_y)
		if c then
			infinite[c] = true
		end
		c = get_closest(x, max_y)
		if c then
			infinite[c] = true
		end
	end
	for y = min_y, max_y do
		local c = get_closest(min_x, y)
		if c then
			infinite[c] = true
		end
		c = get_closest(max_x, y)
		if c then
			infinite[c] = true
		end
	end
	local areas = {}
	for i = 1, #points do
		if not infinite[i] then
			areas[i] = 0
		end
	end
	for x = min_x, max_x do
		for y = min_y, max_y do
			local c = get_closest(x, y)
			if c and not infinite[c] then
				areas[c] = areas[c] + 1
			end
		end
	end
	local max_area = 0
	for _, area in pairs(areas) do
		if area > max_area then
			max_area = area
		end
	end
	return max_area
end

--- @description: Counts points where sum of distances to all coordinates is less than 10000
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local lines = util.read_lines(input)
	local points = {}
	local min_x, max_x = math.huge, -math.huge
	local min_y, max_y = math.huge, -math.huge
	for _, line in ipairs(lines) do
		local x, y = line:match("(%d+), (%d+)")
		x, y = tonumber(x), tonumber(y)
		table.insert(points, { x = x, y = y })
		min_x = math.min(min_x, x)
		max_x = math.max(max_x, x)
		min_y = math.min(min_y, y)
		max_y = math.max(max_y, y)
	end
	local count = 0
	local margin = 100 -- to cover the area
	for x = min_x - margin, max_x + margin do
		for y = min_y - margin, max_y + margin do
			local sum = 0
			for _, p in ipairs(points) do
				sum = sum + math.abs(x - p.x) + math.abs(y - p.y)
			end
			if sum < 10000 then
				count = count + 1
			end
		end
	end
	return count
end

return M
