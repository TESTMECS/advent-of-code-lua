--- @title: Day 23: Coprocessor Conflagration ---
local M = {}

--- @function: Count mul invocations
--- @param input string: the program
--- @return number: mul count
local function simulate(input, a_init)
	local regs = { a = a_init or 0, b = 0, c = 0, d = 0, e = 0, f = 0, g = 0, h = 0 }
	local instructions = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(instructions, line)
	end
	local pc = 1
	local mul_count = 0
	while pc >= 1 and pc <= #instructions do
		local line = instructions[pc]
		local parts = {}
		for word in line:gmatch("%S+") do
			table.insert(parts, word)
		end
		local op = parts[1]
		local x = parts[2]
		local y = parts[3]
		local function get_val(s)
			if s:match("^%-?%d+$") then
				return tonumber(s)
			else
				return regs[s] or 0
			end
		end
		if op == "set" then
			regs[x] = get_val(y)
		elseif op == "sub" then
			regs[x] = (regs[x] or 0) - get_val(y)
		elseif op == "mul" then
			regs[x] = (regs[x] or 0) * get_val(y)
			mul_count = mul_count + 1
		elseif op == "jnz" then
			if get_val(x) ~= 0 then
				pc = pc + get_val(y) - 1
			end
		end
		pc = pc + 1
	end
	return mul_count, regs.h
end

--- @description: Count mul invocations
--- @param input string: the program
--- @return number: mul count
function M.part1(input)
	local mul_count = simulate(input, 0)
	return mul_count
end

--- @function: Run with a=0 and get h
--- @param input string: the program
--- @return number: value of h
function simulate_opt(input, a_init)
	local regs = { a = a_init or 0, b = 0, c = 0, d = 0, e = 0, f = 0, g = 0, h = 0 }
	regs.b = 99
	regs.c = regs.b
	if regs.a ~= 0 then
		regs.b = regs.b * 100 + 100000
		regs.c = regs.b + 17000
	end
	while regs.b <= regs.c do
		local is_composite = false
		local sqrt_b = math.floor(math.sqrt(regs.b))
		for d = 2, sqrt_b do
			if regs.b % d == 0 then
				is_composite = true
				break
			end
		end
		if is_composite then
			regs.h = regs.h + 1
		end
		regs.b = regs.b + 17
	end
	return regs.h
end

--- @description Run with a=1 and get h
--- @param input string the program
--- @return number value of h
function M.part2(input)
	local h = simulate_opt(input, 1)
	return h
end

return M
