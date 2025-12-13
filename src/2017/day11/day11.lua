--- @title: Day 11: Hex Ed ---
local M = {}

--- @description: Calculate the shortest path distance to the end position
--- @param input string: the comma-separated directions
--- @return number: the distance
function M.part1(input)
	local dirs = {
		n = { 0, -1 },
		ne = { 1, -1 },
		se = { 1, 0 },
		s = { 0, 1 },
		sw = { -1, 1 },
		nw = { -1, 0 },
	}

	local q, r = 0, 0
	for dir in input:gmatch("%w+") do
		local dq, dr = table.unpack(dirs[dir])
		q = q + dq
		r = r + dr
	end

	local distance = (math.abs(q) + math.abs(r) + math.abs(-q - r)) / 2
	return distance
end

--- @description: Find the maximum distance reached during the path
--- @param input string: the comma-separated directions
--- @return number: the max distance
function M.part2(input)
	local dirs = {
		n = { 0, -1 },
		ne = { 1, -1 },
		se = { 1, 0 },
		s = { 0, 1 },
		sw = { -1, 1 },
		nw = { -1, 0 },
	}

	local q, r = 0, 0
	local max_dist = 0
	for dir in input:gmatch("%w+") do
		local dq, dr = table.unpack(dirs[dir])
		q = q + dq
		r = r + dr
		local dist = (math.abs(q) + math.abs(r) + math.abs(-q - r)) / 2
		if dist > max_dist then
			max_dist = dist
		end
	end

	return max_dist
end

return M
