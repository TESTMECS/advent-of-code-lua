--- @title: Day 25: Clock Signal ---
local util = require("util")

local M = {}

--- @function: Parses the input file into a list of instructions
--- @param lines string[]: The entire input file content
--- @return table: The list of instructions
local function parse_instructions(lines)
	local instructions = {}
	for i, line in ipairs(lines) do
		local parts = {}
		for part in line:gmatch("%S+") do
			table.insert(parts, part)
		end
		if #parts >= 2 then
			local op = parts[1]
			local arg1 = parts[2]
			local arg2 = parts[3]
			table.insert(instructions, { op = op, arg1 = arg1, arg2 = arg2, line = i })
		end
	end
	return instructions
end

--- @function: Gets the value of a register or constant
--- @param arg string: The register or constant
--- @param registers table: The register values
--- @return number|nil: The value
local function get_value(arg, registers)
	if arg and arg:match("^%-?%d+$") then
		return tonumber(arg)
	else
		return registers[arg] or 0
	end
end

--- @function: Executes the program
--- @param instructions table: The list of instructions
--- @param initial_a number: The initial value of register a
--- @param max_steps number: The maximum number of steps to execute
--- @return table: The output
--- @return table: The final register values
--- @return boolean: Whether the program completed
local function execute_program(instructions, initial_a, max_steps)
	local registers = { a = initial_a, b = 0, c = 0, d = 0 }
	local ip = 1
	local steps = 0
	local output = {}

	while ip >= 1 and ip <= #instructions and steps < max_steps do
		local inst = instructions[ip]
		local op = inst.op
		local arg1 = inst.arg1
		local arg2 = inst.arg2

		if op == "cpy" then
			if arg2 and arg2:match("^[a-d]$") then
				registers[arg2] = get_value(arg1, registers)
			end
			ip = ip + 1
		elseif op == "inc" then
			if arg1 and arg1:match("^[a-d]$") then
				registers[arg1] = (registers[arg1] or 0) + 1
			end
			ip = ip + 1
		elseif op == "dec" then
			if arg1 and arg1:match("^[a-d]$") then
				registers[arg1] = (registers[arg1] or 0) - 1
			end
			ip = ip + 1
		elseif op == "jnz" then
			local val = get_value(arg1, registers)
			if val ~= 0 then
				ip = ip + get_value(arg2, registers)
			else
				ip = ip + 1
			end
		elseif op == "out" then
			local val = get_value(arg1, registers)
			table.insert(output, val)
			ip = ip + 1
		else
			-- Invalid instruction, skip
			ip = ip + 1
		end

		steps = steps + 1
	end

	return output, registers, ip > #instructions
end

--- @function: Checks if the output is alternating between 0 and 1
--- @param output table: The output
--- @param min_length integer: The minimum length of the output
--- @return boolean: True if alternating, false otherwise
local function is_alternating_clock_signal(output, min_length)
	if #output < min_length then
		return false
	end

	-- Check if the sequence alternates between 0 and 1
	local expected = 0
	for _, val in ipairs(output) do
		if val ~= expected then
			return false
		end
		expected = 1 - expected
	end

	return true
end

--- @description: Find lowest positive integer for register a that produces alternating clock signal
--- @param input string: The entire input file content
--- @return number: The lowest positive integer for register a
function M.part1(input)
	local lines = util.read_lines(input)
	local instructions = parse_instructions(lines)

	-- Try increasing values of a until we find one that produces the alternating signal
	local a = 1
	while true do
		local output, registers, completed = execute_program(instructions, a, 100000)

		-- Check if we have enough output and it's alternating
		if is_alternating_clock_signal(output, 20) then
			return a
		end

		a = a + 1

		-- Safety check to prevent infinite loop
		if a > 10000 then
			break
		end
	end

	return -1 -- Not found
end

--- @description: Part 2 doesn't exist for Day 25
--- @return string:
function M.part2(_)
	return "press the button"
end

return M
