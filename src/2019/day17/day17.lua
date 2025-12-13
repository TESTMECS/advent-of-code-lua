--- @title: Day 17: Set and Forget ---
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

--- @function: Runs the Intcode program to get the initial camera view as a 2D grid.
--- @param memory table: The memory state.
--- @return table: The grid.
local function get_map(memory)
	local computer = create_intcode(memory)
	local grid = {}
	local row = {}
	while true do
		local output = computer()
		if output == nil then
			break
		end
		if output == 10 then -- Newline
			if #row > 0 then
				table.insert(grid, row)
			end
			row = {}
		else
			table.insert(row, string.char(output))
		end
	end
	return grid
end

--- @description: Calculate the sum of the alignment parameters of the scaffold intersections.
--- @param input string: The puzzle input.
--- @return number: The answer.
function M.part1(input)
	local memory = parse_input(input)
	local grid = get_map(memory)

	local sum_of_alignment_params = 0
	for y = 2, #grid - 1 do
		for x = 2, #grid[y] - 1 do
			if
				grid[y][x] == "#"
				and grid[y - 1][x] == "#"
				and grid[y + 1][x] == "#"
				and grid[y][x - 1] == "#"
				and grid[y][x + 1] == "#"
			then
				sum_of_alignment_params = sum_of_alignment_params + ((x - 1) * (y - 1))
			end
		end
	end
	return sum_of_alignment_params
end

--- @function: Finds the full path the robot must take to cover all scaffolds.
--- @param grid table: The grid.
--- @return string: The path.
local function find_full_path(grid)
	local start_x, start_y, start_dir
	local dirs = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } } -- N, E, S, W
	local dir_map = { ["^"] = 0, [">"] = 1, ["v"] = 2, ["<"] = 3 }

	for y = 1, #grid do
		for x = 1, #grid[y] do
			if dir_map[grid[y][x]] then
				start_x, start_y, start_dir = x, y, dir_map[grid[y][x]]
				break
			end
		end
	end

	local x, y, dir = start_x, start_y, start_dir
	local path = {}

	while true do
		local forward_steps = 0
		while true do
			local nx, ny = x + dirs[dir + 1][1], y + dirs[dir + 1][2]
			if ny > 0 and ny <= #grid and nx > 0 and nx <= #grid[ny] and grid[ny][nx] == "#" then
				forward_steps = forward_steps + 1
				x, y = nx, ny
			else
				break
			end
		end
		if forward_steps > 0 then
			table.insert(path, tostring(forward_steps))
		end

		local left_dir = (dir - 1 + 4) % 4
		local lx, ly = x + dirs[left_dir + 1][1], y + dirs[left_dir + 1][2]
		if ly > 0 and ly <= #grid and lx > 0 and lx <= #grid[ly] and grid[ly][lx] == "#" then
			table.insert(path, "L")
			dir = left_dir
		else
			local right_dir = (dir + 1) % 4
			local rx, ry = x + dirs[right_dir + 1][1], y + dirs[right_dir + 1][2]
			if ry > 0 and ry <= #grid and rx > 0 and rx <= #grid[ry] and grid[ry][rx] == "#" then
				table.insert(path, "R")
				dir = right_dir
			else
				break -- No more moves
			end
		end
	end
	return table.concat(path, ",")
end

--- @function: A simple greedy compression algorithm for the path.
--- @param path_str string: The path.
--- @return string: The compressed path.
--- @return string: The A segment.
--- @return string: The B segment.
local function compress_path(path_str)
	-- Tokenize path: "R,8,L,6,R,8" -> { "R","8","L","6","R","8" }
	local tokens = {}
	for token in path_str:gmatch("[^,]+") do
		table.insert(tokens, token)
	end

	-- Helper: join tokens into string
	local function join(t)
		return table.concat(t, ",")
	end
	-- in some helper module
	local function utils_Set(list)
		local set = {}
		for _, l in ipairs(list) do
			set[l] = true
		end
		return set
	end

	-- Try all possible segments of length up to 10 tokens (≈20 chars)
	local function try_segments(tokens)
		local n = #tokens

		for a_len = 2, math.min(10, n) do
			local A = { table.unpack(tokens, 1, a_len) }
			local A_str = join(A)
			if #A_str <= 20 then
				local replA = {}
				local i = 1
				while i <= n do
					local seg = join({ table.unpack(tokens, i, i + a_len - 1) })
					if seg == A_str then
						table.insert(replA, "A")
						i = i + a_len
					else
						table.insert(replA, tokens[i])
						i = i + 1
					end
				end

				-- Find B
				for b_start = 1, #replA do
					if replA[b_start] ~= "A" then
						for b_len = 2, math.min(10, #replA - b_start + 1) do
							local B = { table.unpack(replA, b_start, b_start + b_len - 1) }
							_set = utils_Set(B)

							if not _set["A"] then
								local B_str = join(B)
								if #B_str <= 20 then
									local replB = {}
									local j = 1
									while j <= #replA do
										local seg = join({ table.unpack(replA, j, j + b_len - 1) })
										if seg == B_str then
											table.insert(replB, "B")
											j = j + b_len
										else
											table.insert(replB, replA[j])
											j = j + 1
										end
									end

									-- Find C
									for c_start = 1, #replB do
										if replB[c_start] ~= "A" and replB[c_start] ~= "B" then
											for c_len = 2, math.min(10, #replB - c_start + 1) do
												local C = { table.unpack(replB, c_start, c_start + c_len - 1) }
												_set = utils_Set(C)
												if not _set["A"] and not _set["B"] then
													local C_str = join(C)
													if #C_str <= 20 then
														local replC = {}
														local k = 1
														while k <= #replB do
															local seg = join({ table.unpack(replB, k, k + c_len - 1) })
															if seg == C_str then
																table.insert(replC, "C")
																k = k + c_len
															else
																table.insert(replC, replB[k])
																k = k + 1
															end
														end

														local main = join(replC)
														if #main <= 20 and not main:find("[RL0-9]") then
															return main, A_str, B_str, C_str
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		return nil
	end

	return try_segments(tokens)
end

--- @description Find the amount of dust collected by the vacuum robot after traversing the scaffold.
--- @description Find the amount of dust collected by the vacuum robot after traversing the scaffold.
function M.part2(input)
	local initial_memory = parse_input(input)
	local grid = get_map(initial_memory)
	local path_str = find_full_path(grid)
	local main, A, B, C = compress_path(path_str)
	-- Prepare the input stream for the Intcode computer
	local input_stream = {}
	for _, s in ipairs({ main, A, B, C, "n" }) do
		for i = 1, #s do
			table.insert(input_stream, string.byte(s:sub(i, i)))
		end
		table.insert(input_stream, 10) -- Newline character
	end
	-- Use a fresh memory copy for the actual run.
	local memory_for_run = parse_input(input)
	memory_for_run[1] = 2 -- Wake up the robot for free play
	local computer = create_intcode(memory_for_run)
	local final_output
	while true do
		local output = computer()
		if output == "needs_input" then
			if #input_stream > 0 then
				computer(table.remove(input_stream, 1))
			else
				print("Warning: Computer needs input, but stream is empty.")
			end
		elseif output == nil then
			break
		elseif output > 255 then
			final_output = output
		else
		end
	end
	return final_output
end

return M
