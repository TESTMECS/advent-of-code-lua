--- @title: Day 3: No Matter How You Slice It ---
local M = {}
local util = require("util")

--- @description: Counts the number of square inches within two or more claims
--- @param input string: the puzzle input
--- @return number: the count of overlapping square inches
function M.part1(input)
	local lines = util.read_lines(input)
	local claims = {}
	for _, line in ipairs(lines) do
		local id, x, y, w, h = line:match("#(%d+) @ (%d+),(%d+): (%d+)x(%d+)")
		claims[#claims + 1] = {
			id = tonumber(id),
			x = tonumber(x),
			y = tonumber(y),
			w = tonumber(w),
			h = tonumber(h),
		}
	end
	local grid = {}
	for _, claim in ipairs(claims) do
		for i = claim.x, claim.x + claim.w - 1 do
			for j = claim.y, claim.y + claim.h - 1 do
				grid[i] = grid[i] or {}
				grid[i][j] = (grid[i][j] or 0) + 1
			end
		end
	end
	local overlap = 0
	for _, row in pairs(grid) do
		for _, count in pairs(row) do
			if count > 1 then
				overlap = overlap + 1
			end
		end
	end
	return overlap
end

--- @description: Finds the ID of the claim that doesn't overlap with any other
--- @param input string: the puzzle input
--- @return number: the ID of the non-overlapping claim
function M.part2(input)
	local lines = util.read_lines(input)
	local claims = {}
	for _, line in ipairs(lines) do
		local id, x, y, w, h = line:match("#(%d+) @ (%d+),(%d+): (%d+)x(%d+)")
		claims[#claims + 1] = {
			id = tonumber(id),
			x = tonumber(x),
			y = tonumber(y),
			w = tonumber(w),
			h = tonumber(h),
		}
	end
	local grid = {}
	for _, claim in ipairs(claims) do
		for i = claim.x, claim.x + claim.w - 1 do
			for j = claim.y, claim.y + claim.h - 1 do
				grid[i] = grid[i] or {}
				grid[i][j] = (grid[i][j] or 0) + 1
			end
		end
	end
	for _, claim in ipairs(claims) do
		local is_unique = true
		for i = claim.x, claim.x + claim.w - 1 do
			for j = claim.y, claim.y + claim.h - 1 do
				if grid[i][j] ~= 1 then
					is_unique = false
					break
				end
			end
			if not is_unique then
				break
			end
		end
		if is_unique then
			return claim.id
		end
	end
	return 0
end

return M
