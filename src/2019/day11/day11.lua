--- @title: Day 11: Space Police ---
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

--- @function: Creates a resumable Intcode computer instance.
--- @param initial_memory table: The initial memory state.
--- @return function: The Intcode computer function.
local function create_intcode(initial_memory)
	local memory = {}
	for i = 1, #initial_memory do
		memory[i] = initial_memory[i]
	end

	local pc = 1
	local relative_base = 0
	local halted = false
	local inputs = {}

	local function run(input_val)
		if halted then
			return nil
		end

		-- Add the new input to the queue if provided
		if input_val ~= nil then
			table.insert(inputs, input_val)
		end

		while memory[pc] ~= 99 do
			local instr = memory[pc]
			local opcode = instr % 100

			local function get_mode(param_num)
				return math.floor(instr / (10 ^ (param_num + 1))) % 10
			end

			local function get_param(param_num)
				local mode = get_mode(param_num)
				local raw_val = memory[pc + param_num]
				if mode == 0 then
					return memory[raw_val + 1] or 0
				elseif mode == 1 then
					return raw_val
				elseif mode == 2 then
					return memory[raw_val + relative_base + 1] or 0
				end
			end

			local function get_write_addr(param_num)
				local mode = get_mode(param_num)
				local raw_val = memory[pc + param_num]
				if mode == 0 then
					return raw_val + 1
				elseif mode == 2 then
					return raw_val + relative_base + 1
				end
				error("Invalid mode for write parameter: " .. mode)
			end

			if opcode == 1 then -- Add
				memory[get_write_addr(3)] = get_param(1) + get_param(2)
				pc = pc + 4
			elseif opcode == 2 then -- Multiply
				memory[get_write_addr(3)] = get_param(1) * get_param(2)
				pc = pc + 4
			elseif opcode == 3 then -- Input
				if #inputs == 0 then
					return "needs_input"
				end -- Paused
				memory[get_write_addr(1)] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then -- Output
				local output = get_param(1)
				pc = pc + 2
				return output -- Paused
			elseif opcode == 5 then -- Jump-if-true
				pc = (get_param(1) ~= 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 6 then -- Jump-if-false
				pc = (get_param(1) == 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 7 then -- Less than
				memory[get_write_addr(3)] = (get_param(1) < get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 8 then -- Equals
				memory[get_write_addr(3)] = (get_param(1) == get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 9 then -- Adjust Relative Base
				relative_base = relative_base + get_param(1)
				pc = pc + 2
			else
				error("Unknown opcode " .. opcode .. " at pc " .. (pc - 1))
			end
		end

		halted = true
		return nil -- Halted
	end
	return run
end

--- @function: Runs the Intcode program with the given input value.
--- @param memory table: The original memory state.
--- @param start_color number: The initial color.
--- @return table: The final memory state.
local function run_robot(memory, start_color)
	local computer = create_intcode(memory)
	local panels = {}
	local x, y = 0, 0
	local dir = 0 -- 0: up, 1: right, 2: down, 3: left
	local directions = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }

	panels["0,0"] = start_color

	while true do
		local key = x .. "," .. y
		local current_color = panels[key] or 0

		local new_color = computer(current_color)
		if new_color == nil then
			break
		end -- Program halted

		local turn = computer() -- Get second output without providing new input
		if turn == nil then
			break
		end -- Program halted

		panels[key] = new_color

		-- CORRECTED: Modulo arithmetic for turning left
		if turn == 0 then -- Turn left
			dir = (dir - 1 + 4) % 4
		else -- Turn right
			dir = (dir + 1) % 4
		end

		x = x + directions[dir + 1][1]
		y = y + directions[dir + 1][2]
	end

	return panels
end

--- @description Count the number of panels painted at least once
--- @param input string the puzzle input
--- @return number the count
function M.part1(input)
	local memory = parse_input(input)
	-- Start on a black panel (0)
	local painted_panels = run_robot(memory, 0)
	local count = 0
	for _ in pairs(painted_panels) do
		count = count + 1
	end
	return count
end

--- @description Render the registration identifier
--- @param input string the puzzle input
--- @return string the image
function M.part2(input)
	local memory = parse_input(input)
	-- Start on a white panel (1)
	local panels = run_robot(memory, 1)

	local min_x, max_x, min_y, max_y = 0, 0, 0, 0
	for key in pairs(panels) do
		local x, y = key:match("(-?%d+),(-?%d+)")
		x, y = tonumber(x), tonumber(y)
		min_x = math.min(min_x, x)
		max_x = math.max(max_x, x)
		min_y = math.min(min_y, y)
		max_y = math.max(max_y, y)
	end

	local result = "\n"
	for y = min_y, max_y do
		local row_str = ""
		for x = min_x, max_x do
			local key = x .. "," .. y
			local color = panels[key] or 0
			row_str = row_str .. (color == 1 and "█" or " ")
		end
		result = result .. row_str .. "\n"
	end

	print(result)
	return "" -- The visual output is the answer
end

return M
