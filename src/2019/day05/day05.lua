--- @title: Day 5: Sunny with a Chance of Asteroids ---
local M = {}

--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
local function parse_input(input)
	local nums = {}
	for num_str in input:gmatch("([^,]+)") do
		table.insert(nums, tonumber(num_str))
	end
	return nums
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

	local pc = 1 -- Program counter is 1-based
	local outputs = {}

	while memory[pc] ~= 99 do
		local instr = memory[pc]
		local opcode = instr % 100

		--- @local: Helper to get a parameter's mode
		--- @param param_num number: The parameter number to get the mode of.
		--- @return number: The mode of the parameter.
		local function get_mode(param_num)
			return (math.floor(instr / (10 ^ (param_num + 1)))) % 10
		end

		--- @local: Helper to get a parameter's value
		--- @param param_num number: The parameter number to get the value of.
		--- @return number: The value of the parameter.
		local function get_param(param_num)
			local mode = get_mode(param_num)
			local raw_val = memory[pc + param_num]
			if mode == 0 then -- Position Mode
				-- The value is an address. Return the value at that address.
				-- Add 1 to convert 0-based address to 1-based Lua index.
				return memory[raw_val + 1] or 0 -- Default to 0 if address is out of bounds
			else -- Immediate Mode (mode == 1)
				-- The value is the value itself.
				return raw_val
			end
		end

		--- @local: Helper to set a parameter's value
		--- @param param_num number: The parameter number to set the value of.
		--- @param value number: The value to set the parameter to.
		local function set_value(param_num, value)
			local write_addr = memory[pc + param_num]
			-- Add 1 to convert 0-based address to 1-based Lua index.
			memory[write_addr + 1] = value
		end

		if opcode == 1 then -- Add
			local a = get_param(1)
			local b = get_param(2)
			set_value(3, a + b)
			pc = pc + 4
		elseif opcode == 2 then -- Multiply
			local a = get_param(1)
			local b = get_param(2)
			set_value(3, a * b)
			pc = pc + 4
		elseif opcode == 3 then -- Input
			set_value(1, input_value)
			pc = pc + 2
		elseif opcode == 4 then -- Output
			table.insert(outputs, get_param(1))
			pc = pc + 2
		elseif opcode == 5 then -- Jump-if-true
			if get_param(1) ~= 0 then
				pc = get_param(2) + 1 -- Set pc to the new 1-based address
			else
				pc = pc + 3
			end
		elseif opcode == 6 then -- Jump-if-false
			if get_param(1) == 0 then
				pc = get_param(2) + 1 -- Set pc to the new 1-based address
			else
				pc = pc + 3
			end
		elseif opcode == 7 then -- Less than
			local a = get_param(1)
			local b = get_param(2)
			set_value(3, a < b and 1 or 0)
			pc = pc + 4
		elseif opcode == 8 then -- Equals
			local a = get_param(1)
			local b = get_param(2)
			set_value(3, a == b and 1 or 0)
			pc = pc + 4
		else
			error("unknown opcode " .. opcode .. " at pc " .. (pc - 1))
		end
	end

	-- The puzzle requires returning the final output value.
	return outputs[#outputs]
end

--- @description Run the Intcode program with input 1 and return the diagnostic code
--- @param input string the puzzle input
--- @return number the diagnostic code
function M.part1(input)
	local memory = parse_input(input)
	return run_intcode(memory, 1)
end

--- @description Run the Intcode program with input 5 and return the diagnostic code
--- @param input string the puzzle input
--- @return number the diagnostic code
function M.part2(input)
	local memory = parse_input(input)
	return run_intcode(memory, 5)
end

return M
