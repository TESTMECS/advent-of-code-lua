--- @title: Day 7: Recursive Circus ---
local M = {}

--- @description: Find the root program in the tower
--- @param input string: the list of programs
--- @return string: the name of the root program
function M.part1(input)
	local programs = {}
	local all_children = {}
	-- Parse each line
	for line in input:gmatch("[^\n]+") do
		local name, weight, children_str = line:match("(%w+) %((%d+)%)%s*%-*>?%s*(.*)")
		local children = {}
		if children_str and children_str ~= "" then
			for child in children_str:gmatch("%w+") do
				table.insert(children, child)
				all_children[child] = true
			end
		end
		programs[name] = { weight = tonumber(weight), children = children }
	end
	-- Find the program that is not a child
	local root
	for name in pairs(programs) do
		if not all_children[name] then
			root = name
			break
		end
	end
	return root
end

--- @description: Find the correct weight for the unbalanced program
--- @param input string: the list of programs
--- @return number: the correct weight
function M.part2(input)
	local programs = {}
	local all_children = {}
	-- Parse each line
	for line in input:gmatch("[^\n]+") do
		local name, weight, children_str = line:match("(%w+) %((%d+)%)%s*%-*>?%s*(.*)")
		local children = {}
		if children_str and children_str ~= "" then
			for child in children_str:gmatch("%w+") do
				table.insert(children, child)
				all_children[child] = true
			end
		end
		programs[name] = { weight = tonumber(weight), children = children }
	end
	-- Find the root
	local root
	for name in pairs(programs) do
		if not all_children[name] then
			root = name
			break
		end
	end
	-- Function to get total weight
	local function get_total(name)
		local p = programs[name]
		local total = p.weight
		for _, child in ipairs(p.children) do
			total = total + get_total(child)
		end
		return total
	end
	-- Function to find unbalanced
	local function find_unbalanced(name)
		local p = programs[name]
		if #p.children == 0 then
			return nil, nil
		end
		local child_totals = {}
		local child_weights = {}
		for _, child in ipairs(p.children) do
			local total = get_total(child)
			table.insert(child_totals, total)
			child_weights[child] = total
		end
		-- Find the common weight
		local count = {}
		for _, t in ipairs(child_totals) do
			count[t] = (count[t] or 0) + 1
		end
		local common
		for t, c in pairs(count) do
			if c > 1 then
				common = t
				break
			end
		end
		-- Find the odd one
		for child, total in pairs(child_weights) do
			if total ~= common then
				local sub_unbal, sub_weight = find_unbalanced(child)
				if sub_unbal then
					return sub_unbal, sub_weight
				else
					local diff = common - total
					return child, programs[child].weight + diff
				end
			end
		end
		return nil, nil
	end
	local _, correct_weight = find_unbalanced(root)
	return correct_weight
end

return M
