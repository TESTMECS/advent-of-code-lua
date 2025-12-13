--- @title: Day 07: The Sum of Its Parts ---
local M = {}
local util = require("util")

--- @description: Determines the order to complete all steps following dependencies
--- @param input string: the puzzle input
--- @return string: the order of steps
function M.part1(input)
	local lines = util.read_lines(input)
	local deps = {}
	local indegree = {}
	local all_steps = {}
	for _, line in ipairs(lines) do
		local before, after = line:match("Step (%u) must be finished before step (%u)")
		if not deps[before] then
			deps[before] = {}
		end
		table.insert(deps[before], after)
		indegree[after] = (indegree[after] or 0) + 1
		all_steps[before] = true
		all_steps[after] = true
	end
	for step in pairs(all_steps) do
		if not indegree[step] then
			indegree[step] = 0
		end
	end
	local order = {}
	local available = {}
	for step, deg in pairs(indegree) do
		if deg == 0 then
			table.insert(available, step)
		end
	end
	table.sort(available)
	while #available > 0 do
		local next_step = table.remove(available, 1)
		table.insert(order, next_step)
		if deps[next_step] then
			for _, s in ipairs(deps[next_step]) do
				indegree[s] = indegree[s] - 1
				if indegree[s] == 0 then
					table.insert(available, s)
					table.sort(available)
				end
			end
		end
	end
	return table.concat(order)
end

--- @description: Calculates the time to complete all steps with 5 workers
--- @param input string: the puzzle input
--- @return number: the total time
function M.part2(input)
	local lines = util.read_lines(input)
	local deps = {}
	local indegree = {}
	local all_steps = {}
	for _, line in ipairs(lines) do
		local before, after = line:match("Step (%u) must be finished before step (%u)")
		if not deps[before] then
			deps[before] = {}
		end
		table.insert(deps[before], after)
		indegree[after] = (indegree[after] or 0) + 1
		all_steps[before] = true
		all_steps[after] = true
	end
	for step in pairs(all_steps) do
		if not indegree[step] then
			indegree[step] = 0
		end
	end
	local workers = 5
	local base_time = 60
	local time = 0
	local working = {}
	local completed = {}
	local available = {}
	for step, deg in pairs(indegree) do
		if deg == 0 then
			table.insert(available, step)
		end
	end
	table.sort(available)
	while util.numel(completed) < util.numel(all_steps) do
		while #available > 0 and #working < workers do
			local step = table.remove(available, 1)
			local duration = base_time + (string.byte(step) - string.byte("A") + 1)
			table.insert(working, { step = step, time_left = duration })
		end
		time = time + 1
		for i = #working, 1, -1 do
			working[i].time_left = working[i].time_left - 1
			if working[i].time_left == 0 then
				local done = working[i].step
				completed[done] = true
				table.remove(working, i)
				if deps[done] then
					for _, s in ipairs(deps[done]) do
						indegree[s] = indegree[s] - 1
						if indegree[s] == 0 and not completed[s] then
							table.insert(available, s)
							table.sort(available)
						end
					end
				end
			end
		end
	end
	return time
end

return M
