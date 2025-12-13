--- @title: Day 9: Stream Processing ---
local M = {}

--- @description: Calculate the total score of all groups in the stream
--- @param input string: the stream of characters
--- @return number: the total score
function M.part1(input)
	local score = 0
	local depth = 0
	local in_garbage = false
	local ignore_next = false

	for i = 1, #input do
		local c = input:sub(i, i)
		if ignore_next then
			ignore_next = false
		elseif in_garbage then
			if c == ">" then
				in_garbage = false
			elseif c == "!" then
				ignore_next = true
			end
		else
			if c == "{" then
				depth = depth + 1
			elseif c == "}" then
				score = score + depth
				depth = depth - 1
			elseif c == "<" then
				in_garbage = true
			end
		end
	end

	return score
end

--- @description: Count the number of characters within garbage
--- @param input string: the stream of characters
--- @return number: the count of garbage characters
function M.part2(input)
	local garbage_count = 0
	local in_garbage = false
	local ignore_next = false

	for i = 1, #input do
		local c = input:sub(i, i)
		if ignore_next then
			ignore_next = false
		elseif in_garbage then
			if c == ">" then
				in_garbage = false
			elseif c == "!" then
				ignore_next = true
			else
				garbage_count = garbage_count + 1
			end
		else
			if c == "<" then
				in_garbage = true
			end
		end
	end

	return garbage_count
end

return M
