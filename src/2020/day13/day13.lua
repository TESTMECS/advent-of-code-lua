--- @title: Day 13: Shuttle Search ---
local M = {}
local util = require("util")

--- @description: Find bus with smallest wait time
--- @param input string: the puzzle input
--- @return number: ID * wait
function M.part1(input)
	local lines = util.read_lines(input)
	local timestamp = tonumber(lines[1])
	local buses = {}
	for id in lines[2]:gmatch("(%d+)") do
		table.insert(buses, tonumber(id))
	end
	local min_wait = math.huge
	local min_id = 0
	for _, id in ipairs(buses) do
		local wait = id - (timestamp % id)
		if wait == id then
			wait = 0
		end
		if wait < min_wait then
			min_wait = wait
			min_id = id
		end
	end
	return min_id * min_wait
end

--- @description: Find timestamp for aligned departures
--- @param input string: the puzzle input
--- @return number: the timestamp
function M.part2(input)
	local lines = util.read_lines(input)
	local bus_list = {}
	for bus in lines[2]:gmatch("[^,]+") do
		table.insert(bus_list, bus)
	end
	local buses = {}
	for i, bus in ipairs(bus_list) do
		if bus ~= "x" then
			table.insert(buses, { tonumber(bus), i - 1 })
		end
	end
	local t = 0
	local step = 1
	for _, bus in ipairs(buses) do
		local id, offset = bus[1], bus[2]
		while (t + offset) % id ~= 0 do
			t = t + step
		end
		step = step * id
	end
	return t
end

return M
