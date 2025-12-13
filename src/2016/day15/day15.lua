--- @title: Day 15: Timing is Everything ---
local M = {}

--- @function: Parses the input to get the discs
--- @param input string: The description of the discs.
--- @return table: The discs.
local function parse_input(input)
	local discs = {}
	for line in input:gmatch("[^\r\n]+") do
		local id, positions, start_pos =
			line:match("Disc #(%d+) has (%d+) positions; at time=0, it is at position (%d+).")
		if id then
			table.insert(discs, {
				id = tonumber(id),
				positions = tonumber(positions),
				start_pos = tonumber(start_pos),
			})
		end
	end
	return discs
end

--- @function: Solves the problem by simulating the discs
--- @param discs table: The discs.
--- @return number: The first valid time to press the button.
local function solve(discs)
	local time = 0
	local step = 1

	for _, disc in ipairs(discs) do
		while true do
			if (disc.start_pos + time + disc.id) % disc.positions == 0 then
				break
			end
			time = time + step
		end
		step = step * disc.positions
	end

	return time
end

--- @description: Finds the first time to press the button to get a capsule.
--- @param input string: The description of the discs.
--- @return number: The first valid time to press the button.
function M.part1(input)
	local discs = parse_input(input)
	return solve(discs)
end

--- @description: Finds the first time with the additional disc.
--- @param input string: The description of the discs.
--- @return number: The first valid time with the new disc.
function M.part2(input)
	local discs = parse_input(input)
	table.insert(discs, { id = #discs + 1, positions = 11, start_pos = 0 })
	return solve(discs)
end

return M
