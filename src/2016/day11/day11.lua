--- @title: Day 11: Radioisotope Thermoelectric Generators ---
local M = {}

--- @function: Parse input to get initial floor layout
--- @param input string: of floor descriptions
--- @return table: of floors
local function parse_input(input)
	local floors = { {}, {}, {}, {} }
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local floor_names = { "first", "second", "third", "fourth" }

	for i, line in ipairs(lines) do
		local floor_name = floor_names[i]
		if line:match(floor_name) and line:match("contains") then
			local floor_items = {}
			local items_str = line:match("contains (.+)")
			if items_str then
				items_str = items_str:gsub(" and ", ", "):gsub("%.", "")
				local parts = {}
				for part in items_str:gmatch("([^,]+)") do
					part = part:gsub("^%s*", ""):gsub("%s*$", "")
					if part:sub(1, 3) == "and" then
						part = part:sub(4):gsub("^%s*", "")
					end
					if part ~= "nothing relevant" then
						table.insert(parts, part)
					end
				end

				for _, part in ipairs(parts) do
					local type_name, item_type
					if part:match("generator") then
						type_name = part:match("(%w+) generator")
						item_type = "G"
					elseif part:match("microchip") then
						if part:match("%-compatible microchip") then
							type_name = part:match("(%w+)%-compatible microchip")
						else
							type_name = part:match("(%w+) microchip")
						end
						item_type = "M"
					end
					if type_name and item_type then
						table.insert(floor_items, type_name .. item_type)
					end
				end
			end
			floors[i] = floor_items
		end
	end
	return floors
end

--- @function: Helper to get pairs from initial floor layout
--- @param floors table: the initial floor layout
--- @return table: the pairs from initial floor layout
local function get_pairs_from_floors(floors)
	local items = {} -- element -> {G=floor, M=floor}
	for _ = 1, 4 do
		for i = 1, 4 do
			for _, item_str in ipairs(floors[i]) do
				local element = item_str:sub(1, -2) -- "rutheniumG" -> "ruthenium"
				local type = item_str:sub(-1) -- "G" or "M"
				if not items[element] then
					items[element] = {}
				end
				items[element][type] = i
			end
		end

		local pairs_list = {}
		local keys = {}
		for k in pairs(items) do
			table.insert(keys, k)
		end
		table.sort(keys)

		for _, key in ipairs(keys) do
			local pair_floors = items[key]
			table.insert(pairs_list, { pair_floors.G, pair_floors.M })
		end
		return pairs_list
	end
end

--- @function: New state functions for pair-based representation
local function pairs_state_to_string(elevator, pairs)
	-- Sort pairs for a canonical representation
	table.sort(pairs, function(a, b)
		if a[1] ~= b[1] then
			return a[1] < b[1]
		end
		return a[2] < b[2]
	end)
	local parts = { tostring(elevator) }
	for _, p in ipairs(pairs) do
		table.insert(parts, p[1] .. "," .. p[2])
	end
	return table.concat(parts, "|")
end

--- @function: Helper to convert string to pairs state
--- @param state_str string: the string representation of pairs state
--- @return number|nil: the elevator
--- @return table: the pairs
local function string_to_pairs_state(state_str)
	local parts = {}
	for part in state_str:gmatch("[^|]+") do
		table.insert(parts, part)
	end
	local elevator = tonumber(parts[1])
	local pairs = {}
	for i = 2, #parts do
		local g, m = parts[i]:match("^(%d+),(%d+)$")
		table.insert(pairs, { tonumber(g), tonumber(m) })
	end
	return elevator, pairs
end

--- @function: New safety check for pair-based state
--- @param floor number: the floor
--- @param pairs table: the pairs
--- @return boolean: true if safe, false otherwise
local function is_floor_safe_pairs(floor, pairs)
	local has_unmatched_chip = false
	local has_any_generator = false
	for _, p in ipairs(pairs) do
		if p[2] == floor and p[1] ~= floor then
			has_unmatched_chip = true
		end
		if p[1] == floor then
			has_any_generator = true
		end
	end
	if has_unmatched_chip and has_any_generator then
		return false
	end
	return true
end

