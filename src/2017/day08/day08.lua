--- @title: Day 8: I Heard You Like Registers ---
local M = {}

-- Define operations for registers and comparisons
local operations = {
	-- Register modification operations
	inc = function(register_value, amount)
		return register_value + amount
	end,
	dec = function(register_value, amount)
		return register_value - amount
	end,

	-- Comparison operations
	["=="] = function(a, b)
		return a == b
	end,
	["!="] = function(a, b)
		return a ~= b
	end,
	[">"] = function(a, b)
		return a > b
	end,
	["<"] = function(a, b)
		return a < b
	end,
	[">="] = function(a, b)
		return a >= b
	end,
	["<="] = function(a, b)
		return a <= b
	end,
}

--- @function: Helper function to split a string into fields
--- @param input_string string: the input string
--- @return table: the fields
local function split_into_fields(input_string)
	local fields = {}
	for word in input_string:gmatch("%S+") do
		table.insert(fields, word)
	end
	return fields
end

--- @function: Helper function to find the maximum value in a table
--- @param register_table table: the register table
--- @return number: the maximum value
local function find_max_value(register_table)
	local max_value = 0
	for _, value in pairs(register_table) do
		if value > max_value then
			max_value = value
		end
	end
	return max_value
end

--- @description Find the maximum register value after executing all instructions
--- @param input string the list of instructions
--- @return number the maximum value in any register at the end
function M.part1(input)
	local registers = {}

	-- Process each instruction
	for line in input:gmatch("[^\n]+") do
		if line == "" then
			goto continue
		end -- Skip empty lines

		local fields = split_into_fields(line)
		local target_register = fields[1]
		local operation = fields[2]
		local amount = tonumber(fields[3])
		local condition_register = fields[5]
		local comparison_operator = fields[6]
		local comparison_value = tonumber(fields[7])

		-- Get current values
		local target_value = registers[target_register] or 0
		local condition_value = registers[condition_register] or 0

		-- Check condition and apply operation if true
		if operations[comparison_operator](condition_value, comparison_value) then
			target_value = operations[operation](target_value, amount)
			registers[target_register] = target_value
		end

		::continue::
	end

	-- Find the maximum value among all registers
	return find_max_value(registers)
end

--- @description Find the maximum register value ever reached during execution
--- @param input string the list of instructions
--- @return number the highest value any register has held
function M.part2(input)
	local registers = {}
	local max_value_during_execution = 0

	-- Process each instruction
	for line in input:gmatch("[^\n]+") do
		if line == "" then
			goto continue
		end -- Skip empty lines

		local fields = split_into_fields(line)
		local target_register = fields[1]
		local operation = fields[2]
		local amount = tonumber(fields[3])
		local condition_register = fields[5]
		local comparison_operator = fields[6]
		local comparison_value = tonumber(fields[7])

		-- Get current values
		local target_value = registers[target_register] or 0
		local condition_value = registers[condition_register] or 0

		-- Check condition and apply operation if true
		if operations[comparison_operator](condition_value, comparison_value) then
			target_value = operations[operation](target_value, amount)
			registers[target_register] = target_value

			-- Update the maximum value seen so far
			if target_value > max_value_during_execution then
				max_value_during_execution = target_value
			end
		end

		::continue::
	end

	return max_value_during_execution
end

return M
