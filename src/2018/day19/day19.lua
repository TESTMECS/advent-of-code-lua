--- @title: Day 19: Go With The Flow ---
local M = {}

-- Define all 16 opcodes as functions.
-- Instructions are in the format: op A B C.
-- Register indices A, B, C are 0-indexed in the problem description,
-- so we add 1 to access elements in our 1-indexed Lua tables.
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
	setr = function(r, a, _, c)
		r[c + 1] = r[a + 1]
	end,
	seti = function(r, a, _, c)
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

local function parse_program(input)
	local ip_reg
	local program = {}
	local op_map = {}
	for name, _ in pairs(Opcodes) do
		op_map[name] = name
	end

	for line in input:gmatch("[^\n]+") do
		if line:match("#ip") then
			ip_reg = tonumber(line:match("%d+")) + 1 -- Convert to 1-based index
		else
			local op_name, a, b, c = line:match("(%a+) (%d+) (%d+) (%d+)")
			table.insert(program, {
				op = op_map[op_name],
				a = tonumber(a),
				b = tonumber(b),
				c = tonumber(c),
			})
		end
	end
	return ip_reg, program
end

--- @function: Efficiently calculates the sum of all divisors of a number.
--- @param n number: the number to calculate the divisors of
--- @return number: the sum of all divisors
local function sum_of_divisors(n)
	local sum = 0
	local limit = math.sqrt(n)
	for i = 1, limit do
		if n % i == 0 then
			sum = sum + i
			local other_divisor = n / i
			if other_divisor ~= i then
				sum = sum + other_divisor
			end
		end
	end
	return sum
end

--- The main solver function for both parts.
-- It runs the simulation just long enough to find the target number,
-- then calculates the sum of its divisors directly.
local function solve(input, initial_r0)
	local ip_reg, program = parse_program(input)
	local registers = { initial_r0, 0, 0, 0, 0, 0 }
	local ip = 0

	-- Run for a limited number of steps (e.g., 1000) to get past the setup phase.
	-- The main computation loop starts when ip=1.
	for _ = 1, 1000 do
		if ip < 0 or ip >= #program then
			break
		end -- Program halted
		if ip == 1 then
			break
		end -- We have entered the main loop, target number is set.

		registers[ip_reg] = ip
		local instr = program[ip + 1]
		Opcodes[instr.op](registers, instr.a, instr.b, instr.c)
		ip = registers[ip_reg]
		ip = ip + 1
	end

	-- The target number N is now in register 5.
	local target_number = registers[6] -- using 6 for reg[5] because of 1-based index
	return sum_of_divisors(target_number)
end

--- @description: Run the program with register 0 starting at 0.
--- @param input string: the puzzle input
--- @return number: The value left in register 0 when the program halts.
function M.part1(input)
	return solve(input, 0)
end

--- @description: Run the program with register 0 starting at 1.
--- @param input string: the puzzle input
--- @return number: The value left in register 0 when the program halts.
function M.part2(input)
	return solve(input, 1)
end

return M
