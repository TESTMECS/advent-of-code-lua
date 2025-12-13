--- @title: --- Day 19: Linen Layout ---
local M = {}

--- @description Count possible designs
--- @param input string the puzzle input
--- @return number the count
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local patterns = {}
	for p in lines[1]:gmatch("(%w+)") do
		table.insert(patterns, p)
	end
	local designs = {}
	for i = 3, #lines do
		table.insert(designs, lines[i])
	end
	local function can_make(design, memo)
		if memo[design] ~= nil then
			return memo[design]
		end
		if design == "" then
			return true
		end
		for _, p in ipairs(patterns) do
			if design:sub(1, #p) == p then
				if can_make(design:sub(#p + 1), memo) then
					memo[design] = true
					return true
				end
			end
		end
		memo[design] = false
		return false
	end
	local count = 0
	for _, d in ipairs(designs) do
		if can_make(d, {}) then
			count = count + 1
		end
	end
	return count
end

--- @description Sum the number of ways for each design
--- @param input string the puzzle input
--- @return number the sum
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local patterns = {}
	for p in lines[1]:gmatch("(%w+)") do
		table.insert(patterns, p)
	end
	local designs = {}
	for i = 3, #lines do
		table.insert(designs, lines[i])
	end
	local function ways(design, memo)
		if memo[design] ~= nil then
			return memo[design]
		end
		if design == "" then
			return 1
		end
		local total = 0
		for _, p in ipairs(patterns) do
			if design:sub(1, #p) == p then
				total = total + ways(design:sub(#p + 1), memo)
			end
		end
		memo[design] = total
		return total
	end
	local sum = 0
	for _, d in ipairs(designs) do
		sum = sum + ways(d, {})
	end
	return sum
end

return M
