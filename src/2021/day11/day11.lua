--- @title: Day 11: Title ---
local M = {}

--- @description: Simulate 100 steps and count the total flashes
--- @param input string: the puzzle input
--- @return number: the total number of flashes
function M.part1(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		table.insert(grid, row)
	end
	local rows = #grid
	local cols = #grid[1]
	local flashes = 0
	for step = 1, 100 do
		-- increase all
		for i = 1, rows do
			for j = 1, cols do
				grid[i][j] = grid[i][j] + 1
			end
		end
		-- flash
		local flashed = {}
		for i = 1, rows do
			flashed[i] = {}
			for j = 1, cols do
				flashed[i][j] = false
			end
		end
		local function flash(i, j)
			if i < 1 or i > rows or j < 1 or j > cols or flashed[i][j] then
				return
			end
			if grid[i][j] > 9 then
				flashed[i][j] = true
				flashes = flashes + 1
				for di = -1, 1 do
					for dj = -1, 1 do
						if di ~= 0 or dj ~= 0 then
							local ni = i + di
							local nj = j + dj
							if ni >= 1 and ni <= rows and nj >= 1 and nj <= cols then
								grid[ni][nj] = grid[ni][nj] + 1
							end
						end
					end
				end
				-- recurse
				for di = -1, 1 do
					for dj = -1, 1 do
						if di ~= 0 or dj ~= 0 then
							flash(i + di, j + dj)
						end
					end
				end
			end
		end
		for i = 1, rows do
			for j = 1, cols do
				if grid[i][j] > 9 then
					flash(i, j)
				end
			end
		end
		-- reset flashed
		for i = 1, rows do
			for j = 1, cols do
				if flashed[i][j] then
					grid[i][j] = 0
				end
			end
		end
	end
	return flashes
end

--- @description: Find the first step where all octopuses flash simultaneously
--- @param input string: the puzzle input
--- @return number: the step number
function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for d in line:gmatch(".") do
			table.insert(row, tonumber(d))
		end
		table.insert(grid, row)
	end
	local rows = #grid
	local cols = #grid[1]
	local step = 0
	while true do
		step = step + 1
		-- increase all
		for i = 1, rows do
			for j = 1, cols do
				grid[i][j] = grid[i][j] + 1
			end
		end
		-- flash
		local flashed = {}
		for i = 1, rows do
			flashed[i] = {}
			for j = 1, cols do
				flashed[i][j] = false
			end
		end
		local flashes_this_step = 0
		local function flash(i, j)
			if i < 1 or i > rows or j < 1 or j > cols or flashed[i][j] then
				return
			end
			if grid[i][j] > 9 then
				flashed[i][j] = true
				flashes_this_step = flashes_this_step + 1
				for di = -1, 1 do
					for dj = -1, 1 do
						if di ~= 0 or dj ~= 0 then
							local ni = i + di
							local nj = j + dj
							if ni >= 1 and ni <= rows and nj >= 1 and nj <= cols then
								grid[ni][nj] = grid[ni][nj] + 1
							end
						end
					end
				end
				-- recurse
				for di = -1, 1 do
					for dj = -1, 1 do
						if di ~= 0 or dj ~= 0 then
							flash(i + di, j + dj)
						end
					end
				end
			end
		end
		for i = 1, rows do
			for j = 1, cols do
				if grid[i][j] > 9 then
					flash(i, j)
				end
			end
		end
		-- reset flashed
		for i = 1, rows do
			for j = 1, cols do
				if flashed[i][j] then
					grid[i][j] = 0
				end
			end
		end
		if flashes_this_step == rows * cols then
			return step
		end
	end
end

return M
