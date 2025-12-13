--- @title: --- Day 23: Amphipod ---
local M = {}

local cost = { A = 1, B = 10, C = 100, D = 1000 }
local room_pos = { A = 2, B = 4, C = 6, D = 8 }
local blocked = { [2] = true, [4] = true, [6] = true, [8] = true }
local min_energy = math.huge

--- @function: Deep copy a table
--- @param t table: the table to copy
--- @return table: the copied table
local function deepcopy(t)
	if type(t) ~= "table" then
		return t
	end
	local nt = {}
	for k, v in pairs(t) do
		nt[k] = deepcopy(v)
	end
	return nt
end

--- @function: Parse the input into a list of rooms and a hallway
--- @param input string: the puzzle input
--- @param part2 boolean: true if the second part of the puzzle is being solved
--- @return table, table: the list of rooms and the hallway
local function parse_input(input, part2)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local rooms = { A = {}, B = {}, C = {}, D = {} }
	local hallway = {}
	for i = 0, 10 do
		hallway[i] = nil
	end
	if not part2 then
		local l3 = lines[3]
		rooms.A[1] = l3:sub(4, 4)
		rooms.B[1] = l3:sub(6, 6)
		rooms.C[1] = l3:sub(8, 8)
		rooms.D[1] = l3:sub(10, 10)
		local l4 = lines[4]
		rooms.A[2] = l4:sub(4, 4)
		rooms.B[2] = l4:sub(6, 6)
		rooms.C[2] = l4:sub(8, 8)
		rooms.D[2] = l4:sub(10, 10)
	else
		local l3 = lines[3]
		rooms.A[1] = l3:sub(4, 4)
		rooms.B[1] = l3:sub(6, 6)
		rooms.C[1] = l3:sub(8, 8)
		rooms.D[1] = l3:sub(10, 10)
		local l4 = lines[4]
		rooms.A[2] = l4:sub(4, 4)
		rooms.B[2] = l4:sub(6, 6)
		rooms.C[2] = l4:sub(8, 8)
		rooms.D[2] = l4:sub(10, 10)
		rooms.A[3] = "D"
		rooms.B[3] = "C"
		rooms.C[3] = "B"
		rooms.D[3] = "A"
		rooms.A[4] = "D"
		rooms.B[4] = "B"
		rooms.C[4] = "A"
		rooms.D[4] = "C"
	end
	return rooms, hallway
end
local function parse_input2(input, part2)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local rooms = { A = {}, B = {}, C = {}, D = {} }
	local hallway = {}
	for i = 0, 10 do
		hallway[i] = nil
	end

	local l3 = lines[3]
	rooms.A[1] = l3:sub(4, 4)
	rooms.B[1] = l3:sub(6, 6)
	rooms.C[1] = l3:sub(8, 8)
	rooms.D[1] = l3:sub(10, 10)

	local l4 = lines[4]
	if not part2 then
		rooms.A[2] = l4:sub(4, 4)
		rooms.B[2] = l4:sub(6, 6)
		rooms.C[2] = l4:sub(8, 8)
		rooms.D[2] = l4:sub(10, 10)
	else
		-- Correctly insert the new rows
		rooms.A[2] = "D"
		rooms.B[2] = "C"
		rooms.C[2] = "B"
		rooms.D[2] = "A"
		rooms.A[3] = "D"
		rooms.B[3] = "B"
		rooms.C[3] = "A"
		rooms.D[3] = "C"

		-- Original bottom row goes in the last spot
		rooms.A[4] = l4:sub(4, 4)
		rooms.B[4] = l4:sub(6, 6)
		rooms.C[4] = l4:sub(8, 8)
		rooms.D[4] = l4:sub(10, 10)
	end
	return rooms, hallway
end

--- @function: Make a string representation of the current state
--- @param rooms table: the list of rooms
--- @param hallway table: the hallway
--- @param max_spots number: the maximum number of spots
--- @return string: the string representation of the current state
local function make_state(rooms, hallway, max_spots)
	local s = ""
	for i = 0, 10 do
		s = s .. (hallway[i] or ".")
	end
	for _, r in ipairs({ "A", "B", "C", "D" }) do
		for j = 1, max_spots do
			s = s .. (rooms[r][j] or ".")
		end
	end
	return s
end

--- @function: Check if the current state is a goal state
--- @param rooms table: the list of rooms
--- @param max_spots number: the maximum number of spots
--- @return boolean: true if the current state is a goal state
local function is_goal(rooms, max_spots)
	for _, r in ipairs({ "A", "B", "C", "D" }) do
		for j = 1, max_spots do
			if rooms[r][j] ~= r then
				return false
			end
		end
	end
	return true
end

