--- @title: Day 05: Alchemical Reduction ---
local M = {}

--- @description: Fully reacts the polymer and returns the length of the resulting string
--- @param input string: the puzzle input (the polymer)
--- @return number: the length after reactions
function M.part1(input)
	local polymer = input:gsub("%s+", "")
	local stack = {}
	for i = 1, #polymer do
		local char = polymer:sub(i, i)
		if #stack > 0 and string.lower(char) == string.lower(stack[#stack]) and char ~= stack[#stack] then
			table.remove(stack)
		else
			table.insert(stack, char)
		end
	end
	return #stack
end

--- @description: Removes one type of unit (both cases) before reacting, finds the minimum length
--- @param input string: the puzzle input (the polymer)
--- @return number: the minimum length after removing one type and reacting
function M.part2(input)
	local polymer = input:gsub("%s+", "")
	local min_length = #polymer
	for c = string.byte("a"), string.byte("z") do
		local char = string.char(c)
		local upper = string.upper(char)
		local filtered = polymer:gsub("[" .. char .. upper .. "]", "")
		local length = M.part1(filtered)
		if length < min_length then
			min_length = length
		end
	end
	return min_length
end

return M
