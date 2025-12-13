--- @title: Day 16: Chronal Classification ---
local M = {}

--- @function: Helper to create a copy of a registers table
local function copy_regs(regs)
	return { regs[1], regs[2], regs[3], regs[4] }
end

--- @function: Helper to compare two registers tables for equality
local function regs_equal(r1, r2)
	return r1[1] == r2[1] and r1[2] == r2[2] and r1[3] == r2[3] and r1[4] == r2[4]
end

-- Define all 16 opcodes as functions.
-- Instructions are in the format: op A B C.
-- Register indices A, B, C are 0-indexed in the problem description,
-- so we add 1 to access elements in our 1-indexed Lua tables.
local Opcodes = {
	addr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] + out[b + 1]
		return out
	end,
	addi = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] + b
		return out
	end,
	mulr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] * out[b + 1]
		return out
	end,
	muli = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] * b
		return out
	end,
	banr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] & out[b + 1]
		return out
	end,
	bani = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] & b
		return out
	end,
	borr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] | out[b + 1]
		return out
	end,
	bori = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] | b
		return out
	end,
	setr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1]
		return out
	end,
	seti = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = a
		return out
	end,
	gtir = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = a > out[b + 1] and 1 or 0
		return out
	end,
	gtri = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] > b and 1 or 0
		return out
	end,
	gtrr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] > out[b + 1] and 1 or 0
		return out
	end,
	eqir = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = a == out[b + 1] and 1 or 0
		return out
	end,
	eqri = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] == b and 1 or 0
		return out
	end,
	eqrr = function(regs, a, b, c)
		local out = copy_regs(regs)
		out[c + 1] = out[a + 1] == out[b + 1] and 1 or 0
		return out
	end,
}

--- @function: Parses the input into two parts: a list of samples and the test program.
local function parse_input(input)
	local samples = {}
	local program = {}

	-- The samples and program are separated by at least 3 newlines.
	input = input:match("^%s*(.-)%s*$")
	local sample_block, program_block = input:match("^(.-)\n\n\n+(.*)$")

	local function parse_numbers(s)
		local t = {}
		for n in s:gmatch("%d+") do
			table.insert(t, tonumber(n))
		end
		return t
	end

	-- Parse samples
	for before_str, instr_str, after_str in sample_block:gmatch("Before: %[(.-)%]\n(.-)\nAfter:  %[(.-)%]") do
		table.insert(samples, {
			before = parse_numbers(before_str),
			instr = parse_numbers(instr_str),
			after = parse_numbers(after_str),
		})
	end

	-- Parse program
	for line in program_block:gmatch("[^\n]+") do
		if #line > 0 then
			table.insert(program, parse_numbers(line))
		end
	end

	return samples, program
end

--- @description: Counts how many samples in the input behave like three or more opcodes.
--- @param input string: the puzzle input
--- @return number: The number of samples matching three or more opcodes.
function M.part1(input)
	local samples, _ = parse_input(input)

	local three_or_more_count = 0

	for _, sample in ipairs(samples) do
		local matching_opcodes = 0
		local _, a, b, c = table.unpack(sample.instr)

		for _, func in pairs(Opcodes) do
			local result_regs = func(sample.before, a, b, c)
			if regs_equal(result_regs, sample.after) then
				matching_opcodes = matching_opcodes + 1
			end
		end

		if matching_opcodes >= 3 then
			three_or_more_count = three_or_more_count + 1
		end
	end

	return three_or_more_count
end

--- @description: Deduces the opcode numbers, runs the test program, and returns the value in register 0.
--- @param input string: the puzzle input
--- @return number: The value in register 0 after executing the program.
function M.part2(input)
	local samples, program = parse_input(input)

	-- 1. Gather Constraints: Find possible opcodes for each opcode number
	local possible_opcodes = {}
	for i = 0, 15 do
		possible_opcodes[i] = {}
		for name, _ in pairs(Opcodes) do
			possible_opcodes[i][name] = true
		end
	end

	for _, sample in ipairs(samples) do
		local op_num, a, b, c = table.unpack(sample.instr)

		for name, func in pairs(Opcodes) do
			-- If this opcode is currently a possibility for op_num
			if possible_opcodes[op_num][name] then
				local result_regs = func(sample.before, a, b, c)
				if not regs_equal(result_regs, sample.after) then
					-- This opcode doesn't work for this sample, so eliminate it
					possible_opcodes[op_num][name] = nil
				end
			end
		end
	end

	-- 2. Deduce the Mapping: Iteratively solve the constraints
	local opcode_map = {} -- Final mapping: op_num -> name
	local resolved_count = 0

	while resolved_count < 16 do
		local changed_this_pass = false
		-- Find an opcode number with only one possible name
		for op_num = 0, 15 do
			if not opcode_map[op_num] then -- if not already resolved
				local possibilities = {}
				for name, _ in pairs(possible_opcodes[op_num]) do
					table.insert(possibilities, name)
				end

				if #possibilities == 1 then
					local resolved_name = possibilities[1]
					opcode_map[op_num] = resolved_name
					resolved_count = resolved_count + 1
					changed_this_pass = true

					-- Remove this resolved name from all other possibilities
					for i = 0, 15 do
						if i ~= op_num then
							if possible_opcodes[i][resolved_name] then
								possible_opcodes[i][resolved_name] = nil
							end
						end
					end
				end
			end
		end
		if not changed_this_pass and resolved_count < 16 then
			-- This indicates an issue if the puzzle isn't solvable this way
			error("Deduction loop is stuck. Total resolved: " .. resolved_count)
			break
		end
	end

	-- 3. Execute the Test Program
	local regs = { 0, 0, 0, 0 }
	for _, instr in ipairs(program) do
		local op_num, a, b, c = table.unpack(instr)
		local op_name = opcode_map[op_num]
		local op_func = Opcodes[op_name]

		-- op funcs return a new table, so re-assign
		regs = op_func(regs, a, b, c)
	end

	return regs[1]
end

return M
