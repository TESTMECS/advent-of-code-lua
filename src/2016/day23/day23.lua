--- @title: Day 23: Safe Cracking ---
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
	if arg:match("^%-?%d+$") then
		return tonumber(arg)
	else
		return registers[arg] or 0
	end
end

--- @function: Toggles the instruction type
--- @param inst table: The instruction
--- @return string: The new instruction type
local function toggle_instruction(inst)
	local op = inst.op
	if op == "inc" then
		return "dec"
	elseif op == "dec" then
		return "inc"
	elseif op == "tgl" then
		return "inc"
	elseif op == "jnz" then
		return "cpy"
	elseif op == "cpy" then
		return "jnz"
	else
		return "inc"
	end
end

--- @function: Executes the program
--- @param instructions table: The list of instructions
--- @param initial_a number: The initial value of register a
--- @param max_steps number: The maximum number of steps to execute
--- @return number: The final value of register a
local function execute_program(instructions, initial_a, max_steps)
	local registers = { a = initial_a, b = 0, c = 0, d = 0 }
	local ip = 1
	local steps = 0

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
			if arg1:match("^[a-d]$") then
				registers[arg1] = (registers[arg1] or 0) + 1
			end
			ip = ip + 1
		elseif op == "dec" then
			if arg1:match("^[a-d]$") then
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
		elseif op == "tgl" then
			local offset = get_value(arg1, registers)
			local target_ip = ip + offset
			if target_ip >= 1 and target_ip <= #instructions then
				instructions[target_ip].op = toggle_instruction(instructions[target_ip])
			end
			ip = ip + 1
		else
			-- Invalid instruction, skip
			ip = ip + 1
		end

		steps = steps + 1
		if steps % 1000000 == 0 then
			print(
				string.format(
					"Step %d, IP %d, Registers: a=%d, b=%d, c=%d, d=%d",
					steps,
					ip,
					registers.a,
					registers.b,
					registers.c,
					registers.d
				)
			)
		end
	end

	if ip > #instructions then
		print("Program completed naturally after " .. steps .. " steps")
	elseif steps >= max_steps then
		print("Program timed out after " .. max_steps .. " steps at IP " .. ip)
	end

	return registers.a
end

--- @description: Run the Assembunny program with initial a=7
--- @param input string: The entire input file content
--- @return number: Final value in register a
function M.part1(input)
	local lines = util.read_lines(input)
	local instructions = parse_instructions(lines)
	return execute_program(instructions, 7, 1000000)
end

--- @description: Run the Assembunny program with initial a=12
--- @param input string: The entire input file content
--- @return number: Final value in register a
--- @note: May take a while to run, can JIT this one
function M.part2(input)
	local lines = util.read_lines(input)
	local instructions = parse_instructions(lines)
	return execute_program(instructions, 12, 5000000000)
	-- Program completed naturally after 3501381236 steps
end

return M
