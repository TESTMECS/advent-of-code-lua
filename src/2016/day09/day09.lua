--- @title: Day 9: Explosives in Cyberspace ---
local M = {}

--- @description: Calculates the decompressed length of the input string using iterative stack-based decompression, where markers inside decompressed data are also processed.
--- @param input string: The compressed input string.
--- @return number: The length of the fully decompressed string.
function M.part2(input)
	local total_length = 0
	local stack = { { start = 1, end_ = #input, multiplier = 1 } }
	local iterations = 0
	while #stack > 0 do
		iterations = iterations + 1
		if iterations % 10000 == 0 then
			print(
				"Part 2: iterations = "
					.. iterations
					.. ", stack size = "
					.. #stack
					.. ", total_length = "
					.. total_length
			)
		end
		if iterations > 1000000 then
			print("Infinite loop detected in Part 2")
			break
		end
		local current = table.remove(stack)
		local pos = current.start
		while pos <= current.end_ and pos <= #input do
			if input:sub(pos, pos) == "(" then
				local marker_end = input:find(")", pos)
				local marker = input:sub(pos + 1, marker_end - 1)
				local A, B = marker:match("(%d+)x(%d+)")
				A, B = tonumber(A), tonumber(B)
				local data_start = marker_end + 1
				local data_end = math.min(data_start + A - 1, #input)
				table.insert(stack, { start = data_start, end_ = data_end, multiplier = current.multiplier * B })
				pos = data_end + 1
			elseif input:sub(pos, pos):match("%s") then
				pos = pos + 1
			else
				total_length = total_length + current.multiplier
				pos = pos + 1
			end
		end
	end
	return total_length
end

--- @description: Calculates the decompressed length of the input string using non-recursive decompression.
--- @param input string: The compressed input string.
--- @return number: The length of the decompressed string.
function M.part1(input)
	local length = 0
	local pos = 1
	while pos <= #input do
		if input:sub(pos, pos) == "(" then
			local marker_end = input:find(")", pos)
			local marker = input:sub(pos + 1, marker_end - 1)
			local A, B = marker:match("(%d+)x(%d+)")
			A, B = tonumber(A), tonumber(B)
			length = length + A * B
			pos = marker_end + A + 1
		elseif input:sub(pos, pos):match("%s") then
			pos = pos + 1
		else
			length = length + 1
			pos = pos + 1
		end
	end
	return length
end

return M