--- @function: Get all possible moves from the current state
--- @param rooms table: the list of rooms
--- @param hallway table: the hallway
--- @param max_spots number: the maximum number of spots
--- @return table: the list of all possible moves
local function get_moves(rooms, hallway, max_spots)
	local moves = {}

	-- 1. Try moving from HALLWAY into a ROOM
	for i = 0, 10 do
		if hallway[i] then
			local type = hallway[i]
			local r = type
			local target_spot = nil
			local room_ok = true

			-- Check from the bottom of the room up
			for j = max_spots, 1, -1 do
				if not rooms[r][j] then
					target_spot = j -- This is the deepest available spot
					break
				elseif rooms[r][j] ~= r then
					room_ok = false -- An incorrect amphipod is in the room
					break
				end
			end

			if room_ok and target_spot then
				local current_pos = i
				local target_pos = room_pos[r]
				local steps = math.abs(current_pos - target_pos) + target_spot

				-- Check if the path in the hallway is clear
				local clear = true
				local minp = math.min(current_pos, target_pos)
				local maxp = math.max(current_pos, target_pos)
				for k = minp, maxp do
					if k ~= current_pos and hallway[k] then -- Corrected path check
						clear = false
						break
					end
				end

				if clear then
					local new_rooms = deepcopy(rooms)
					local new_hallway = deepcopy(hallway)
					new_rooms[r][target_spot] = type
					new_hallway[i] = nil
					table.insert(moves, { new_rooms = new_rooms, new_hallway = new_hallway, cost = cost[type] * steps })
				end
			end
		end
	end

	-- 2. Try moving from a ROOM into the HALLWAY
	for _, r in ipairs({ "A", "B", "C", "D" }) do
		for j = 1, max_spots do
			if rooms[r][j] then
				local type = rooms[r][j]
				local can_move = true

				-- Check if this amphipod should stay put
				if r == type then
					local is_settled = true
					-- Check if all spots *below* this one are also correctly filled
					for k = j + 1, max_spots do
						if not rooms[r][k] or rooms[r][k] ~= type then
							is_settled = false
							break
						end
					end
					if is_settled then
						can_move = false
					end
				end

				if can_move then
					-- Check if it's blocked by another amphipod in the same room
					local blocked_in_room = false
					for k = 1, j - 1 do
						if rooms[r][k] then
							blocked_in_room = true
							break
						end
					end

					if not blocked_in_room then
						local current_pos = room_pos[r]
						local steps_from_spot = j
						for target = 0, 10 do
							if not blocked[target] and not hallway[target] then
								local target_pos = target
								local steps = math.abs(current_pos - target_pos) + steps_from_spot

								-- Check if the path in the hallway is clear
								local clear = true
								local minp = math.min(current_pos, target_pos)
								local maxp = math.max(current_pos, target_pos)
								for k = minp, maxp do
									if k ~= current_pos and hallway[k] then
										clear = false
										break
									end
								end

								if clear then
									local new_rooms = deepcopy(rooms)
									local new_hallway = deepcopy(hallway)
									new_rooms[r][j] = nil
									new_hallway[target] = type
									table.insert(
										moves,
										{ new_rooms = new_rooms, new_hallway = new_hallway, cost = cost[type] * steps }
									)
								end
							end
						end
					end
				end
			end
		end
	end
	return moves
end

--- @function: Solve the puzzle recursively
--- @param rooms table: the list of rooms
--- @param hallway table: the hallway
--- @param max_spots number: the maximum number of spots
--- @param current_cost number: the current cost
--- @param cache table: the cache
local function solve_recursive(rooms, hallway, max_spots, current_cost, cache)
	local state = make_state(rooms, hallway, max_spots)
	if cache[state] and cache[state] <= current_cost then
		return
	end
	cache[state] = current_cost
	if current_cost >= min_energy then
		return
	end
	if is_goal(rooms, max_spots) then
		if current_cost < min_energy then
			min_energy = current_cost
		end
		return
	end
	local moves = get_moves(rooms, hallway, max_spots)
	for _, move in ipairs(moves) do
		local new_cost = current_cost + move.cost
		solve_recursive(move.new_rooms, move.new_hallway, max_spots, new_cost, cache)
	end
end

--- @function: Solve the puzzle recursively
--- @param rooms table: the list of rooms
--- @param hallway table: the hallway
--- @param max_spots number: the maximum number of spots
--- @return number: the minimum energy
function M.solve(rooms, hallway, max_spots)
	min_energy = math.huge
	local cache = {}
	local start_time = os.clock()
	print("Starting recursive solve with max_spots:", max_spots)
	solve_recursive(rooms, hallway, max_spots, 0, cache)
	local elapsed = os.clock() - start_time
	return min_energy == math.huge and -1 or min_energy
end

--- @description: Solve the puzzle for the first part
--- @param input string: the puzzle input
--- @return number: the minimum energy
function M.part1(input)
	local rooms, hallway = parse_input(input, false)
	return M.solve(rooms, hallway, 2)
end

--- @description: Solve the puzzle for the second part
--- @param input string: the puzzle input
--- @return number: the minimum energy
function M.part2(input)
	local rooms, hallway = parse_input2(input, true)
	return M.solve(rooms, hallway, 4)
end

return M
