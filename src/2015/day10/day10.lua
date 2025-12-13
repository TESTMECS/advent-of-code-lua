--- @title: --- Day 10: Elves Look, Elves Say ---
local M = {}

--- @function: RLE for look and say
--- @param s string: input string with no newlines
--- @return string: RLE encoded string
local function look_and_say(s)
	local result = {}
	local i = 1
	while i <= #s do
		local digit = s:sub(i, i)
		local count = 1
		i = i + 1 -- skip the digit
		while i <= #s and s:sub(i, i) == digit do -- while the digit is repeated
			count = count + 1
			i = i + 1
		end
		table.insert(result, tostring(count) .. digit)
	end
	return table.concat(result) -- output as a string of digits
end

--- @description Day 10 part 1 1:40
--- @param input string: input string with no newlines
--- @return integer: length of the RLE encoded string
function M.part1(input)
	local s = input:gsub("\n", "")
	for _ = 1, 40 do
		s = look_and_say(s)
	end
	return #s
end

--- @description Day 10 part 2 1:50
--- @param input string: input string with no newlines
--- @return integer: length of the RLE encoded string
function M.part2(input)
	local s = input:gsub("\n", "")
	for _ = 1, 50 do
		s = look_and_say(s)
	end
	return #s
end

return M
