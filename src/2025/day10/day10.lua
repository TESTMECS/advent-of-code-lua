local util = require("src.util")
local M = {}

-- Helper function to parse the button wiring schematic
---@param s string
---@return number[][]
local function parse_buttons(s)
	local buttons = {}
	for button_str in s:gmatch("%((.-)%)") do
		local indices = {}
		for index_str in button_str:gmatch("%d+") do
			table.insert(indices, tonumber(index_str))
		end
		table.insert(buttons, indices)
	end
	return buttons
end

-- Helper function to parse the target light diagram
---@param s string
---@return number[]
local function parse_target(s)
	local target = {}
	local diagram = s:match("%[([^%]]+)%]")
	for i = 1, #diagram do
		-- 0 for '.', 1 for '#'
		table.insert(target, diagram:sub(i, i) == "#" and 1 or 0)
	end
	return target
end

---@param line string
---@return number
local function solve_machine(line)
	local target_state = parse_target(line)
	local light_count = #target_state
	local button_indices = parse_buttons(line)
	-- local num_buttons = #button_indices
	-- Pre-calculate the vector for each button press
	local button_vectors = {}
	for _, indices in ipairs(button_indices) do
		local vector = {}
		for i = 1, light_count do
			vector[i] = 0
		end
		for _, index in ipairs(indices) do
			vector[index + 1] = 1
		end
		table.insert(button_vectors, vector)
	end
	-- BFS setup
	local init_state_str = string.rep("0", light_count)
	local target_state_str = table.concat(target_state)
	if init_state_str == target_state_str then
		return 0
	end
	local queue = { { state_str = init_state_str, distance = 0 } }
	local visited = { [init_state_str] = true }
	local head = 1
	while head <= #queue do
		local current = queue[head]
		head = head + 1
		local current_state_str = current.state_str
		local dist = current.distance
		-- Convert current state string to a light vector
		local current_lights = {}
		for i = 1, light_count do
			current_lights[i] = tonumber(current_state_str:sub(i, i))
		end
		-- Try pressing each button once
		for _, button_vector in ipairs(button_vectors) do
			local next_lights = {}
			for i = 1, light_count do
				-- print(current_lights[i]) -- nil
				-- print(button_vector[i])
				-- print(next_lights[i]) -- nil
				next_lights[i] = (current_lights[i] + button_vector[i]) % 2
			end
			local next_state_str = table.concat(next_lights)
			if next_state_str == target_state_str then
				return dist + 1
			end
			if not visited[next_state_str] then
				visited[next_state_str] = true
				table.insert(queue, {
					state_str = next_state_str,
					distance = dist + 1,
				})
			end
		end
	end
	return -1
end

---@param input string
---@return number
function M.part1(input)
	local total_min_presses = 0
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	for _, line in ipairs(lines) do
		local min_presses = solve_machine(line)
		total_min_presses = total_min_presses + min_presses
	end
	return total_min_presses
end

-- local function trim(s)
-- 	return s:match("^%s*(.-)%s*$")
-- end

---@param s string
---@return number[]
local function parse_requirements(s)
	local reqs = {}
	local req_str = s:match("{([%d,]+)}")
	for num in req_str:gmatch("%d+") do
		table.insert(reqs, tonumber(num))
	end
	return reqs
end

-- Deep copy a matrix
-- local function copy_matrix(m)
-- 	local new_m = {}
-- 	for i, row in ipairs(m) do
-- 		new_m[i] = {}
-- 		for j, val in ipairs(row) do
-- 			new_m[i][j] = val
-- 		end
-- 	end
-- 	return new_m
-- end

---@param line string
---@return number
local function solve_machine2(line)
	local targets = parse_requirements(line)
	local button_defs = parse_buttons(line)

	local num_eq = #targets
	local num_vars = #button_defs

	local matrix = {}
	for r = 1, num_eq do
		matrix[r] = {}
		for c = 1, num_vars do
			matrix[r][c] = 0
		end
		matrix[r][num_vars + 1] = targets[r]
	end
	-- Fill in the button effects
	for c, indices in ipairs(button_defs) do
		for _, r_idx in ipairs(indices) do
			matrix[r_idx + 1][c] = 1
		end
	end
	local pivot_row = 1
	local pivot_cols = {}
	-- local free_vars = {}
	local free_cols = {}

	for c = 1, num_vars do
		local r_pivot = pivot_row
		while r_pivot <= num_eq and matrix[r_pivot][c] == 0 do
			r_pivot = r_pivot + 1
		end
		if r_pivot <= num_eq then
			matrix[pivot_row], matrix[r_pivot] = matrix[r_pivot], matrix[pivot_row]
			local pivot_val = matrix[pivot_row][c]
			for j = c, num_vars + 1 do
				matrix[pivot_row][j] = matrix[pivot_row][j] / pivot_val
			end
			-- Eliminate other rows
			for r = 1, num_eq do
				if r ~= pivot_row and matrix[r][c] ~= 0 then
					local factor = matrix[r][c]
					for j = c, num_vars + 1 do
						matrix[r][j] = matrix[r][j] - factor * matrix[pivot_row][j]
					end
				end
			end
			pivot_cols[c] = pivot_row
			pivot_row = pivot_row + 1
		else
			table.insert(free_cols, c)
		end
	end
	-- Backtracking
	local min_total_presses = math.huge

	---@param n number
	---@return boolean
	local function is_int(n)
		return math.abs(n - math.floor(n + 0.5)) < 1e-9
	end
	---@param n number
	---@return number
	local function round(n)
		return math.floor(n + 0.5)
	end
	---@param free_idx number
	---@param current_vars table<number, number>
	---@return nil
	local function search(free_idx, current_vars)
		if free_idx > #free_cols then
			-- local total = 0
			local valid = true
			local temp_vars = {}
			for i = 1, num_vars do
				temp_vars[i] = current_vars[i] or 0
			end
			for c = 1, num_vars do
				if pivot_cols[c] then
					local r = pivot_cols[c]
					local val = matrix[r][num_vars + 1]
					for _, fc in ipairs(free_cols) do
						val = val - matrix[r][fc] * (temp_vars[fc] or 0)
					end
					if val < -1e-9 or not is_int(val) then
						valid = false
						break
					end
					temp_vars[c] = round(val)
				end
			end
			if valid then
				local sum = 0
				for i = 1, num_vars do
					sum = sum + temp_vars[i]
				end
				if sum < min_total_presses then
					min_total_presses = sum
				end
			end
			return
		end
		local col_idx = free_cols[free_idx]
		local max_limit = 0
		for _, t in ipairs(targets) do
			if t > max_limit then
				max_limit = t
			end
		end
		for val = 0, max_limit do
			current_vars[col_idx] = val
			search(free_idx + 1, current_vars)
			current_vars[col_idx] = nil
		end
	end
	search(1, {})
	if min_total_presses == math.huge then
		return 0
	end
	return min_total_presses
end
---@diagnostic disable
local ex = [[
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
]]
---@description takes around 30 seconds on my machine.
---@param input string
---@return number
function M.part2(input)
	local total_presses = 0
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local min_presses = solve_machine2(line)
		total_presses = total_presses + min_presses
	end
	return total_presses
end

return M
