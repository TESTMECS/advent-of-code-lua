--- @title: --- Day 6: Custom Customs ---
--- @description Read the input file line by line. Parse the line into instructions. Update the grid based on the instructions. Return the number of lit lights
local M = {}
local util = require("util")

--- @function: Parse an instruction line into a command, x1, y1, x2, y2
--- @param line string The instruction line, e.g. "turn on 0,0 through 999,999".
--- @return string|nil cmd The command: "turn on", "turn off", "toggle", or nil if invalid.
--- @return number|nil x1 The starting x coordinate.
--- @return number|nil y1 The starting y coordinate.
--- @return number|nil x2 The ending x coordinate.
--- @return number|nil y2 The ending y coordinate.
local function parse_instruction(line)
	local cmd, x1, y1, x2, y2
	if line:find("turn on") then
		x1, y1, x2, y2 = line:match("turn on (%d+),(%d+) through (%d+),(%d+)")
		cmd = "turn on"
	elseif line:find("turn off") then
		x1, y1, x2, y2 = line:match("turn off (%d+),(%d+) through (%d+),(%d+)")
		cmd = "turn off"
	elseif line:find("toggle") then
		x1, y1, x2, y2 = line:match("toggle (%d+),(%d+) through (%d+),(%d+)")
		cmd = "toggle"
	end
	if not x1 then
		return nil
	end
	return cmd, tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
end

--- @description Counts number of lights that are lit.
--- @param input string The input file.
--- @return number The number of lit lights.
function M.part1(input)
	-- Populate grid with initial state
	local grid = {}
	for i = 0, 999 do
		grid[i] = {}
		for j = 0, 999 do
			grid[i][j] = false
		end
	end

	-- Read instructions and update grid
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local cmd, x1, y1, x2, y2 = parse_instruction(line)
		if cmd then
			for x = x1, x2 do
				for y = y1, y2 do
					if cmd == "turn on" then
						grid[x][y] = true
					elseif cmd == "turn off" then
						grid[x][y] = false
					elseif cmd == "toggle" then
						grid[x][y] = not grid[x][y]
					end
				end
			end
		end
	end

	-- Count lit lights
	local count = 0
	for i = 0, 999 do
		for j = 0, 999 do
			if grid[i][j] then
				count = count + 1
			end
		end
	end
	return count
end

--- @description Counts number of lights that are lit.
--- @param input string The input file.
--- @return number The number of lit lights.
function M.part2(input)
	-- Populate grid with initial state
	local grid = {}
	for i = 0, 999 do
		grid[i] = {}
		for j = 0, 999 do
			grid[i][j] = 0
		end
	end

	-- Parse instructions and update grid
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local cmd, x1, y1, x2, y2 = parse_instruction(line)
		if cmd then
			for x = x1, x2 do
				for y = y1, y2 do
					if cmd == "turn on" then
						grid[x][y] = grid[x][y] + 1
					elseif cmd == "turn off" then
						grid[x][y] = math.max(0, grid[x][y] - 1)
					elseif cmd == "toggle" then
						grid[x][y] = grid[x][y] + 2
					end
				end
			end
		end
	end

	-- Count lit lights
	local total = 0
	for i = 0, 999 do
		for j = 0, 999 do
			total = total + grid[i][j]
		end
	end
	return total
end

return M
