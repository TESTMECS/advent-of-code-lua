--- @title: Day 21: Monkey Math (Integer Version)
local M = {}

local function parse_input(input)
	local monkeys = {}
	for line in input:gmatch("[^\n]+") do
		local name, expr = line:match("([^:]+): (.+)")
		if expr:match("^%d+$") then
			monkeys[name] = tonumber(expr)
		else
			local left, op, right = expr:match("(%w+) ([%+%-%*/]) (%w+)")
			monkeys[name] = { left = left, op = op, right = right }
		end
	end
	return monkeys
end

-- Evaluate monkey values using integer arithmetic
local function eval_monkey(monkeys, name, memo)
	if memo[name] then
		return memo[name]
	end
	local val = monkeys[name]
	if type(val) == "number" then
		memo[name] = { value = val, depends = (name == "humn") }
		return memo[name]
	end

	local left = eval_monkey(monkeys, val.left, memo)
	local right = eval_monkey(monkeys, val.right, memo)

	local res
	if val.op == "+" then
		res = left.value + right.value
	elseif val.op == "-" then
		res = left.value - right.value
	elseif val.op == "*" then
		res = left.value * right.value
	elseif val.op == "/" then
		-- integer division
		res = left.value // right.value
	end

	memo[name] = { value = res, depends = left.depends or right.depends }
	return memo[name]
end

-- Solve for "humn" recursively using integer arithmetic
local function solve_humn(monkeys, name, target, memo)
	if name == "humn" then
		return target
	end
	local val = monkeys[name]
	local left = eval_monkey(monkeys, val.left, memo)
	local right = eval_monkey(monkeys, val.right, memo)

	if left.depends then
		if val.op == "+" then
			return solve_humn(monkeys, val.left, target - right.value, memo)
		elseif val.op == "-" then
			return solve_humn(monkeys, val.left, target + right.value, memo)
		elseif val.op == "*" then
			return solve_humn(monkeys, val.left, target // right.value, memo)
		elseif val.op == "/" then
			return solve_humn(monkeys, val.left, target * right.value, memo)
		end
	else
		if val.op == "+" then
			return solve_humn(monkeys, val.right, target - left.value, memo)
		elseif val.op == "-" then
			return solve_humn(monkeys, val.right, left.value - target, memo)
		elseif val.op == "*" then
			return solve_humn(monkeys, val.right, target // left.value, memo)
		elseif val.op == "/" then
			return solve_humn(monkeys, val.right, left.value // target, memo)
		end
	end
end

function M.part1(input)
	local monkeys = parse_input(input)
	local memo = {}
	return eval_monkey(monkeys, "root", memo).value
end

function M.part2(input)
	local monkeys = parse_input(input)
	local memo = {}
	local root = monkeys["root"]
	local left = eval_monkey(monkeys, root.left, memo)
	local right = eval_monkey(monkeys, root.right, memo)

	if left.depends then
		return solve_humn(monkeys, root.left, right.value, memo)
	else
		return solve_humn(monkeys, root.right, left.value, memo)
	end
end

return M
