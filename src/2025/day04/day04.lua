local util = require("src.util")
local M = {}

local ex = [[
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
]]

---@class Vec
---@field [1] number
---@field [2] number
---@alias Grid table<number, table<number, string>>
---
--- 3x3 Square with middle being our current position.
---@alias Directions { [1]: Vec, [2]: Vec, [3]: Vec, [4]: Vec, [5]: Vec, [6]: Vec, [7]: Vec, [8]: Vec }
---@type Directions
local DIRECTIONS = {
	{ -1, -1 },
	{ 0, -1 },
	{ 1, -1 },
	{ -1, 0 },
	{ 1, 0 },
	{ -1, 1 },
	{ 0, 1 },
	{ 1, 1 },
}
---@param grid Grid
---@param x number -- column
---@param y number -- row
---@param w number -- width (columns)
---@param h number -- height (rows)
---@return number
local function COUNT_ADJ_ROLLS(grid, x, y, w, h)
	---@type number
	local count = 0
	for _, dir in ipairs(DIRECTIONS) do
		local nx = x + dir[1] -- column
		local ny = y + dir[2] -- row
		if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
			--[[
			-- Checks these places.
			-- x x x
			-- x . x
			-- x x x
			--]]
			if grid[ny][nx] == "@" then
				count = count + 1
			end
		end
	end
	return count
end
---@param lines table<number,string>
---@return Grid, number, number
local function build_grid(lines)
	local h = #lines ---@type number: height
	local w = #lines[1] ---@type number: width
	local grid = {} ---@type Grid
	for row = 1, h do
		grid[row] = {}
		local line = lines[row]
		for col = 1, w do
			grid[row][col] = line:sub(col, col)
		end
	end
	return grid, w, h
end

---@param input string
---@return number
function M.part1(input)
	---@type table<number, string>
	local allLines = util.read_lines(input)
	-- collect lines
	local lines = {}
	for _, line in ipairs(allLines) do
		if #line > 0 then
			table.insert(lines, line)
		end
	end
	-- build grid
	local grid, width, height = build_grid(lines)
	local accessible = 0 ---@type number
	for y = 1, height do
		for x = 1, width do
			if grid[y][x] == "@" then
				local adj = COUNT_ADJ_ROLLS(grid, x, y, width, height)
				if adj < 4 then
					accessible = accessible + 1
				end
			end
		end
	end
	return accessible
end

---@param input string
---@return number
function M.part2(input)
	local allLines = util.read_lines(input)
	-- collect lines
	local lines = {}
	for _, line in ipairs(allLines) do
		if #line > 0 then
			table.insert(lines, line)
		end
	end
	-- build grid
	local grid, width, height = build_grid(lines)
	local total_removed = 0
	while true do
		local to_remove = {}
		-- scan the whole grid for accessible rolls
		for y = 1, height do
			for x = 1, width do
				if grid[y][x] == "@" then
					local adj = COUNT_ADJ_ROLLS(grid, x, y, width, height)
					if adj < 4 then
						table.insert(to_remove, { x, y })
					end
				end
			end
		end
		-- stop when nothing can be removed
		if #to_remove == 0 then
			break
		end
		-- remove all marked rolls simultaneously
		for _, pos in ipairs(to_remove) do
			local px, py = pos[1], pos[2]
			grid[py][px] = "."
			total_removed = total_removed + 1
		end
	end
	return total_removed
end

return M
