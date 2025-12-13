--- @title: Day 1: Not Quite Lisp
--- @description: Lua uses input:sub(i, i) to get the ith character of the input string. This allows us to follow the instructions to the ___ floor and check if that floor == -1 to see if Santa has entered the basement
local M = {}

--- @description: Return the position of the first character that causes Santa to enter the basement
--- @param input string: of alternating "(" and ")"
--- @return number|nil: the position of the first character that causes Santa to enter the basement
function M.part1(input)
	local floor = 0
	for i = 1, #input do
		local char = input:sub(i, i)
		if char == "(" then
			floor = floor + 1
		elseif char == ")" then
			floor = floor - 1
		end
	end
	return floor
end

--- @description: Return the position of the first character that causes Santa to first enter the basement
--- @param input string: of alternatiing "(" and ")"
--- @return number|nil: the position of the first character that causes Santa to first enter the basement, nil if never reaches basement
function M.part2(input)
	local floor = 0
	for i = 1, #input do
		local char = input:sub(i, i)
		if char == "(" then
			floor = floor + 1
		elseif char == ")" then
			floor = floor - 1
		end
		if floor == -1 then
			return i
		end
	end
	return nil -- if never reaches basement
end

return M
