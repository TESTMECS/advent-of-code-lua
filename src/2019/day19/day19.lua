--- @title: Day 19: Tractor Beam ---
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

--- @description Count the number of points affected by the tractor beam in a 50x50 area.
function M.part1(input)
	local memory = parse_input(input)

	-- Helper function to probe a single point. Creates a fresh computer each time.
	local function probe(x, y)
		local computer = create_intcode(memory)
		computer(x) -- Send x
		return computer(y) -- Send y and get the result
	end

	local affected_count = 0
	for y = 0, 49 do
		for x = 0, 49 do
			if probe(x, y) == 1 then
				affected_count = affected_count + 1
			end
		end
	end
	return affected_count
end

--- @description Find the top-left corner of the first 100x100 square that fits in the beam.
function M.part2(input)
	local memory = parse_input(input)

	local function probe(x, y)
		local computer = create_intcode(memory)
		computer(x)
		return computer(y)
	end

	local x, y = 0, 100 -- Start scanning from a reasonable y to fit the square

	while true do
		-- Find the left edge of the beam for the current row y
		while probe(x, y) == 0 do
			x = x + 1
		end

		-- Now (x, y) is the bottom-left corner of a potential 100x100 square.
		-- The top-right corner would be at (x + 99, y - 99).
		-- If that point is also in the beam, the entire square fits.
		if probe(x + 99, y - 99) == 1 then
			-- We found it. The top-left corner is (x, y - 99).
			return x * 10000 + (y - 99)
		end

		-- Move to the next row to continue the search
		y = y + 1
	end
end

return M
