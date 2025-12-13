--- @title: Day 12: Leonardo's Monorail ---
local M = {}

--- @function: Executes the assembunny code and returns the final registers.
--- @param input string: The assembunny code.
--- @param initial_registers table|nil: The initial registers.
--- @return table: The final registers.
local function run_assembunny(input, initial_registers)
	local registers = { a = 0, b = 0, c = 0, d = 0 }
	if initial_registers then
		for k, v in pairs(initial_registers) do
			registers[k] = v
		end
	end

	local instructions = {}
	for line in input:gmatch("[^\r\n]+") do
		local parts = {}
		for part in line:gmatch("%S+") do
			table.insert(parts, part)
		end
		table.insert(instructions, parts)
	end

	--- @function: Helper function to get value from register or number
	--- @param val string|number: The register or number
	--- @return number|nil: The value
	local function get_value(val)
		if registers[val] ~= nil then
			return registers[val]
		else
			return tonumber(val)
		end
	end

	local ip = 1
	while ip <= #instructions do
		local instr = instructions[ip]
		local cmd = instr[1]

		if cmd == "cpy" then
			local val = get_value(instr[2])
			local reg = instr[3]
			registers[reg] = val
			ip = ip + 1
		elseif cmd == "inc" then
			local reg = instr[2]
			registers[reg] = registers[reg] + 1
			ip = ip + 1
		elseif cmd == "dec" then
			local reg = instr[2]
			registers[reg] = registers[reg] - 1
			ip = ip + 1
		elseif cmd == "jnz" then
			local val = get_value(instr[2])
			if val ~= 0 then
				local jump = get_value(instr[3])
				ip = ip + jump
			else
				ip = ip + 1
			end
		end
	end

	return registers
end

--- @description Executes the assembunny code and returns the value in register a.
--- @param input string The assembunny code.
--- @return number The final value in register a.
function M.part1(input)
	local final_registers = run_assembunny(input)
	return final_registers.a
end

--- @description Executes the assembunny code with register c initialized to 1.
--- @param input string The assembunny code.
--- @return number The final value in register a.
function M.part2(input)
	local final_registers = run_assembunny(input, { c = 1 })
	return final_registers.a
end

return M
