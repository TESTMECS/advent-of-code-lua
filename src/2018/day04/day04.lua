--- @title: Day 04: Repose Record ---
local M = {}
local util = require("util")

--- @description: Finds the guard that sleeps the most and the minute they sleep most, returns guard ID * minute
--- @param input string: the puzzle input
--- @return number: the result
function M.part1(input)
	local lines = util.read_lines(input)
	table.sort(lines, function(a, b)
		local ta = a:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		local tb = b:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		return ta < tb
	end)
	local guards = {}
	local current_guard = nil
	local asleep_time = nil
	for _, line in ipairs(lines) do
		local time_str = line:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		local event = line:match("%] (.+)")
		local _, min = time_str:match("(%d+):(%d+)")
		min = tonumber(min)
		if event:find("Guard") then
			current_guard = tonumber(event:match("#(%d+)"))
			if not guards[current_guard] then
				guards[current_guard] = { total_sleep = 0, minutes = {} }
				for m = 0, 59 do
					guards[current_guard].minutes[m] = 0
				end
			end
			asleep_time = nil
		elseif event == "falls asleep" then
			asleep_time = min
		elseif event == "wakes up" then
			if asleep_time then
				for m = asleep_time, min - 1 do
					guards[current_guard].minutes[m] = guards[current_guard].minutes[m] + 1
				end
				guards[current_guard].total_sleep = guards[current_guard].total_sleep + (min - asleep_time)
			end
			asleep_time = nil
		end
	end
	local max_guard = nil
	local max_sleep = 0
	for id, data in pairs(guards) do
		if data.total_sleep > max_sleep then
			max_sleep = data.total_sleep
			max_guard = id
		end
	end
	local max_min = 0
	local max_count = 0
	for m = 0, 59 do
		if guards[max_guard].minutes[m] > max_count then
			max_count = guards[max_guard].minutes[m]
			max_min = m
		end
	end
	return max_guard * max_min
end

--- @description: Finds the guard most frequently asleep on the same minute, returns guard ID * minute
--- @param input string: the puzzle input
--- @return number: the result
function M.part2(input)
	local lines = util.read_lines(input)
	table.sort(lines, function(a, b)
		local ta = a:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		local tb = b:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		return ta < tb
	end)
	local guards = {}
	local current_guard = nil
	local asleep_time = nil
	for _, line in ipairs(lines) do
		local time_str = line:match("%[(%d+-%d+-%d+ %d+:%d+)%]")
		local event = line:match("%] (.+)")
		local _, min = time_str:match("(%d+):(%d+)")
		min = tonumber(min)
		if event:find("Guard") then
			current_guard = tonumber(event:match("#(%d+)"))
			if not guards[current_guard] then
				guards[current_guard] = { total_sleep = 0, minutes = {} }
				for m = 0, 59 do
					guards[current_guard].minutes[m] = 0
				end
			end
			asleep_time = nil
		elseif event == "falls asleep" then
			asleep_time = min
		elseif event == "wakes up" then
			if asleep_time then
				for m = asleep_time, min - 1 do
					guards[current_guard].minutes[m] = guards[current_guard].minutes[m] + 1
				end
				guards[current_guard].total_sleep = guards[current_guard].total_sleep + (min - asleep_time)
			end
			asleep_time = nil
		end
	end
	local max_guard = nil
	local max_min = 0
	local max_count = 0
	for id, data in pairs(guards) do
		for m = 0, 59 do
			if data.minutes[m] > max_count then
				max_count = data.minutes[m]
				max_min = m
				max_guard = id
			end
		end
	end
	return max_guard * max_min
end

return M
