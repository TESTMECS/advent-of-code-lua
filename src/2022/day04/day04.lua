--- @title: --- Day 4: Camp Cleanup ---
local M = {}

--- @description: Count pairs where one range fully contains the other
--- @param input string the puzzle input
--- @return number: the count
function M.part1(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local a1, a2, b1, b2 = line:match("(%d+)-(%d+),(%d+)-(%d+)")
		a1, a2, b1, b2 = tonumber(a1), tonumber(a2), tonumber(b1), tonumber(b2)
		if (a1 <= b1 and a2 >= b2) or (b1 <= a1 and b2 >= a2) then
			count = count + 1
		end
	end
	return count
end

--- @description: Count pairs where ranges overlap
--- @param input string the puzzle input
--- @return number: the count
function M.part2(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local a1, a2, b1, b2 = line:match("(%d+)-(%d+),(%d+)-(%d+)")
		a1, a2, b1, b2 = tonumber(a1), tonumber(a2), tonumber(b1), tonumber(b2)
		if not (a2 < b1 or b2 < a1) then
			count = count + 1
		end
	end
	return count
end

return M
