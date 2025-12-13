--- @title: Day 14: Extended Polymerization ---
local M = {}

--- @description: Parses the input into a template string and a rules table.
--- @param input string: The puzzle input.
--- @return string, table: The template and the insertion rules.
local function parse_input(input)
	-- A cleaner way to parse is to split by the blank line.
	local template_str, rules_str = input:match("([^\n]+)\n\n(.+)")

	local rules = {}
	for line in rules_str:gmatch("[^\r\n]+") do
		local pair, insert = line:match("(%w%w)%s*->%s*(%w)")
		if pair then
			rules[pair] = insert
		end
	end

	return template_str, rules
end

--- @description: Perform 10 steps of polymerization and calculate the difference.
--- @param input string: The puzzle input.
--- @return number: The difference between the minimum and maximum character counts.
function M.part1(input)
	local template, rules = parse_input(input)

	for _ = 1, 10 do
		local new_template = ""
		-- Iterate through pairs, building the new string.
		for i = 1, #template - 1 do
			local pair = template:sub(i, i + 1)
			local insert = rules[pair]
			new_template = new_template .. template:sub(i, i) -- Add first char of the pair
			if insert then
				new_template = new_template .. insert -- Add the new char if a rule exists
			end
		end
		template = new_template .. template:sub(#template)
	end

	local counts = {}
	for char in template:gmatch(".") do
		counts[char] = (counts[char] or 0) + 1
	end

	local min_c, max_c = math.huge, 0
	for _, count in pairs(counts) do
		min_c = math.min(min_c, count)
		max_c = math.max(max_c, count)
	end
	return max_c - min_c
end

--- @description Perform 40 steps of polymerization using pair counting.
--- @param input string: The puzzle input.
--- @return number: The difference between the minimum and maximum character counts.
function M.part2(input)
	local template, rules = parse_input(input)

	-- Initialize character counts from the starting template.
	local char_counts = {}
	for char in template:gmatch(".") do
		char_counts[char] = (char_counts[char] or 0) + 1
	end

	-- Initialize pair counts from the starting template.
	local pair_counts = {}
	for i = 1, #template - 1 do
		local pair = template:sub(i, i + 1)
		pair_counts[pair] = (pair_counts[pair] or 0) + 1
	end

	for _ = 1, 40 do
		local new_pair_counts = {}
		for pair, count in pairs(pair_counts) do
			local insert = rules[pair]
			if insert then
				-- This pair (e.g., NN) gets replaced by two new pairs (NC, CN).
				local p1 = pair:sub(1, 1) .. insert
				local p2 = insert .. pair:sub(2, 2)
				new_pair_counts[p1] = (new_pair_counts[p1] or 0) + count
				new_pair_counts[p2] = (new_pair_counts[p2] or 0) + count

				-- For each transformation, we add 'count' new characters.
				char_counts[insert] = (char_counts[insert] or 0) + count
			else
				-- **THE FIX:** If no rule exists, the pair persists. Carry it over.
				new_pair_counts[pair] = (new_pair_counts[pair] or 0) + count
			end
		end
		pair_counts = new_pair_counts
	end

	local min_c, max_c = math.huge, 0
	for _, count in pairs(char_counts) do
		min_c = math.min(min_c, count)
		max_c = math.max(max_c, count)
	end
	return max_c - min_c
end

return M
