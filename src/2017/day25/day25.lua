--- @title: Day 25: The Halting Problem ---
local M = {}

--- @function: Parse the input string into lines, ignoring empty lines
--- @param input string: the blueprint description
--- @return table: the blueprint description
local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	return lines
end

--- @description: Simulate the Turing machine and compute the diagnostic checksum
--- @param input string: the blueprint description
--- @return number: the number of 1s on the tape after the specified steps
function M.part1(input)
	local lines = parse_input(input)
	local states = {} -- Table to hold state rules: states[state][value] = {write, move, newstate}
	local current_state -- Initial state
	local max_steps -- Number of steps to run

	-- Direction mapping for movement
	local MOVE = { left = -1, right = 1 }

	-- Parse the input lines to build the states table
	local state, ifval -- Temporary variables for parsing
	for _, line in ipairs(lines) do
		-- Extract initial state
		local val = line:match("Begin in state (.-)%.")
		if val then
			current_state = val
		end

		-- Extract number of steps
		val = line:match("Perform a diagnostic checksum after (%d+) steps.")
		if val then
			max_steps = tonumber(val)
		end

		-- Extract state name
		val = line:match("In state (.-):")
		if val then
			state = val
			states[state] = {}
		end

		-- Extract condition value (0 or 1)
		val = line:match("If the current value is (%d+):")
		if val then
			ifval = tonumber(val)
			states[state][ifval] = {}
		end

		-- Extract write value
		val = line:match("- Write the value (%d+)%.")
		if val then
			states[state][ifval].write = tonumber(val)
		end

		-- Extract move direction
		val = line:match("- Move one slot to the (.-)%.")
		if val then
			states[state][ifval].move = MOVE[val]
		end

		-- Extract next state
		val = line:match("- Continue with state (.-)%.")
		if val then
			states[state][ifval].newstate = val
		end
	end

	-- Simulate the Turing machine
	local tape = {} -- Sparse table representing the tape, position -> value
	local cur_pos = 0 -- Current cursor position
	local min_pos, max_pos = 0, 0 -- Track the range of positions written to

	for step = 1, max_steps do
		-- Read the current value under the cursor (default to 0)
		local cur_val = tape[cur_pos] or 0

		-- Get the actions for the current state and value
		local state_rules = states[current_state]
		local actions = state_rules[cur_val]

		-- Perform the actions: write, move, change state
		tape[cur_pos] = actions.write
		cur_pos = cur_pos + actions.move
		current_state = actions.newstate

		-- Update min and max positions for checksum calculation
		if cur_pos < min_pos then
			min_pos = cur_pos
		end
		if cur_pos > max_pos then
			max_pos = cur_pos
		end
	end

	-- Calculate the checksum: count the number of 1s on the tape
	local checksum = 0
	for pos = min_pos, max_pos do
		checksum = checksum + (tape[pos] or 0)
	end

	return checksum
end

--- @description: Part 2: No computation needed, as per the puzzle narrative
--- @return string
function M.part2(_)
	return "press dat button"
end

return M
