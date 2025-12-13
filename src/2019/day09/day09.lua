--- @title: Day 09: Sensor Boost ---
local M = {}

--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
local function parse_input(input)
	local memory = {}
	for num_str in input:gmatch("([^,]+)") do
		table.insert(memory, tonumber(num_str))
	end
	return memory
end

--- @function: Runs the Intcode program with the given input value.
--- @param orig_memory table: The original memory state.
--- @param input_value number: The input value to use.
--- @return number: The final output value.
local function run_intcode(orig_memory, input_value)
	local memory = {}
	for i = 1, #orig_memory do
		memory[i] = orig_memory[i]
	end

	local pc = 1
	local relative_base = 0
	local outputs = {}

	while memory[pc] ~= 99 do
		local instr = memory[pc]
		local opcode = instr % 100

		-- Helper to get parameter mode for a given parameter index (1, 2, or 3)
		local function get_mode(param_num)
			return math.floor(instr / (10 ^ (param_num + 1))) % 10
		end

		-- Helper to get a parameter's value based on its mode
		local function get_param(param_num)
			local mode = get_mode(param_num)
			local raw_val = memory[pc + param_num]

			if mode == 0 then -- Position Mode
				return memory[raw_val + 1] or 0
			elseif mode == 1 then -- Immediate Mode
				return raw_val
			elseif mode == 2 then -- Relative Mode
				return memory[raw_val + relative_base + 1] or 0
			end
		end

		-- Helper to determine the write address for a parameter
		local function get_write_addr(param_num)
			local mode = get_mode(param_num)
			local raw_val = memory[pc + param_num]

			if mode == 0 then -- Position Mode
				return raw_val + 1
			elseif mode == 2 then -- Relative Mode
				return raw_val + relative_base + 1
			else -- Immediate mode is invalid for writes
				error("Invalid mode for a write parameter: " .. mode)
			end
		end

		if opcode == 1 then -- Add
			local addr = get_write_addr(3)
			memory[addr] = get_param(1) + get_param(2)
			pc = pc + 4
		elseif opcode == 2 then -- Multiply
			local addr = get_write_addr(3)
			memory[addr] = get_param(1) * get_param(2)
			pc = pc + 4
		elseif opcode == 3 then -- Input
			local addr = get_write_addr(1)
			memory[addr] = input_value
			pc = pc + 2
		elseif opcode == 4 then -- Output
			table.insert(outputs, get_param(1))
			pc = pc + 2
		elseif opcode == 5 then -- Jump-if-true
			if get_param(1) ~= 0 then
				pc = get_param(2) + 1
			else
				pc = pc + 3
			end
		elseif opcode == 6 then -- Jump-if-false
			if get_param(1) == 0 then
				pc = get_param(2) + 1
			else
				pc = pc + 3
			end
		elseif opcode == 7 then -- Less than
			local addr = get_write_addr(3)
			memory[addr] = (get_param(1) < get_param(2)) and 1 or 0
			pc = pc + 4
		elseif opcode == 8 then -- Equals
			local addr = get_write_addr(3)
			memory[addr] = (get_param(1) == get_param(2)) and 1 or 0
			pc = pc + 4
		elseif opcode == 9 then -- Adjust Relative Base
			relative_base = relative_base + get_param(1)
			pc = pc + 2
		else
			error("unknown opcode " .. opcode .. " at pc " .. (pc - 1))
		end
	end

	return outputs[#outputs]
end

--- @description Run the BOOST program in test mode (input 1)
--- @param input string the puzzle input
--- @return number the BOOST keycode
function M.part1(input)
	local memory = parse_input(input)
	return run_intcode(memory, 1)
end

--- @description Run the BOOST program in sensor boost mode (input 2)
--- @param input string the puzzle input
--- @return number the coordinates
function M.part2(input)
	local memory = parse_input(input)
	return run_intcode(memory, 2)
end

return M
