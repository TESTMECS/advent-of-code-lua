--- @title: Day 11: Seating System ---
local M = {}
local util = require("util")

--- @description: Simulate seating with adjacent rules
--- @param input string: the puzzle input
--- @return number: occupied seats
function M.part1(input)
	local grid = util.read_lines(input)
	local rows = #grid
	local cols = #grid[1]
	local directions = {
		{ -1, -1 },
		{ -1, 0 },
		{ -1, 1 },
		{ 0, -1 },
		{ 0, 1 },
		{ 1, -1 },
		{ 1, 0 },
		{ 1, 1 },
	}
	local function count_adjacent(r, c)
		local count = 0
		for _, d in ipairs(directions) do
			local nr, nc = r + d[1], c + d[2]
			if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols and grid[nr]:sub(nc, nc) == "#" then
				count = count + 1
			end
		end
		return count
	end
	while true do
		local new_grid = {}
		local changed = false
		for r = 1, rows do
			new_grid[r] = ""
			for c = 1, cols do
				local cell = grid[r]:sub(c, c)
				if cell == "." then
					new_grid[r] = new_grid[r] .. "."
				else
					local adj = count_adjacent(r, c)
					if cell == "L" and adj == 0 then
						new_grid[r] = new_grid[r] .. "#"
						changed = true
					elseif cell == "#" and adj >= 4 then
						new_grid[r] = new_grid[r] .. "L"
						changed = true
					else
						new_grid[r] = new_grid[r] .. cell
					end
				end
			end
		end
		if not changed then
			break
		end
		grid = new_grid
	end
	local count = 0
	for _, row in ipairs(grid) do
		for c = 1, cols do
			if row:sub(c, c) == "#" then
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Simulate seating with line-of-sight rules
--- @param input string: the puzzle input
--- @return number: occupied seats
function M.part2(input)
	local grid = util.read_lines(input)
	local rows = #grid
	local cols = #grid[1]
	local directions = {
		{ -1, -1 },
		{ -1, 0 },
		{ -1, 1 },
		{ 0, -1 },
		{ 0, 1 },
		{ 1, -1 },
		{ 1, 0 },
		{ 1, 1 },
	}
	local function count_visible(r, c)
		local count = 0
		for _, d in ipairs(directions) do
			local nr, nc = r, c
			repeat
				nr = nr + d[1]
				nc = nc + d[2]
				if nr < 1 or nr > rows or nc < 1 or nc > cols then
					break
				end
				local cell = grid[nr]:sub(nc, nc)
				if cell == "L" then
					break
				elseif cell == "#" then
					count = count + 1
					break
				end
			until false
		end
		return count
	end
	while true do
		local new_grid = {}
		local changed = false
		for r = 1, rows do
			new_grid[r] = ""
			for c = 1, cols do
				local cell = grid[r]:sub(c, c)
				if cell == "." then
					new_grid[r] = new_grid[r] .. "."
				else
					local vis = count_visible(r, c)
					if cell == "L" and vis == 0 then
						new_grid[r] = new_grid[r] .. "#"
						changed = true
					elseif cell == "#" and vis >= 5 then
						new_grid[r] = new_grid[r] .. "L"
						changed = true
					else
						new_grid[r] = new_grid[r] .. cell
					end
				end
			end
		end
		if not changed then
			break
		end
		grid = new_grid
	end
	local count = 0
	for _, row in ipairs(grid) do
		for c = 1, cols do
			if row:sub(c, c) == "#" then
				count = count + 1
			end
		end
	end
	return count
end

return M
