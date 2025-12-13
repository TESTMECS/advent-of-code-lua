--- @title: Day 08: Memory Maneuver ---
local M = {}

--- @description: Sums all metadata entries in the tree
--- @param input string: the puzzle input
--- @return number: the sum of metadata
function M.part1(input)
	local nums = {}
	for num in input:gmatch("%d+") do
		table.insert(nums, tonumber(num))
	end
	local function parse_tree(index)
		local children_count = nums[index]
		local metadata_count = nums[index + 1]
		index = index + 2
		local children = {}
		for i = 1, children_count do
			local child, new_index = parse_tree(index)
			table.insert(children, child)
			index = new_index
		end
		local metadata = {}
		for i = 1, metadata_count do
			table.insert(metadata, nums[index])
			index = index + 1
		end
		return { children = children, metadata = metadata }, index
	end
	local root, _ = parse_tree(1)
	local function sum_metadata(node)
		local sum = 0
		for _, m in ipairs(node.metadata) do
			sum = sum + m
		end
		for _, child in ipairs(node.children) do
			sum = sum + sum_metadata(child)
		end
		return sum
	end
	return sum_metadata(root)
end

--- @description: Calculates the value of the root node
--- @param input string: the puzzle input
--- @return number: the value of the root
function M.part2(input)
	local nums = {}
	for num in input:gmatch("%d+") do
		table.insert(nums, tonumber(num))
	end
	local function parse_tree(index)
		local children_count = nums[index]
		local metadata_count = nums[index + 1]
		index = index + 2
		local children = {}
		for i = 1, children_count do
			local child, new_index = parse_tree(index)
			table.insert(children, child)
			index = new_index
		end
		local metadata = {}
		for i = 1, metadata_count do
			table.insert(metadata, nums[index])
			index = index + 1
		end
		return { children = children, metadata = metadata }, index
	end
	local root, _ = parse_tree(1)
	local function value(node)
		if #node.children == 0 then
			local sum = 0
			for _, m in ipairs(node.metadata) do
				sum = sum + m
			end
			return sum
		else
			local sum = 0
			for _, m in ipairs(node.metadata) do
				if m >= 1 and m <= #node.children then
					sum = sum + value(node.children[m])
				end
			end
			return sum
		end
	end
	return value(root)
end

return M
