--- @title: Day 8: Two-Factor Authentication ---
local M = {}

--- @description: Simulates the screen operations and counts the number of lit pixels.
--- @param input string: The multiline input string containing screen instructions.
--- @return number: The count of lit pixels.
function M.part1(input)
	local screen = {}
	for i = 1, 6 do
		screen[i] = {}
		for j = 1, 50 do
			screen[i][j] = false
		end
	end
	for line in input:gmatch("[^\n]+") do
		if line:find("rect") then
			local A, B = line:match("rect (%d+)x(%d+)")
			A, B = tonumber(A), tonumber(B)
			for i = 1, B do
				for j = 1, A do
					screen[i][j] = true
				end
			end
		elseif line:find("rotate row") then
			local A, B = line:match("rotate row y=(%d+) by (%d+)")
			A, B = tonumber(A), tonumber(B)
			local new_row = {}
			for j = 1, 50 do
				new_row[(j + B - 1) % 50 + 1] = screen[A + 1][j]
			end
			screen[A + 1] = new_row
		elseif line:find("rotate column") then
			local A, B = line:match("rotate column x=(%d+) by (%d+)")
			A, B = tonumber(A), tonumber(B)
			local new_col = {}
			for i = 1, 6 do
				new_col[(i + B - 1) % 6 + 1] = screen[i][A + 1]
			end
			for i = 1, 6 do
				screen[i][A + 1] = new_col[i]
			end
		end
	end
	local count = 0
	for i = 1, 6 do
		for j = 1, 50 do
			if screen[i][j] then
				count = count + 1
			end
		end
	end
	return count
end

--- @description Simulates the screen operations and returns the screen display as a string.
--- @param input string The multiline input string containing screen instructions.
--- @return string The screen display with # for lit pixels and . for off pixels.
function M.part2(input)
	local screen = {}
	for i = 1, 6 do
		screen[i] = {}
		for j = 1, 50 do
			screen[i][j] = false
		end
	end
	for line in input:gmatch("[^\n]+") do
		if line:find("rect") then
			local A, B = line:match("rect (%d+)x(%d+)")
			A, B = tonumber(A), tonumber(B)
			for i = 1, B do
				for j = 1, A do
					screen[i][j] = true
				end
			end
		elseif line:find("rotate row") then
			local A, B = line:match("rotate row y=(%d+) by (%d+)")
			A, B = tonumber(A), tonumber(B)
			local new_row = {}
			for j = 1, 50 do
				new_row[(j + B - 1) % 50 + 1] = screen[A + 1][j]
			end
			screen[A + 1] = new_row
		elseif line:find("rotate column") then
			local A, B = line:match("rotate column x=(%d+) by (%d+)")
			A, B = tonumber(A), tonumber(B)
			local new_col = {}
			for i = 1, 6 do
				new_col[(i + B - 1) % 6 + 1] = screen[i][A + 1]
			end
			for i = 1, 6 do
				screen[i][A + 1] = new_col[i]
			end
		end
	end
	local result = ""
	for i = 1, 6 do
		for j = 1, 50 do
			result = result .. (screen[i][j] and "#" or ".")
		end
		result = result .. "\n"
	end
	return result
end

return M
