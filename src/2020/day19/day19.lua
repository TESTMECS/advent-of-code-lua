--- @title: Day 19: Monster Messages ---
local M = {}

--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
--- @return table
local function parse_input(input)
	input = input:gsub("\r", "")
	local rules_str, messages_str = input:match("(.+)\n\n(.+)")

	local rules = {}
	for line in rules_str:gmatch("[^\n]+") do
		local id, rest = line:match("(%d+): (.+)")
		rules[tonumber(id)] = rest
	end

	local messages = {}
	for line in messages_str:gmatch("[^\n]+") do
		table.insert(messages, line)
	end
	return rules, messages
end

--- @description: Recursively finds all possible end positions for a rule match.
--- @param rules table: The table of all rules.
--- @param rule_id number: The ID of the current rule to match.
--- @param str string: The message string to match against.
--- @param pos number: The starting position in the string.
--- @param memo table: The memoization table to cache results.
--- @return table: A list of all possible positions in the string where this rule could finish matching.
local function get_end_positions(rules, rule_id, str, pos, memo)
	-- Memoization: If we've already computed this result, return the cached version.
	if memo[rule_id] and memo[rule_id][pos] then
		return memo[rule_id][pos]
	end

	-- If we're trying to match past the end of the string, it's a failure.
	if pos > #str then
		return {}
	end

	local rule = rules[rule_id]
	local final_positions = {}

	-- Base case: The rule is a single character like "a".
	if rule:match('^"(.+)"$') then
		local char = rule:match('^"(.+)"$')
		if str:sub(pos, pos) == char then
			table.insert(final_positions, pos + 1)
		end
	else
		-- Recursive case: The rule is a series of other rules (e.g., "42 31 | 42 11 31").
		for alternative in rule:gmatch("[^|]+") do
			local sub_rule_ids = {}
			for id in alternative:gmatch("%d+") do
				table.insert(sub_rule_ids, tonumber(id))
			end

			-- We start with our current position. This list will hold the end
			-- positions after each sub-rule in the sequence is matched.
			local current_positions = { pos }

			for _, sub_rule_id in ipairs(sub_rule_ids) do
				local next_positions = {}
				for _, p in ipairs(current_positions) do
					-- Recursively find where the sub-rule can end.
					local results = get_end_positions(rules, sub_rule_id, str, p, memo)
					-- Add all successful end positions to the list for the next sub-rule.
					for _, res_pos in ipairs(results) do
						table.insert(next_positions, res_pos)
					end
				end
				current_positions = next_positions
				-- If at any point a sub-rule can't be matched, this alternative fails.
				if #current_positions == 0 then
					break
				end
			end

			-- Add all the final positions from this successful alternative to our main list.
			for _, p in ipairs(current_positions) do
				table.insert(final_positions, p)
			end
		end
	end

	-- Cache the result before returning.
	if not memo[rule_id] then
		memo[rule_id] = {}
	end
	memo[rule_id][pos] = final_positions
	return final_positions
end

--- @description: Count messages matching rule 0
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local rules, messages = parse_input(input)
	local count = 0
	for _, msg in ipairs(messages) do
		-- For each message, create a fresh memoization table.
		local memo = {}
		local end_positions = get_end_positions(rules, 0, msg, 1, memo)

		-- Check if any of the possible matches consumed the entire string.
		for _, pos in ipairs(end_positions) do
			if pos == #msg + 1 then
				count = count + 1
				break -- Count this message only once.
			end
		end
	end
	return count
end

--- @description: Count messages with modified rules
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local rules, messages = parse_input(input)
	-- Apply the rule changes for Part 2.
	rules[8] = "42 | 42 8"
	rules[11] = "42 31 | 42 11 31"

	local count = 0
	for _, msg in ipairs(messages) do
		-- For each message, create a fresh memoization table.
		local memo = {}
		local end_positions = get_end_positions(rules, 0, msg, 1, memo)

		-- Check if any of the possible matches consumed the entire string.
		for _, pos in ipairs(end_positions) do
			if pos == #msg + 1 then
				count = count + 1
				break -- Count this message only once.
			end
		end
	end
	return count
end

return M
