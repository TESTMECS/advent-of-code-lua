--- @title: Day 5: A Maze of Twisty Trampolines, All Alike ---
local M = {}

--- @description: Count steps to exit maze with incrementing jumps
--- @param input string: the jump offsets
--- @return number: the step count
function M.part1(input)
	local jumps = {}
	-- Parse input into table
	for line in input:gmatch("[^\n]+") do
		table.insert(jumps, tonumber(line))
	end
	local pos = 1
	local steps = 0
	-- Simulate jumps
	while pos >= 1 and pos <= #jumps do
		local offset = jumps[pos]
		jumps[pos] = offset + 1
		pos = pos + offset
		steps = steps + 1
	end
	return steps
end

--- @description: Count steps to exit maze with conditional increment/decrement
--- @param input string: the jump offsets
--- @return number: the step count
function M.part2(input)
	local jumps = {}
	-- Parse input into table
	for line in input:gmatch("[^\n]+") do
		table.insert(jumps, tonumber(line))
	end
	local pos = 1
	local steps = 0
	-- Simulate jumps
	while pos >= 1 and pos <= #jumps do
		local offset = jumps[pos]
		if offset >= 3 then
			jumps[pos] = offset - 1
		else
			jumps[pos] = offset + 1
		end
		pos = pos + offset
		steps = steps + 1
	end
	return steps
end

return M
