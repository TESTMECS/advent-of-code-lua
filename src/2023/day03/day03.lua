--- @title: --- Day 3: Gear Ratios ---
local M = {}
local util = require("util")

local function is_symbol(grid, r, c)
	if r < 1 or r > #grid or c < 1 or c > #grid[1] then
		return false
	end
	local ch = grid[r]:sub(c, c)
	return not (ch:match("%d") or ch == ".")
end

--- @description: Sum numbers adjacent to symbols
--- @param input string: the puzzle input
--- @return number: the sum of part numbers
function M.part1(input)
	local grid = util.read_lines(input)
	if #grid == 0 then
		return 0
	end
	local sum = 0
	local rows = #grid
	local cols = #grid[1]
	local visited = {}
	for r = 1, rows do
		for c = 1, cols do
			if grid[r]:sub(c, c):match("%d") and not visited[r * cols + c] then
				local start = c
				while start > 1 and grid[r]:sub(start - 1, start - 1):match("%d") do
					start = start - 1
				end
				local endc = c
				while endc < cols and grid[r]:sub(endc + 1, endc + 1):match("%d") do
					endc = endc + 1
				end
				local num_str = grid[r]:sub(start, endc)
				local num = tonumber(num_str)
				for i = start, endc do
					visited[r * cols + i] = true
				end
				local adjacent = false
				for rr = r - 1, r + 1 do
					for cc = start - 1, endc + 1 do
						if is_symbol(grid, rr, cc) then
							adjacent = true
							break
						end
					end
					if adjacent then
						break
					end
				end
				if adjacent then
					sum = sum + num
				end
			end
		end
	end
	return sum
end

--- @description: Sum gear ratios (products of exactly two adjacent numbers)
--- @param input string: the puzzle input
--- @return number: the sum of gear ratios
function M.part2(input)
	local grid = util.read_lines(input)
	if #grid == 0 then
		return 0
	end
	local rows = #grid
	local cols = #grid[1]
	local numbers = {}
	for r = 1, rows do
		local c = 1
		while c <= cols do
			if grid[r]:sub(c, c):match("%d") then
				local start = c
				while c <= cols and grid[r]:sub(c, c):match("%d") do
					c = c + 1
				end
				local num_str = grid[r]:sub(start, c - 1)
				local num = tonumber(num_str)
				table.insert(numbers, { num = num, row = r, start = start, endc = c - 1 })
			else
				c = c + 1
			end
		end
	end
	local sum = 0
	for r = 1, rows do
		for c = 1, cols do
			if grid[r]:sub(c, c) == "*" then
				local adjacent_nums = {}
				for _, num_info in ipairs(numbers) do
					if math.abs(num_info.row - r) <= 1 then
						if num_info.start - 1 <= c and c <= num_info.endc + 1 then
							table.insert(adjacent_nums, num_info.num)
						end
					end
				end
				if #adjacent_nums == 2 then
					sum = sum + adjacent_nums[1] * adjacent_nums[2]
				end
			end
		end
	end
	return sum
end

return M
