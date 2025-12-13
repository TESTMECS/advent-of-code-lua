--- @title: Day 21: Springdroid Adventure ---
local M = {}

--- Parses a comma-separated string of numbers into a Lua table.
local function parse_input(input)
	local memory = {}
	for num_str in input:gmatch("([^,]+)") do
		table.insert(memory, tonumber(num_str))
	end
	return memory
end

--- Creates a resumable Intcode computer instance.
local function create_intcode(initial_memory)
	local memory = {}
	for i = 1, #initial_memory do
		memory[i] = initial_memory[i]
	end
	local pc, relative_base, halted, inputs = 1, 0, false, {}
	local function run(input_val)
		if halted then
			return nil
		end
		if input_val ~= nil then
			table.insert(inputs, input_val)
		end
		while true do
			if pc > #memory then
				memory[pc] = 0
			end
			local instr, opcode = memory[pc], memory[pc] % 100
			if opcode == 99 then
				halted = true
				return nil
			end
			local function get_mode(p)
				return math.floor(instr / (10 ^ (p + 1))) % 10
			end
			local function get_param(p)
				local mode, raw = get_mode(p), memory[pc + p] or 0
				if mode == 0 then
					return memory[raw + 1] or 0
				elseif mode == 1 then
					return raw
				elseif mode == 2 then
					return memory[raw + relative_base + 1] or 0
				end
			end
			local function get_write_addr(p)
				local mode, raw = get_mode(p), memory[pc + p] or 0
				if mode == 0 then
					return raw + 1
				elseif mode == 2 then
					return raw + relative_base + 1
				end
			end
			local addr
			if opcode == 1 then
				addr = get_write_addr(3)
				memory[addr] = get_param(1) + get_param(2)
				pc = pc + 4
			elseif opcode == 2 then
				addr = get_write_addr(3)
				memory[addr] = get_param(1) * get_param(2)
				pc = pc + 4
			elseif opcode == 3 then
				if #inputs == 0 then
					return "needs_input"
				end
				addr = get_write_addr(1)
				memory[addr] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then
				local out = get_param(1)
				pc = pc + 2
				return out
			elseif opcode == 5 then
				pc = (get_param(1) ~= 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 6 then
				pc = (get_param(1) == 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 7 then
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) < get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 8 then
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) == get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 9 then
				relative_base = relative_base + get_param(1)
				pc = pc + 2
			else
				error("Unknown opcode " .. opcode)
			end
		end
	end
	return run
end

--- Compiles a springscript and runs it on the Intcode computer.
local function run_springscript(memory, script_lines)
	local computer = create_intcode(memory)

	-- Convert script lines to a single string and then to ASCII bytes
	local script_str = table.concat(script_lines, "\n") .. "\n"
	for i = 1, #script_str do
		computer(string.byte(script_str, i))
	end

	-- Run the computer and collect outputs
	local last_output
	while true do
		local output = computer()
		if output == nil or output == "needs_input" then
			break
		end
		if output > 255 then
			last_output = output -- This is the hull damage
		else
			-- You can uncomment this to see the droid's view
			-- io.write(string.char(output))
		end
	end
	return last_output
end

--- @description Find the amount of hull damage by programming the springdroid.
function M.part1(input)
	local memory = parse_input(input)
	-- Logic: Jump if there's a hole at A, B, or C, but only if D is solid ground.
	-- NOT A J  ; J = !A
	-- NOT B T  ; T = !B
	-- OR T J   ; J = !A || !B
	-- NOT C T  ; T = !C
	-- OR T J   ; J = !A || !B || !C
	-- AND D J  ; J = (!A || !B || !C) && D
	-- WALK
	local springscript = {
		"NOT A J",
		"NOT B T",
		"OR T J",
		"NOT C T",
		"OR T J",
		"AND D J",
		"WALK",
	}
	return run_springscript(memory, springscript)
end

--- @description Find the amount of hull damage with the extended sensor suite.
function M.part2(input)
	local memory = parse_input(input)

	-- Logic: Jump if a hole is at A/B/C, AND landing spot D is ground,
	-- AND you have a "next move" after landing (either can walk to E or jump to H).
	-- Final logic: JUMP if (!A || !B || !C) && D && (E || H)
	local springscript = {
		-- Step 1: J = !A || !B || !C
		"NOT A J",
		"NOT B T",
		"OR T J",
		"NOT C T",
		"OR T J",

		-- Step 2: T = D && (E || H)
		"NOT T T", -- clear T
		"OR E T",
		"OR H T",
		"AND D T",

		-- Step 3: J = J && T
		"AND T J",

		"RUN",
	}
	return run_springscript(memory, springscript)
end

return M
