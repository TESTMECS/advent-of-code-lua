--- @title: --- Day 8: Treetop Tree House ---
local M = {}

local function parse_grid(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, tonumber(c))
		end
		table.insert(grid, row)
	end
	return grid
end

--- @description: Count trees visible from outside
--- @param input string the puzzle input
--- @return number: the count
function M.part1(input)
	local grid = parse_grid(input)
	local rows = #grid
	local cols = #grid[1]
	local visible = {}
	for i = 1, rows do
		visible[i] = {}
		for j = 1, cols do
			visible[i][j] = false
		end
	end
	-- edges
	for i = 1, rows do
		visible[i][1] = true
		visible[i][cols] = true
	end
	for j = 1, cols do
		visible[1][j] = true
		visible[rows][j] = true
	end
	-- inner rows
	for i = 2, rows - 1 do
		-- left to right
		local max_h = grid[i][1]
		for j = 2, cols - 1 do
			if grid[i][j] > max_h then
				visible[i][j] = true
				max_h = grid[i][j]
			end
		end
		-- right to left
		max_h = grid[i][cols]
		for j = cols - 1, 2, -1 do
			if grid[i][j] > max_h then
				visible[i][j] = true
				max_h = grid[i][j]
			end
		end
	end
	-- inner cols
	for j = 2, cols - 1 do
		-- top to bottom
		local max_h = grid[1][j]
		for i = 2, rows - 1 do
			if grid[i][j] > max_h then
				visible[i][j] = true
				max_h = grid[i][j]
			end
		end
		-- bottom to top
		max_h = grid[rows][j]
		for i = rows - 1, 2, -1 do
			if grid[i][j] > max_h then
				visible[i][j] = true
				max_h = grid[i][j]
			end
		end
	end
	local count = 0
	for i = 1, rows do
		for j = 1, cols do
			if visible[i][j] then
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Find the highest scenic score
--- @param input string the puzzle input
--- @return number: the max score
function M.part2(input)
	local grid = parse_grid(input)
	local rows = #grid
	local cols = #grid[1]
	local max_score = 0
	for i = 1, rows do
		for j = 1, cols do
			local score = 1
			-- up
			local dist = 0
			for k = i - 1, 1, -1 do
				dist = dist + 1
				if grid[k][j] >= grid[i][j] then
					break
				end
			end
			score = score * dist
			-- down
			dist = 0
			for k = i + 1, rows do
				dist = dist + 1
				if grid[k][j] >= grid[i][j] then
					break
				end
			end
			score = score * dist
			-- left
			dist = 0
			for k = j - 1, 1, -1 do
				dist = dist + 1
				if grid[i][k] >= grid[i][j] then
					break
				end
			end
			score = score * dist
			-- right
			dist = 0
			for k = j + 1, cols do
				dist = dist + 1
				if grid[i][k] >= grid[i][j] then
					break
				end
			end
			score = score * dist
			if score > max_score then
				max_score = score
			end
		end
	end
	return max_score
end

return M
