--- @title: Day 12: Rain Risk ---
local M = {}
local util = require("util")

--- @description: Navigate with ship direction
--- @param input string: the puzzle input
--- @return number: manhattan distance
function M.part1(input)
	local lines = util.read_lines(input)
	local x, y = 0, 0
	local dir = 0 -- 0 east, 90 north, etc.
	local dirs = { [0] = { 1, 0 }, [90] = { 0, 1 }, [180] = { -1, 0 }, [270] = { 0, -1 } }
	for _, line in ipairs(lines) do
		local action = line:sub(1, 1)
		local val = tonumber(line:sub(2))
		if action == "N" then
			y = y + val
		elseif action == "S" then
			y = y - val
		elseif action == "E" then
			x = x + val
		elseif action == "W" then
			x = x - val
		elseif action == "F" then
			local dx, dy = table.unpack(dirs[dir])
			x = x + dx * val
			y = y + dy * val
		elseif action == "L" then
			dir = (dir + val) % 360
		elseif action == "R" then
			dir = (dir - val) % 360
		end
	end
	return math.abs(x) + math.abs(y)
end

--- @description: Navigate with waypoint
--- @param input string: the puzzle input
--- @return number: manhattan distance
function M.part2(input)
	local lines = util.read_lines(input)
	local x, y = 0, 0
	local wx, wy = 10, 1
	for _, line in ipairs(lines) do
		local action = line:sub(1, 1)
		local val = tonumber(line:sub(2))
		if action == "N" then
			wy = wy + val
		elseif action == "S" then
			wy = wy - val
		elseif action == "E" then
			wx = wx + val
		elseif action == "W" then
			wx = wx - val
		elseif action == "F" then
			x = x + wx * val
			y = y + wy * val
		elseif action == "L" or action == "R" then
			local turns = val / 90
			if action == "R" then
				turns = 4 - turns
			end
			for _ = 1, turns do
				wx, wy = -wy, wx
			end
		end
	end
	return math.abs(x) + math.abs(y)
end

return M
