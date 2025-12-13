--- @title: Day 15: Oxygen System ---
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
		if input_val ~= nil then
			table.insert(inputs, input_val)
		end
		while true do
			if pc > #memory then
				memory[pc] = 0
			end
			local instr = memory[pc]
			local opcode = instr % 100
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

-- Droid movement commands and their opposites
-- Directions: 1:N, 2:S, 3:W, 4:E
local dx = { [1] = 0, [2] = 0, [3] = -1, [4] = 1 }
local dy = { [1] = -1, [2] = 1, [3] = 0, [4] = 0 }
local opposite_dir = { [1] = 2, [2] = 1, [3] = 4, [4] = 3 }

-- Global-like variables for the recursive explorer
local computer, map, visited, oxygen_pos
local recursive_explore

--- @function: Explores the maze using a recursive DFS. Simpler and more reliable.
--- @param x number: The x-coordinate of the starting position.
--- @param y number: The y-coordinate of the starting position.
recursive_explore = function(x, y)
	for dir = 1, 4 do
		local nx, ny = x + dx[dir], y + dy[dir]
		local key = nx .. "," .. ny

		if not visited[key] then
			visited[key] = true
			local status = computer(dir)

			if status == 0 then -- Hit a wall
				map[key] = 0
			else -- Moved successfully
				map[key] = status
				if status == 2 then
					oxygen_pos.x, oxygen_pos.y = nx, ny
				end

				-- Explore from the new position
				recursive_explore(nx, ny)

				-- Backtrack the droid to its original position (x, y)
				computer(opposite_dir[dir])
			end
		end
	end
end

--- @function: Finds the shortest path using Breadth-First Search.
--- @param start_x number: The x-coordinate of the starting position.
--- @param start_y number: The y-coordinate of the starting position.
--- @param target_x number: The x-coordinate of the target position.
--- @param target_y number: The y-coordinate of the target position.
--- @return number: The distance.
local function bfs(start_x, start_y, target_x, target_y)
	local queue = { { x = start_x, y = start_y, dist = 0 } }
	local visited_bfs = { [start_x .. "," .. start_y] = true }

	while #queue > 0 do
		local curr = table.remove(queue, 1)
		if curr.x == target_x and curr.y == target_y then
			return curr.dist
		end
		for dir = 1, 4 do
			local nx, ny = curr.x + dx[dir], curr.y + dy[dir]
			local key = nx .. "," .. ny
			if map[key] ~= 0 and not visited_bfs[key] then
				visited_bfs[key] = true
				table.insert(queue, { x = nx, y = ny, dist = curr.dist + 1 })
			end
		end
	end
	return -1
end

--- @function: Finds the time it takes for oxygen to fill all reachable areas.
--- @param start_x number: The x-coordinate of the starting position.
--- @param start_y number: The y-coordinate of the starting position.
--- @return number: The time.
local function fill_oxygen(start_x, start_y)
	local queue = { { x = start_x, y = start_y, time = 0 } }
	local visited_fill = { [start_x .. "," .. start_y] = true }
	local max_time = 0

	while #queue > 0 do
		local curr = table.remove(queue, 1)
		max_time = math.max(max_time, curr.time)
		for dir = 1, 4 do
			local nx, ny = curr.x + dx[dir], curr.y + dy[dir]
			local key = nx .. "," .. ny
			if map[key] ~= 0 and not visited_fill[key] then
				visited_fill[key] = true
				table.insert(queue, { x = nx, y = ny, time = curr.time + 1 })
			end
		end
	end
	return max_time
end

--- @function: Solves both parts by first mapping the area, then running BFS.
--- @param input string: The puzzle input.
--- @return number: The part1 answer.
--- @return number: The part2 answer.
local function solve(input)
	local memory = parse_input(input)
	computer = create_intcode(memory)

	-- Reset state for the explorer
	map = { ["0,0"] = 1 }
	visited = { ["0,0"] = true }
	oxygen_pos = {}

	recursive_explore(0, 0)

	local part1_answer = bfs(0, 0, oxygen_pos.x, oxygen_pos.y)
	local part2_answer = fill_oxygen(oxygen_pos.x, oxygen_pos.y)

	return part1_answer, part2_answer
end

--- @description: Find the shortest path using Breadth-First Search.
--- @param input string: The puzzle input.
--- @return number: The answer.
function M.part1(input)
	local p1, _ = solve(input)
	return p1
end

--- @description: Find the time it takes for oxygen to fill all reachable areas.
--- @param input string: The puzzle input.
--- @return number: The answer.
function M.part2(input)
	local _, p2 = solve(input)
	return p2
end

return M
