--- @title: Day 15: Dueling Generators ---
local M = {}

--- @description: Count matches for 40 million pairs
--- @param input string: the input with starts
--- @return number: the count
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	local a = tonumber(lines[1]:match("(%d+)"))
	local b = tonumber(lines[2]:match("(%d+)"))
	local count = 0
	for _ = 1, 40000000 do
		a = (a * 16807) % 2147483647
		b = (b * 48271) % 2147483647
		if (a & 0xFFFF) == (b & 0xFFFF) then
			count = count + 1
		end
	end
	return count
end

--- @description: Count matches for 5 million pairs with criteria
--- @param input string: the input with starts
--- @return number: the count
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	local a = tonumber(lines[1]:match("(%d+)"))
	local b = tonumber(lines[2]:match("(%d+)"))
	local count = 0
	for i = 1, 5000000 do
		repeat
			a = (a * 16807) % 2147483647
		until a % 4 == 0
		repeat
			b = (b * 48271) % 2147483647
		until b % 8 == 0
		if (a & 0xFFFF) == (b & 0xFFFF) then
			count = count + 1
		end
	end
	return count
end

return M
