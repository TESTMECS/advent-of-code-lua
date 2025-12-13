--- @title Day 6: Signals and Noise ---
local M = {}

--- @description: Finds the most frequent character in each column of the input lines to reconstruct the error-corrected message.
--- @param input string: The multiline input string containing the repeated messages.
--- @return string: The reconstructed message using the most common character per column.
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local len = #lines[1]
	local counts = {}
	for i = 1, len do
		counts[i] = {}
	end
	for _, line in ipairs(lines) do
		for i = 1, len do
			local c = line:sub(i, i)
			if c ~= "" then
				counts[i][c] = (counts[i][c] or 0) + 1
			end
		end
	end
	local result = ""
	for i = 1, len do
		local max_count = 0
		local max_char = ""
		for c, count in pairs(counts[i]) do
			if count > max_count or (count == max_count and c < max_char) then
				max_count = count
				max_char = c
			end
		end
		result = result .. max_char
	end
	return result
end

--- @description Finds the least frequent character in each column of the input lines to reconstruct the original message.
--- @param input string The multiline input string containing the repeated messages.
--- @return string The reconstructed original message using the least common character per column.
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local len = #lines[1]
	local counts = {}
	for i = 1, len do
		counts[i] = {}
	end
	for _, line in ipairs(lines) do
		for i = 1, len do
			local c = line:sub(i, i)
			if c ~= "" then
				counts[i][c] = (counts[i][c] or 0) + 1
			end
		end
	end
	local result = ""
	for i = 1, len do
		local min_count = math.huge
		local min_char = ""
		for c, count in pairs(counts[i]) do
			if count < min_count or (count == min_count and c < min_char) then
				min_count = count
				min_char = c
			end
		end
		result = result .. min_char
	end
	return result
end

return M
