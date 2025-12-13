--- @title: --- Day 11: Cosmic Expansion ---
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
	local empty_rows = {}
	for i = 1, #grid do
		local empty = true
		for j = 1, #grid[1] do
			if grid[i][j] == "#" then
				empty = false
				break
			end
		end
		if empty then
			table.insert(empty_rows, i)
		end
	end
	local empty_cols = {}
	for j = 1, #grid[1] do
		local empty = true
		for i = 1, #grid do
			if grid[i][j] == "#" then
				empty = false
				break
			end
		end
		if empty then
			table.insert(empty_cols, j)
		end
	end
	local galaxies = {}
	for i = 1, #grid do
		for j = 1, #grid[1] do
			if grid[i][j] == "#" then
				local extra_y = 0
				for _, r in ipairs(empty_rows) do
					if r < i then
						extra_y = extra_y + 1
					end
				end
				local extra_x = 0
				for _, c in ipairs(empty_cols) do
					if c < j then
						extra_x = extra_x + 1
					end
				end
				table.insert(galaxies, { j + extra_x, i + extra_y })
			end
		end
	end
	local sum = 0
	for i = 1, #galaxies do
		for j = i + 1, #galaxies do
			local dx = math.abs(galaxies[i][1] - galaxies[j][1])
			local dy = math.abs(galaxies[i][2] - galaxies[j][2])
			sum = sum + dx + dy
		end
	end
	return sum
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
	local empty_rows = {}
	for i = 1, #grid do
		local empty = true
		for j = 1, #grid[1] do
			if grid[i][j] == "#" then
				empty = false
				break
			end
		end
		if empty then
			table.insert(empty_rows, i)
		end
	end
	local empty_cols = {}
	for j = 1, #grid[1] do
		local empty = true
		for i = 1, #grid do
			if grid[i][j] == "#" then
				empty = false
				break
			end
		end
		if empty then
			table.insert(empty_cols, j)
		end
	end
	local galaxies = {}
	for i = 1, #grid do
		for j = 1, #grid[1] do
			if grid[i][j] == "#" then
				local extra_y = 0
				for _, r in ipairs(empty_rows) do
					if r < i then
						extra_y = extra_y + 999999
					end
				end
				local extra_x = 0
				for _, c in ipairs(empty_cols) do
					if c < j then
						extra_x = extra_x + 999999
					end
				end
				table.insert(galaxies, { j + extra_x, i + extra_y })
			end
		end
	end
	local sum = 0
	for i = 1, #galaxies do
		for j = i + 1, #galaxies do
			local dx = math.abs(galaxies[i][1] - galaxies[j][1])
			local dy = math.abs(galaxies[i][2] - galaxies[j][2])
			sum = sum + dx + dy
		end
	end
	return sum
end

return M
