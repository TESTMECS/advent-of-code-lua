--- @title: Day 11: Monkey in the Middle ---
local M = {}

local function parse_monkeys(input)
	local monkeys = {}
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	local i = 1
	while i <= #lines do
		if lines[i]:match("Monkey %d+:") then
			local monkey = {}
			i = i + 1 -- Starting items
			local items_str = lines[i]:match("Starting items: (.+)")
			monkey.items = {}
			for num in items_str:gmatch("(%d+)") do
				table.insert(monkey.items, tonumber(num))
			end
			i = i + 1 -- Operation
			local op_str = lines[i]:match("Operation: new = (.+)")
			local left, op, right = op_str:match("(%w+) ([%+%*]) (.+)")
			monkey.op = function(old)
				local l = left == "old" and old or tonumber(left)
				local r = right == "old" and old or tonumber(right)
				if op == "+" then
					return l + r
				elseif op == "*" then
					return l * r
				end
			end
			i = i + 1 -- Test
			local div = tonumber(lines[i]:match("divisible by (%d+)"))
			monkey.test = div
			i = i + 1 -- If true
			local true_m = tonumber(lines[i]:match("throw to monkey (%d+)"))
			monkey.true_monkey = true_m
			i = i + 1 -- If false
			local false_m = tonumber(lines[i]:match("throw to monkey (%d+)"))
			monkey.false_monkey = false_m
			monkey.inspected = 0
			table.insert(monkeys, monkey)
		end
		i = i + 1
	end
	return monkeys
end

--- @description Calculate monkey business after 20 rounds with worry reduction
--- @param input string the puzzle input
--- @return number the monkey business level
function M.part1(input)
	local monkeys = parse_monkeys(input)
	for round = 1, 20 do
		for _, monkey in ipairs(monkeys) do
			for _, item in ipairs(monkey.items) do
				monkey.inspected = monkey.inspected + 1
				local worry = monkey.op(item)
				worry = math.floor(worry / 3)
				local target = (worry % monkey.test == 0) and monkey.true_monkey or monkey.false_monkey
				table.insert(monkeys[target + 1].items, worry)
			end
			monkey.items = {}
		end
	end
	local inspects = {}
	for _, m in ipairs(monkeys) do
		table.insert(inspects, m.inspected)
	end
	table.sort(inspects, function(a, b)
		return a > b
	end)
	return inspects[1] * inspects[2]
end

--- @description Calculate monkey business after 10000 rounds without worry reduction
--- @param input string the puzzle input
--- @return number the monkey business level
function M.part2(input)
	local monkeys = parse_monkeys(input)
	local mod = 1
	for _, m in ipairs(monkeys) do
		mod = mod * m.test
	end
	for round = 1, 10000 do
		for _, monkey in ipairs(monkeys) do
			for _, item in ipairs(monkey.items) do
				monkey.inspected = monkey.inspected + 1
				local worry = monkey.op(item) % mod
				local target = (worry % monkey.test == 0) and monkey.true_monkey or monkey.false_monkey
				table.insert(monkeys[target + 1].items, worry)
			end
			monkey.items = {}
		end
	end
	local inspects = {}
	for _, m in ipairs(monkeys) do
		table.insert(inspects, m.inspected)
	end
	table.sort(inspects, function(a, b)
		return a > b
	end)
	return inspects[1] * inspects[2]
end

return M
