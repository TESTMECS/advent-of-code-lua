--- @title: Day 18: Snailfish ---
local M = {}

--- @function: Parse a string into a tree structure. Returns the tree and the final position.
--- @param s string: The input string.
--- @param pos number: The starting position.
--- @return table, number: The parsed tree and the final position.
local function parse_snailfish(s, pos)
	pos = pos or 1
	if s:sub(pos, pos) == "[" then
		pos = pos + 1 -- Skip '['
		local left, left_pos = parse_snailfish(s, pos)
		pos = left_pos + 1 -- Skip ','
		local right, right_pos = parse_snailfish(s, pos)
		pos = right_pos + 1 -- Skip ']'
		local node = { left = left, right = right }
		left.parent = node
		right.parent = node -- Add parent reference
		return node, pos
	else
		local num_str, next_pos = s:match("^(%d+)", pos)
		return { value = tonumber(num_str), parent = nil }, pos + #num_str
	end
end

--- @function: Creates a full, independent copy of a snailfish number tree.
--- @param node table: The node to copy.
--- @return table: The copied node.
local function deep_copy(node)
	if node.value then
		return { value = node.value }
	end
	local new_node = { left = deep_copy(node.left), right = deep_copy(node.right) }
	new_node.left.parent = new_node
	new_node.right.parent = new_node
	return new_node
end

--- @function: Helper to find the first pair to explode (depth 4) via DFS.
--- @param node table: The current node.
--- @param depth number: The current depth.
--- @return table: The target node, or nil if not found.
local function find_explode_target(node, depth)
	if node.value then
		return nil
	end
	if depth >= 4 and node.left.value and node.right.value then
		return node
	end
	local target = find_explode_target(node.left, depth + 1)
	if target then
		return target
	end
	return find_explode_target(node.right, depth + 1)
end

--- @function: Helper to find the first number to split (>= 10) via DFS.
--- @param node table: The current node.
--- @return table: The target node, or nil if not found.
local function find_split_target(node)
	if node.value then
		return node.value >= 10 and node or nil
	end
	local target = find_split_target(node.left)
	if target then
		return target
	end
	return find_split_target(node.right)
end

--- @function: Gets a flat list of all number nodes via in-order traversal.
--- @param node table: The current node.
--- @param list table: The list to add to.
--- @return table: The list.
local function get_in_order_numbers(node, list)
	list = list or {}
	if node.value then
		table.insert(list, node)
	else
		get_in_order_numbers(node.left, list)
		get_in_order_numbers(node.right, list)
	end
	return list
end

--- @function: The main reduction loop.
--- @param snail table: The snailfish tree.
local function reduce(snail)
	while true do
		-- 1. Check for explosions
		local explode_node = find_explode_target(snail, 0)
		if explode_node then
			local left_val, right_val = explode_node.left.value, explode_node.right.value
			local flat_numbers = get_in_order_numbers(snail)

			-- Find neighbors in the flat list
			for i, num_node in ipairs(flat_numbers) do
				if num_node == explode_node.left then
					if i > 1 then
						flat_numbers[i - 1].value = flat_numbers[i - 1].value + left_val
					end
				end
				if num_node == explode_node.right then
					if i < #flat_numbers then
						flat_numbers[i + 1].value = flat_numbers[i + 1].value + right_val
					end
				end
			end

			-- Replace the exploded node with 0
			explode_node.value = 0
			explode_node.left, explode_node.right = nil, nil
			goto continue -- Restart the reduction process
		end

		-- 2. Check for splits
		local split_node = find_split_target(snail)
		if split_node then
			local val = split_node.value
			split_node.value = nil
			split_node.left = { value = math.floor(val / 2), parent = split_node }
			split_node.right = { value = math.ceil(val / 2), parent = split_node }
			goto continue -- Restart the reduction process
		end

		-- 3. If nothing happened, we're done.
		if not explode_node and not split_node then
			break
		end
		::continue::
	end
end

--- @function: Calculates the final magnitude.
--- @param node table: The snailfish tree.
--- @return number: The magnitude.
local function magnitude(node)
	if node.value ~= nil then
		return node.value
	end
	return 3 * magnitude(node.left) + 2 * magnitude(node.right)
end

--------------------------------------------------------------------------------
-- Main Solver Functions
--------------------------------------------------------------------------------

--- @description: Calculate the magnitude of the snailfish tree
--- @param input string: the puzzle input
--- @return number: the magnitude
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local current, _ = parse_snailfish(lines[1])
	for i = 2, #lines do
		local next_num, _ = parse_snailfish(lines[i])
		local new_sum = { left = current, right = next_num }
		current.parent = new_sum
		next_num.parent = new_sum
		current = new_sum
		reduce(current)
	end

	return magnitude(current)
end

--- @description: Calculate the maximum magnitude of the snailfish tree
--- @param input string: the puzzle input
--- @return number: the maximum magnitude
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local max_mag = 0
	for i = 1, #lines do
		for j = 1, #lines do
			if i ~= j then
				-- Must parse and copy fresh versions for each addition
				local n1, _ = parse_snailfish(lines[i])
				local n2, _ = parse_snailfish(lines[j])

				-- Add n1 + n2
				local sum1 = { left = deep_copy(n1), right = deep_copy(n2) }
				sum1.left.parent, sum1.right.parent = sum1, sum1
				reduce(sum1)
				max_mag = math.max(max_mag, magnitude(sum1))

				-- Add n2 + n1
				local sum2 = { left = deep_copy(n2), right = deep_copy(n1) }
				sum2.left.parent, sum2.right.parent = sum2, sum2
				reduce(sum2)
				max_mag = math.max(max_mag, magnitude(sum2))
			end
		end
	end

	return max_mag
end

return M
