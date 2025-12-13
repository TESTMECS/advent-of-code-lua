--- @title: --- Day 24: Arithmetic Logic Unit ---
local M = {}

local call_count = 0
local max_calls = 1000000

--- @description Find the largest model number accepted by the ALU
--- @param input string the puzzle input
--- @return number the largest valid model number
function M.part1(input)
	call_count = 0
	local start_time = os.clock()
	local params = M.parse_params(input)
	local result = M.find_model(0, 0, true, params, {})
	local elapsed = os.clock() - start_time
	print(string.format("Part1: calls %d, elapsed %.2fs", call_count, elapsed))
	return result and tonumber(result) or 0
end

--- @description Find the smallest model number accepted by the ALU
--- @param input string the puzzle input
--- @return number the smallest valid model number
function M.part2(input)
	call_count = 0
	local start_time = os.clock()
	local params = M.parse_params(input)
	local result = M.find_model(0, 0, false, params, {})
	local elapsed = os.clock() - start_time
	print(string.format("Part2: calls %d, elapsed %.2fs", call_count, elapsed))
	return result and tonumber(result) or 0
end

--- @param input string the program
--- @return table list of {a, b, c} for each block
function M.parse_params(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local params = {}
	local i = 1
	while i <= #lines do
		if lines[i] and lines[i]:find("inp w") then
			local block = {}
			i = i + 1
			-- skip mul x 0, add x z, mod x 26
			i = i + 3
			local _, _, a = lines[i]:find("div z (%d+)")
			block.a = tonumber(a)
			i = i + 1
			local _, _, b = lines[i]:find("add x (-?%d+)")
			block.b = tonumber(b)
			i = i + 1
			-- skip eql x w, eql x 0, mul y 0, add y 25, mul y x, add y 1, mul z y, mul y 0, add y w
			i = i + 9
			local _, _, c = lines[i]:find("add y (%d+)")
			block.c = tonumber(c)
			i = i + 1
			-- skip mul y x, add z y
			i = i + 2
			table.insert(params, block)
		else
			i = i + 1
		end
	end
	return params
end

--- @param pos number current position (0-13)
--- @param z number current z value
--- @param is_max boolean true for largest, false for smallest
--- @param params table the parameters
--- @param cache table for memoization
--- @return string|nil the model number string or nil
function M.find_model(pos, z, is_max, params, cache)
	if pos == 14 then
		return z == 0 and "" or nil
	end

	local key = pos .. ":" .. z
	if cache[key] ~= nil then
		-- We have solved this subproblem before.
		-- A false value indicates a dead end.
		return cache[key] and cache[key] or nil
	end

	local p = params[pos + 1]
	local digits = is_max and { 9, 8, 7, 6, 5, 4, 3, 2, 1 } or { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

	if p.a == 26 then
		-- This is a POP block. The required digit is fixed.
		local required_digit = (z % 26) + p.b
		if required_digit >= 1 and required_digit <= 9 then
			local new_z = math.floor(z / 26)
			local res = M.find_model(pos + 1, new_z, is_max, params, cache)
			if res then
				local solution = tostring(required_digit) .. res
				cache[key] = solution
				return solution
			end
		end
	else
		for _, digit in ipairs(digits) do
			local new_z = z * 26 + digit + p.c
			local res = M.find_model(pos + 1, new_z, is_max, params, cache)
			if res then
				local solution = tostring(digit) .. res
				cache[key] = solution
				return solution
			end
		end
	end

	-- No solution found from this (pos, z) state. Cache this failure.
	cache[key] = false
	return nil
end

return M
