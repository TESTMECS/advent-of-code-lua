--- @title: Day 13: Care Package ---
local M = {}

---@function: Parses a comma-separated string of numbers into a Lua table, handling negatives.
---@param input string
---@return table
local function parse_input(input)
	local memory = {}
	for num_str in input:gmatch("([^,]+)") do
		table.insert(memory, tonumber(num_str))
	end
	return memory
end

---@function: Creates a resumable Intcode computer instance.
---@param initial_memory table: The initial memory state.
---@return function: The Intcode computer function.
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

		if input_val ~= nil then
			table.insert(inputs, input_val)
		end

		while true do
			-- Ensure memory is large enough
			if pc > #memory then
				memory[pc] = 0
			end

			local instr = memory[pc]
			local opcode = instr % 100

			if opcode == 99 then
				halted = true
				return nil -- Halted
			end

			local function get_mode(param_num)
				return math.floor(instr / (10 ^ (param_num + 1))) % 10
			end

			local function get_param(param_num)
				local mode = get_mode(param_num)
				local raw_val = memory[pc + param_num] or 0
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
				local raw_val = memory[pc + param_num] or 0
				if mode == 0 then
					return raw_val + 1
				elseif mode == 2 then
					return raw_val + relative_base + 1
				end
				error("Invalid mode for write parameter: " .. mode)
			end

			local addr
			if opcode == 1 then -- Add
				addr = get_write_addr(3)
				memory[addr] = get_param(1) + get_param(2)
				pc = pc + 4
			elseif opcode == 2 then -- Multiply
				addr = get_write_addr(3)
				memory[addr] = get_param(1) * get_param(2)
				pc = pc + 4
			elseif opcode == 3 then -- Input
				if #inputs == 0 then
					return "needs_input"
				end -- Paused for input
				addr = get_write_addr(1)
				memory[addr] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then -- Output
				local output = get_param(1)
				pc = pc + 2
				return output -- Paused with output
			elseif opcode == 5 then -- Jump-if-true
				pc = (get_param(1) ~= 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 6 then -- Jump-if-false
				pc = (get_param(1) == 0) and (get_param(2) + 1) or (pc + 3)
			elseif opcode == 7 then -- Less than
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) < get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 8 then -- Equals
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) == get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 9 then -- Adjust Relative Base
				relative_base = relative_base + get_param(1)
				pc = pc + 2
			else
				error("Unknown opcode " .. opcode .. " at pc " .. (pc - 1))
			end
		end
	end
	return run
end

--- @description: Count the number of block tiles on the screen at the start.
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local memory = parse_input(input)
	local computer = create_intcode(memory)
	local block_count = 0

	while true do
		local x = computer()
		if x == nil then
			break
		end
		local y = computer()
		local tile_id = computer()

		if tile_id == 2 then
			block_count = block_count + 1
		end
	end

	return block_count
end

--- @description Play the arcade game and return the final score.
--- @param input string: the puzzle input
--- @return number: the score
function M.part2(input)
	local memory = parse_input(input)
	memory[1] = 2 -- Activate "free play" mode
	local computer = create_intcode(memory)

	local score = 0
	local ball_x = 0
	local paddle_x = 0

	while true do
		local result = computer()

		if result == "needs_input" then
			-- The computer is paused and needs our move. Decide based on positions.
			local joystick
			if paddle_x < ball_x then
				joystick = 1 -- Move right
			elseif paddle_x > ball_x then
				joystick = -1 -- Move left
			else
				joystick = 0
			end -- Stay neutral
			result = computer(joystick)
		end

		if result == nil then
			-- Program has halted, the game is over.
			break
		end

		-- We received the first output (x). Get the next two.
		local x = result
		local y = computer()
		local id = computer()

		if x == -1 and y == 0 then
			score = id
		else
			if id == 4 then
				ball_x = x -- Track the ball
			elseif id == 3 then
				paddle_x = x -- Track the paddle
			end
		end
	end

	return score
end

return M
