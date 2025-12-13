--- @title: Day 10: The Stars Align ---
local M = {}
local util = require("util")

--- @description: Finds the grid of points when they form the message
--- @param input string: the puzzle input
--- @return string: the grid as a string
function M.part1(input)
	local lines = util.read_lines(input)
	local points = {}
	for _, line in ipairs(lines) do
		local px, py, vx, vy = line:match("position=< *(-?%d+), *(-?%d+)> velocity=< *(-?%d+), *(-?%d+)>")
		table.insert(points, { x = tonumber(px), y = tonumber(py), vx = tonumber(vx), vy = tonumber(vy) })
	end
	local time = 0
	local min_height = math.huge
	local best_positions = {}
	while true do
		local min_y = math.huge
		local max_y = -math.huge
		for _, p in ipairs(points) do
			if p.y < min_y then
				min_y = p.y
			end
			if p.y > max_y then
				max_y = p.y
			end
		end
		local height = max_y - min_y
		if height < min_height then
			min_height = height
			best_positions = {}
			for _, p in ipairs(points) do
				table.insert(best_positions, { x = p.x, y = p.y })
			end
		else
			break
		end
		for _, p in ipairs(points) do
			p.x = p.x + p.vx
			p.y = p.y + p.vy
		end
		time = time + 1
	end
	local min_x = math.huge
	local max_x = -math.huge
	local min_y = math.huge
	local max_y = -math.huge
	for _, p in ipairs(best_positions) do
		if p.x < min_x then
			min_x = p.x
		end
		if p.x > max_x then
			max_x = p.x
		end
		if p.y < min_y then
			min_y = p.y
		end
		if p.y > max_y then
			max_y = p.y
		end
	end
	local positions = {}
	for _, p in ipairs(best_positions) do
		positions[p.y .. "," .. p.x] = true
	end
	local result = ""
	for y = min_y, max_y do
		for x = min_x, max_x do
			if positions[y .. "," .. x] then
				result = result .. "#"
			else
				result = result .. "."
			end
		end
		result = result .. "\n"
	end
	return result
end

--- @description: Finds the time when the points form the message
--- @param input string: the puzzle input
--- @return number: the time in seconds
function M.part2(input)
	local lines = util.read_lines(input)
	local points = {}
	for _, line in ipairs(lines) do
		local px, py, vx, vy = line:match("position=< *(-?%d+), *(-?%d+)> velocity=< *(-?%d+), *(-?%d+)>")
		table.insert(points, { x = tonumber(px), y = tonumber(py), vx = tonumber(vx), vy = tonumber(vy) })
	end
	local time = 0
	local min_height = math.huge
	local best_time = 0
	while true do
		local min_y = math.huge
		local max_y = -math.huge
		for _, p in ipairs(points) do
			if p.y < min_y then
				min_y = p.y
			end
			if p.y > max_y then
				max_y = p.y
			end
		end
		local height = max_y - min_y
		if height < min_height then
			min_height = height
			best_time = time
		else
			break
		end
		for _, p in ipairs(points) do
			p.x = p.x + p.vx
			p.y = p.y + p.vy
		end
		time = time + 1
	end
	return best_time
end

return M
