--- @title: Day 15: Beverage Bandits ---
local M = {}

--- @function: Helper for reading order sorting (for units, positions, etc.)
--- @param a table
--- @param b table
--- @return boolean
local function reading_order_sort(a, b)
	if a.y == b.y then
		return a.x < b.x
	end
	return a.y < b.y
end

--- @function: Parses the input string into a grid and a list of units.
--- @param input string
--- @return table, table
local function parse_input(input)
	local grid = {}
	local units = {}
	local y = 1
	for line in input:gmatch("[^\n]+") do
		grid[y] = {}
		for x = 1, #line do
			local char = line:sub(x, x)
			grid[y][x] = char
			if char == "E" or char == "G" then
				table.insert(units, {
					x = x,
					y = y,
					type = char,
					hp = 200,
					ap = 3, -- Default AP
				})
			end
		end
		y = y + 1
	end
	return grid, units
end

-- Directions in reading order: Up, Left, Right, Down
local DIRS = { { y = -1, x = 0 }, { y = 0, x = -1 }, { y = 0, x = 1 }, { y = 1, x = 0 } }

--- @function: The main simulation function, generalized for both parts.
--- @param initial_grid table: The starting map layout.
--- @param initial_units table: The starting list of units.
--- @param elf_ap number: The attack power for all elves.
--- @param fail_on_elf_death boolean: If true, aborts immediately if an elf dies (for Part 2)
--- @return boolean combat_ended_cleanly, number final_score, boolean elves_won
local function run_simulation(initial_grid, initial_units, elf_ap, fail_on_elf_death)
	-- Deep copy state to not modify the originals between runs
	local grid = {}
	for y, row in ipairs(initial_grid) do
		grid[y] = {}
		for x, cell in ipairs(row) do
			grid[y][x] = cell
		end
	end
	local units = {}
	local initial_elf_count = 0
	for _, u in ipairs(initial_units) do
		local new_unit = { x = u.x, y = u.y, type = u.type, hp = u.hp, ap = u.ap }
		if new_unit.type == "E" then
			new_unit.ap = elf_ap
			initial_elf_count = initial_elf_count + 1
		end
		table.insert(units, new_unit)
	end

	local rounds = 0
	while true do
		-- Sort units by reading order for the upcoming round
		table.sort(units, reading_order_sort)

		for i = 1, #units do
			local unit = units[i]
			if unit.hp <= 0 then
				goto continue_turn
			end -- Skip dead units

			-- 1. Identify targets
			local targets = {}
			local target_type = (unit.type == "E" and "G" or "E")
			for _, other in ipairs(units) do
				if other.hp > 0 and other.type == target_type then
					table.insert(targets, other)
				end
			end

			-- If no targets, combat ends
			if #targets == 0 then
				local remaining_hp = 0
				for _, u in ipairs(units) do
					if u.hp > 0 then
						remaining_hp = remaining_hp + u.hp
					end
				end
				local score = rounds * remaining_hp
				local elves_won = unit.type == "E"
				return true, score, elves_won
			end

			-- 2. Check if already in range of a target
			local in_range = false
			for _, dir in ipairs(DIRS) do
				local nx, ny = unit.x + dir.x, unit.y + dir.y
				if grid[ny][nx] == target_type then
					in_range = true
					break
				end
			end

			-- 3. If not in range, move
			if not in_range then
				-- Find all open squares adjacent to targets
				local in_range_squares = {}
				local visited_in_range = {}
				for _, target in ipairs(targets) do
					for _, dir in ipairs(DIRS) do
						local nx, ny = target.x + dir.x, target.y + dir.y
						if grid[ny][nx] == "." then
							local key = ny .. "," .. nx
							if not visited_in_range[key] then
								table.insert(in_range_squares, { x = nx, y = ny })
								visited_in_range[key] = true
							end
						end
					end
				end

				-- BFS to find the closest reachable in-range square
				local q = { { x = unit.x, y = unit.y, dist = 0, path = {} } }
				local visited = { [unit.y .. "," .. unit.x] = true }
				local found_paths = {}

				while #q > 0 do
					local curr = table.remove(q, 1)

					-- If we found a path to an in-range square, store it
					for _, dest in ipairs(in_range_squares) do
						if curr.x == dest.x and curr.y == dest.y then
							table.insert(found_paths, curr)
						end
					end

					-- Stop BFS if we've gone past the shortest possible path length
					if #found_paths > 0 and curr.dist >= found_paths[1].dist then
						goto continue_bfs
					end

					for _, dir in ipairs(DIRS) do
						local nx, ny = curr.x + dir.x, curr.y + dir.y
						local key = ny .. "," .. nx
						if grid[ny][nx] == "." and not visited[key] then
							visited[key] = true
							local new_path = {}
							for _, p in ipairs(curr.path) do
								table.insert(new_path, p)
							end
							table.insert(new_path, { x = nx, y = ny })
							table.insert(q, { x = nx, y = ny, dist = curr.dist + 1, path = new_path })
						end
					end
					::continue_bfs::
				end

				if #found_paths > 0 then
					-- Sort found paths by distance, then destination reading order
					table.sort(found_paths, function(a, b)
						if a.dist == b.dist then
							return reading_order_sort(a, b)
						end
						return a.dist < b.dist
					end)

					-- The best destination is the first one after sorting
					local best_path = found_paths[1]
					local step = best_path.path[1]

					-- Move the unit
					grid[unit.y][unit.x] = "."
					unit.x, unit.y = step.x, step.y
					grid[unit.y][unit.x] = unit.type
				end
			end

			-- 4. Attack if possible
			local adjacent_targets = {}
			for _, dir in ipairs(DIRS) do
				local nx, ny = unit.x + dir.x, unit.y + dir.y
				if grid[ny][nx] == target_type then
					for _, t in ipairs(targets) do
						if t.x == nx and t.y == ny and t.hp > 0 then
							table.insert(adjacent_targets, t)
							break
						end
					end
				end
			end

			if #adjacent_targets > 0 then
				-- Choose target: lowest HP, then reading order
				table.sort(adjacent_targets, function(a, b)
					if a.hp == b.hp then
						return reading_order_sort(a, b)
					end
					return a.hp < b.hp
				end)

				local target_to_attack = adjacent_targets[1]
				target_to_attack.hp = target_to_attack.hp - unit.ap

				if target_to_attack.hp <= 0 then
					grid[target_to_attack.y][target_to_attack.x] = "."
					-- For Part 2, check if an Elf died
					if fail_on_elf_death and target_to_attack.type == "E" then
						return false, 0, false -- Abort this simulation
					end
				end
			end

			::continue_turn::
		end

		-- Cleanup dead units from the list at the end of the turn loop
		local living_units = {}
		for _, u in ipairs(units) do
			if u.hp > 0 then
				table.insert(living_units, u)
			end
		end
		units = living_units

		rounds = rounds + 1
	end
end

--- @description The outcome of the battle is the number of full rounds that were completed, multiplied by the sum of the hit points of all remaining units.
--- @param input string the puzzle input
--- @return number The battle's outcome score.
function M.part1(input)
	local initial_grid, initial_units = parse_input(input)
	local _, score = run_simulation(initial_grid, initial_units, 3, false)
	return score
end

--- @description Find the lowest attack power for Elves that results in a victory for the Elves with no casualties.
--- @param input string the puzzle input
--- @return number The outcome score of that winning battle.
function M.part2(input)
	local initial_grid, initial_units = parse_input(input)
	local elf_ap = 4
	while true do
		local success, score, elves_won = run_simulation(initial_grid, initial_units, elf_ap, true)
		if success and elves_won then
			return score
		end
		elf_ap = elf_ap + 1
	end
end

return M
