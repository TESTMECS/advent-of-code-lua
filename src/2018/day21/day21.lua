--- @title: Day 21: Chronal Conversion ---
local M = {}

-- Define all 16 opcodes as functions. These operate directly on the registers table.
local Opcodes = {
	addr = function(r, a, b, c)
		r[c + 1] = r[a + 1] + r[b + 1]
	end,
	addi = function(r, a, b, c)
		r[c + 1] = r[a + 1] + b
	end,
	mulr = function(r, a, b, c)
		r[c + 1] = r[a + 1] * r[b + 1]
	end,
	muli = function(r, a, b, c)
		r[c + 1] = r[a + 1] * b
	end,
	banr = function(r, a, b, c)
		r[c + 1] = r[a + 1] & r[b + 1]
	end,
	bani = function(r, a, b, c)
		r[c + 1] = r[a + 1] & b
	end,
	borr = function(r, a, b, c)
		r[c + 1] = r[a + 1] | r[b + 1]
	end,
	bori = function(r, a, b, c)
		r[c + 1] = r[a + 1] | b
	end,
	setr = function(r, a, b, c)
		r[c + 1] = r[a + 1]
	end,
	seti = function(r, a, b, c)
		r[c + 1] = a
	end,
	gtir = function(r, a, b, c)
		r[c + 1] = a > r[b + 1] and 1 or 0
	end,
	gtri = function(r, a, b, c)
		r[c + 1] = r[a + 1] > b and 1 or 0
	end,
	gtrr = function(r, a, b, c)
		r[c + 1] = r[a + 1] > r[b + 1] and 1 or 0
	end,
	eqir = function(r, a, b, c)
		r[c + 1] = a == r[b + 1] and 1 or 0
	end,
	eqri = function(r, a, b, c)
		r[c + 1] = r[a + 1] == b and 1 or 0
	end,
	eqrr = function(r, a, b, c)
		r[c + 1] = r[a + 1] == r[b + 1] and 1 or 0
	end,
}

--- @function: Parses the input into an IP register and a list of instructions.
--- @param input string: the puzzle input
--- @return number, table: the IP register and the list of instructions
local function parse_program(input)
	local ip_reg
	local program = {}

	for line in input:gmatch("[^\n]+") do
		if line:match("#ip") then
			ip_reg = tonumber(line:match("%d+")) + 1 -- Convert to 1-based index
		else
			local op_name, a, b, c = line:match("(%a+) (%d+) (%d+) (%d+)")
			table.insert(program, {
				op = op_name,
				a = tonumber(a),
				b = tonumber(b),
				c = tonumber(c),
			})
		end
	end
	return ip_reg, program
end

--- @function: The main solver function for both parts.
--- @param input string: the puzzle input
--- @param part number: the part to solve (1 or 2)
--- @return number|nil: the value for register 0 that causes the earliest halt
local function solve(input, part)
	local ip_reg, program = parse_program(input)
	-- The analysis of the generated sequence is independent of reg[0]'s initial value.
	-- We start with all zeros.
	local registers = { 0, 0, 0, 0, 0, 0 }
	local ip = 0

	-- For Part 2, to detect cycles.
	local seen_values = {}
	local last_unique_value = -1

	-- The key instruction that checks against reg[0] is at IP 28.
	local check_ip = 28

	while ip >= 0 and ip < #program do
		if ip == check_ip then
			local current_val = registers[6] -- Register 5 is at index 6

			if part == 1 then
				-- For part 1, the first value checked is the answer.
				return current_val
			end

			if seen_values[current_val] then
				-- A value has repeated, so we've found the cycle.
				-- The previous value was the last unique one before the cycle began.
				return last_unique_value
			else
				seen_values[current_val] = true
				last_unique_value = current_val
			end
		end

		registers[ip_reg] = ip
		local instr = program[ip + 1]
		Opcodes[instr.op](registers, instr.a, instr.b, instr.c)
		ip = registers[ip_reg]
		ip = ip + 1
	end

	return -1 -- Should not be reached for this puzzle's input
end

--- @description: Find the lowest non-negative integer value for register 0 that causes the program to halt after the fewest instructions.
--- @param input string: the puzzle input
--- @return number|nil: The value for register 0 that causes the earliest halt.
function M.part1(input)
	return solve(input, 1)
end

--- @description: Find the non-negative integer value for register 0 that causes the program to halt after the most instructions.
--- @param input string: the puzzle input
--- @return number|nil: The value for register 0 that causes the latest halt.
--- @note: Takes about a minute.
function M.part2(input)
	return solve(input, 2)
end

return M
