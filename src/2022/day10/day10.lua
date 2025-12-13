--- @title: Day 10: Cathode-Ray Tube ---
local M = {}

--- @description Calculate the sum of signal strengths at specific cycles
--- @param input string the puzzle input
--- @return number the sum of signal strengths
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	local X = 1
	local cycle = 0
	local sum = 0
	local function check()
		if cycle == 20 or cycle == 60 or cycle == 100 or cycle == 140 or cycle == 180 or cycle == 220 then
			sum = sum + cycle * X
		end
	end
	for _, line in ipairs(lines) do
		if line == "noop" then
			cycle = cycle + 1
			check()
		else
			local v = tonumber(line:match("addx (%-?%d+)"))
			cycle = cycle + 1
			check()
			cycle = cycle + 1
			check()
			X = X + v
		end
	end
	return sum
end

--- @description Render the CRT output
--- @param input string the puzzle input
--- @return string the CRT display
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	local X = 1
	local cycle = 0
	local crt = {}
	for i = 1, 6 do
		crt[i] = {}
		for j = 1, 40 do
			crt[i][j] = "."
		end
	end
	local row = 1
	local col = 1
	local function draw()
		if math.abs(col - 1 - X) <= 1 then
			crt[row][col] = "#"
		end
		col = col + 1
		if col > 40 then
			col = 1
			row = row + 1
		end
	end
	for _, line in ipairs(lines) do
		if line == "noop" then
			cycle = cycle + 1
			draw()
		else
			local v = tonumber(line:match("addx (%-?%d+)"))
			cycle = cycle + 1
			draw()
			cycle = cycle + 1
			draw()
			X = X + v
		end
	end
	local output = ""
	for i = 1, 6 do
		for j = 1, 40 do
			output = output .. crt[i][j]
		end
		output = output .. "\n"
	end
	return output
end

return M
