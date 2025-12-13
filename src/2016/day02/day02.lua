--- @title: Day 2: Bathroom Security ---
local M = {}

--- @description The approach is to parse the input and move the cursor according to the instructions.
--- @param input string ULDR
--- @return number|nil bathroom code
function M.part1(input)
	local row, col = 1, 1 -- start at 5, row 1 col 1 (0-based)
	local code = ""

	for line in input:gmatch("[^\n]+") do
		for i = 1, #line do
			local move = line:sub(i, i)
			if move == "U" then
				row = math.max(0, row - 1)
			elseif move == "D" then
				row = math.min(2, row + 1)
			elseif move == "L" then
				col = math.max(0, col - 1)
			elseif move == "R" then
				col = math.min(2, col + 1)
			end
		end
		local button = row * 3 + col + 1
		code = code .. tostring(button)
	end
	return tonumber(code)
end

--- @description The approach is the same as part1, but the keypad is different.
--- @param input string ULDR
--- @return number|nil bathroom code
function M.part2(input)
	local row, col = 0, -2 -- start at 5
	local code = ""

	for line in input:gmatch("[^\n]+") do
		for i = 1, #line do
			local move = line:sub(i, i)
			local new_row, new_col = row, col
			if move == "U" then
				new_row = row - 1
			elseif move == "D" then
				new_row = row + 1
			elseif move == "L" then
				new_col = col - 1
			elseif move == "R" then
				new_col = col + 1
			end
			if math.abs(new_row) + math.abs(new_col) <= 2 then
				row, col = new_row, new_col
			end
		end
		local button
		if row == -2 and col == 0 then
			button = "1"
		elseif row == -1 then
			if col == -1 then
				button = "2"
			elseif col == 0 then
				button = "3"
			elseif col == 1 then
				button = "4"
			end
		elseif row == 0 then
			if col == -2 then
				button = "5"
			elseif col == -1 then
				button = "6"
			elseif col == 0 then
				button = "7"
			elseif col == 1 then
				button = "8"
			elseif col == 2 then
				button = "9"
			end
		elseif row == 1 then
			if col == -1 then
				button = "A"
			elseif col == 0 then
				button = "B"
			elseif col == 1 then
				button = "C"
			end
		elseif row == 2 and col == 0 then
			button = "D"
		end
		code = code .. button
	end
	return code
end

return M
