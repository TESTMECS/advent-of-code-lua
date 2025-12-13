--- @title: --- Day 19: Aplenty ---
local M = {}

--- @description: Sums the ratings of all accepted parts
--- @return number: the sum of ratings for accepted parts
function M.part1(_)
	local input_path = "src/2023/day19/input"
	local total_sum = 0

	local function create_comparator(x, comparison_operator)
		if comparison_operator == "<" then
			return function(value)
				return value < x
			end
		else
			return function(value)
				return value > x
			end
		end
	end

	local function always_accept(_)
		return true
	end

	local read_rule_stage = 1
	local pipelines = {}
	for line in io.lines(input_path) do
		if line == "" then
			read_rule_stage = read_rule_stage + 1
			goto continue
		end

		if read_rule_stage == 1 then
			local pipeline_name = ""
			for name in line:gmatch("([A-Za-z]+){") do
				pipeline_name = name
			end

			pipelines[pipeline_name] = {}
			for property, comparison_operator, value, transition in line:gmatch("([A-Za-z]+)([<>])(%d+):([A-Za-z]+),") do
				table.insert(
					pipelines[pipeline_name],
					{ property, create_comparator(tonumber(value), comparison_operator), transition }
				)
			end

			for transition in line:gmatch(",([A-Za-z]+)}") do
				table.insert(pipelines[pipeline_name], { "x", always_accept, transition })
			end
		else
			local variables = {}
			for feature, value in line:gmatch("([xmas]+)=(%d+)") do
				variables[feature] = tonumber(value)
			end

			local pipeline = "in"
			while true do
				local current_pipeline = pipelines[pipeline]
				for _, rule in ipairs(current_pipeline) do
					local feature, comparator, transition = table.unpack(rule)
					if comparator(variables[feature]) then
						pipeline = transition
						break
					end
				end

				if pipeline == "A" then
					local sum = 0
					for _, value in pairs(variables) do
						sum = sum + value
					end
					total_sum = total_sum + sum
					break
				elseif pipeline == "R" then
					break
				end
			end
		end
		::continue::
	end
	return total_sum
end

--- @description: Counts the number of distinct combinations of ratings that are accepted
--- @param input string: the puzzle input
--- @return number: the number of accepted combinations
function M.part2(input)
	local workflows = {}
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")
		if line == "" then
			break
		end
		local start = line:find("{")
		local name = line:sub(1, start - 1)
		local rules_str = line:sub(start + 1, -2)
		local rules = {}
		for rule in rules_str:gmatch("([^,]+)") do
			rule = rule:gsub("^%s*(.-)%s*$", "%1")
			local cond, dest = rule:match("(.+):(.+)")
			if cond then
				cond = cond:gsub("^%s*(.-)%s*$", "%1")
				local cat, op, num_str = cond:match("(%w)%s*([<>])%s*(%d+)")
				table.insert(rules, { cat = cat, op = op, num = tonumber(num_str), dest = dest })
			else
				table.insert(rules, { dest = rule })
			end
		end
		workflows[name] = rules
	end

	local function copy(t)
		local nt = {}
		for k, v in pairs(t) do
			nt[k] = { min = v.min, max = v.max }
		end
		return nt
	end

	local function count_accepted(ranges, wf)
		-- Base case: Reached an "Accept" state. Calculate the volume of the valid range.
		if wf == "A" then
			local vol = 1
			for _, r in pairs(ranges) do
				-- If a range is invalid (e.g., min > max), its size is 0.
				if r.max < r.min then
					return 0
				end
				vol = vol * (r.max - r.min + 1)
			end
			return vol
		-- Base case: Reached a "Reject" state.
		elseif wf == "R" then
			return 0
		end

		local total = 0
		local rules = workflows[wf]
		-- This is the range that will be passed down to subsequent rules in this workflow.
		-- It starts as a copy of the input ranges.
		local remaining_ranges = copy(ranges)

		for _, rule in ipairs(rules) do
			-- A. Unconditional Rule (the "else" case)
			if not rule.cat then
				-- This rule gets all the remaining combinations.
				total = total + count_accepted(remaining_ranges, rule.dest)
				-- Since this rule consumes the rest of the range, no other rules can be processed.
				return total
			end

			-- B. Conditional Rule
			local cat, op, num = rule.cat, rule.op, rule.num

			-- Create a range for the "true" path (where the condition is met).
			local true_path_ranges = copy(remaining_ranges)

			if op == ">" then
				-- The part of the range that satisfies the condition.
				true_path_ranges[cat].min = math.max(true_path_ranges[cat].min, num + 1)
				-- The part that does NOT satisfy it is passed to the next rule.
				remaining_ranges[cat].max = math.min(remaining_ranges[cat].max, num)
			else -- op == "<"
				-- The part of the range that satisfies the condition.
				true_path_ranges[cat].max = math.min(true_path_ranges[cat].max, num - 1)
				-- The part that does NOT satisfy it is passed to the next rule.
				remaining_ranges[cat].min = math.max(remaining_ranges[cat].min, num)
			end

			-- If the "true" path contains a valid range, recurse on it and add to the total.
			if true_path_ranges[cat].min <= true_path_ranges[cat].max then
				total = total + count_accepted(true_path_ranges, rule.dest)
			end

			-- If the "remaining" range has become invalid, we can stop processing rules.
			if remaining_ranges[cat].min > remaining_ranges[cat].max then
				return total
			end
		end

		return total
	end

	local initial_ranges = {
		x = { min = 1, max = 4000 },
		m = { min = 1, max = 4000 },
		a = { min = 1, max = 4000 },
		s = { min = 1, max = 4000 },
	}
	return count_accepted(initial_ranges, "in")
end

return M
