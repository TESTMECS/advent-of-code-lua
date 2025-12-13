--- @title: --- Day 14: Parabolic Reflector Dish ---
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local grid = {}
	local y = 1
	for line in input:gmatch("[^\n]+") do
		grid[y] = {}
		for x = 1, #line do
			grid[y][x] = line:sub(x, x)
		end
		y = y + 1
	end
	local rows = #grid
	local cols = #grid[1]
	-- Tilt north
	for x = 1, cols do
		local pos = 1
		for y = 1, rows do
			if grid[y][x] == "#" then
				pos = y + 1
			elseif grid[y][x] == "O" then
				if y ~= pos then
					grid[pos][x] = "O"
					grid[y][x] = "."
				end
				pos = pos + 1
			end
		end
	end
	local load = 0
	for y = 1, rows do
		local count = 0
		for x = 1, cols do
			if grid[y][x] == "O" then
				count = count + 1
			end
		end
		load = load + count * (rows - y + 1)
	end
	return load
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local grid = {}
	local y = 1
	for line in input:gmatch("[^\n]+") do
		grid[y] = {}
		for x = 1, #line do
			grid[y][x] = line:sub(x, x)
		end
		y = y + 1
	end
	local rows = #grid
	local cols = #grid[1]
	local function serialize(g)
		local s = ""
		for i = 1, rows do
			for j = 1, cols do
				s = s .. g[i][j]
			end
		end
		return s
	end
	local function tilt(dir)
		if dir == "N" then
			for x = 1, cols do
				local pos = 1
				for y = 1, rows do
					if grid[y][x] == "#" then
						pos = y + 1
					elseif grid[y][x] == "O" then
						if y ~= pos then
							grid[pos][x] = "O"
							grid[y][x] = "."
						end
						pos = pos + 1
					end
				end
			end
		elseif dir == "S" then
			for x = 1, cols do
				local pos = rows
				for y = rows, 1, -1 do
					if grid[y][x] == "#" then
						pos = y - 1
					elseif grid[y][x] == "O" then
						if y ~= pos then
							grid[pos][x] = "O"
							grid[y][x] = "."
						end
						pos = pos - 1
					end
				end
			end
		elseif dir == "W" then
			for y = 1, rows do
				local pos = 1
				for x = 1, cols do
					if grid[y][x] == "#" then
						pos = x + 1
					elseif grid[y][x] == "O" then
						if x ~= pos then
							grid[y][pos] = "O"
							grid[y][x] = "."
						end
						pos = pos + 1
					end
				end
			end
		elseif dir == "E" then
			for y = 1, rows do
				local pos = cols
				for x = cols, 1, -1 do
					if grid[y][x] == "#" then
						pos = x - 1
					elseif grid[y][x] == "O" then
						if x ~= pos then
							grid[y][pos] = "O"
							grid[y][x] = "."
						end
						pos = pos - 1
					end
				end
			end
		end
	end
	local seen = {}
	local cycle_start
	local i = 0
	while true do
		local s = serialize(grid)
		if seen[s] then
			cycle_start = seen[s]
			break
		end
		seen[s] = i
		tilt("N")
		tilt("W")
		tilt("S")
		tilt("E")
		i = i + 1
	end
	local cycle_len = i - cycle_start
	local remaining = (1000000000 - cycle_start) % cycle_len
	for _ = 1, remaining do
		tilt("N")
		tilt("W")
		tilt("S")
		tilt("E")
	end
	local load = 0
	for y = 1, rows do
		local count = 0
		for x = 1, cols do
			if grid[y][x] == "O" then
				count = count + 1
			end
		end
		load = load + count * (rows - y + 1)
	end
	return load
end

return M
