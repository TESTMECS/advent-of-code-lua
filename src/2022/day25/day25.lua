--- @title: Full of Hot Air ---
local M = {}

local function from_snafu(s)
	local val = 0
	for i = 1, #s do
		local c = s:sub(i, i)
		val = val * 5
		if c == "2" then
			val = val + 2
		elseif c == "1" then
			val = val + 1
		elseif c == "0" then
			val = val + 0
		elseif c == "-" then
			val = val - 1
		elseif c == "=" then
			val = val - 2
		end
	end
	return val
end

local function to_snafu(n)
	if n == 0 then
		return "0"
	end
	local result = {}
	while n > 0 do
		local r = n % 5
		if r == 0 or r == 1 or r == 2 then
			table.insert(result, 1, tostring(r))
			n = math.floor(n / 5)
		elseif r == 3 then
			table.insert(result, 1, "=") -- -2
			n = math.floor(n / 5) + 1
		elseif r == 4 then
			table.insert(result, 1, "-") -- -1
			n = math.floor(n / 5) + 1
		end
	end
	return table.concat(result)
end

--- @description Sum the SNAFU numbers and return the sum in SNAFU
--- @param input string the puzzle input
--- @return string the sum in SNAFU
function M.part1(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		sum = sum + from_snafu(line)
	end
	return to_snafu(sum)
end

--- @description No part 2 for day 25
--- @param input string the puzzle input
--- @return number 0
function M.part2(input)
	return 0
end

return M