--- @function: New goal check for pair-based state
--- @param pairs table: the pairs
--- @return boolean: true if goal, false otherwise
local function is_goal_pairs(pairs)
	for _, p in ipairs(pairs) do
		if p[1] ~= 4 or p[2] ~= 4 then
			return false
		end
	end
	return true
end

--- @function: Helper for deep copy of pairs table
--- @param t table: the pairs
--- @return table: the deep copied pairs
local function deepcopy_pairs(t)
	local new_t = {}
	for i, v in ipairs(t) do
		new_t[i] = { v[1], v[2] }
	end
	return new_t
end

--- @function: Get all possible combinations of 1-2 items from a list
--- @param items table: the items
--- @return table: the combinations
local function get_item_combinations(items)
	local combos = {}
	-- Single items
	for i, item in ipairs(items) do
		table.insert(combos, { item })
	end
	-- Two items
	for i = 1, #items do
		for j = i + 1, #items do
			table.insert(combos, { items[i], items[j] })
		end
	end
	return combos
end

--- @function: BFS to find minimum steps with pair-based state
--- @param initial_pairs table: the initial pairs
--- @return number: the minimum steps
local function find_min_steps_pairs(initial_pairs)
	local queue = {}
	local visited = {}
	local initial_state = pairs_state_to_string(1, initial_pairs)
	table.insert(queue, { state = initial_state, steps = 0 })
	visited[initial_state] = true

	while #queue > 0 do
		local current = table.remove(queue, 1)
		local elevator, pairs = string_to_pairs_state(current.state)

		if is_goal_pairs(pairs) then
			return current.steps
		end

		-- Generate next moves
		local directions = {}
		if elevator < 4 then
			table.insert(directions, 1)
		end
		if elevator > 1 then
			table.insert(directions, -1)
		end

		for _, dir in ipairs(directions) do
			local new_elevator = elevator + dir
			local continue_dir_loop = false

			-- Pruning: Don't move things to floors that are empty below the elevator
			if dir == -1 then
				local lower_floors_empty = true
				for i = 1, #pairs do
					if pairs[i][1] < elevator or pairs[i][2] < elevator then
						lower_floors_empty = false
						break
					end
				end
				if lower_floors_empty then
					continue_dir_loop = true
				end
			end

			if not continue_dir_loop then
				local items_on_floor = {}
				for i = 1, #pairs do
					if pairs[i][1] == elevator then
						table.insert(items_on_floor, { type = "G", index = i })
					end
					if pairs[i][2] == elevator then
						table.insert(items_on_floor, { type = "M", index = i })
					end
				end

				local combos = get_item_combinations(items_on_floor)

				for _, items_to_move in ipairs(combos) do
					local new_pairs = deepcopy_pairs(pairs)

					-- Move items
					for _, item in ipairs(items_to_move) do
						if item.type == "G" then
							new_pairs[item.index][1] = new_elevator
						else
							new_pairs[item.index][2] = new_elevator
						end
					end

					-- Check safety of new state
					local safe = true
					for i = 1, 4 do
						if not is_floor_safe_pairs(i, new_pairs) then
							safe = false
							break
						end
					end

					if safe then
						local new_state = pairs_state_to_string(new_elevator, new_pairs)
						if not visited[new_state] then
							visited[new_state] = true
							table.insert(queue, { state = new_state, steps = current.steps + 1 })
						end
					end
				end
			end
		end
	end
	return -1 -- No solution found
end

--- @description Find minimum steps to move all items to floor 4
--- @param input string of floor descriptions
--- @return number minimum steps required
function M.part1(input)
	local floors = parse_input(input)
	local initial_pairs = get_pairs_from_floors(floors)
	return find_min_steps_pairs(initial_pairs)
end

--- @description Part 2 with additional items
--- @param input string of floor descriptions
--- @return number minimum steps required
function M.part2(input)
	local floors = parse_input(input)
	-- Add two more items to floor 1: elerium generator, elerium microchip, dilithium generator, dilithium microchip
	table.insert(floors[1], "eleriumG")
	table.insert(floors[1], "eleriumM")
	table.insert(floors[1], "dilithiumG")
	table.insert(floors[1], "dilithiumM")
	return find_min_steps_pairs(get_pairs_from_floors(floors))
end

return M
