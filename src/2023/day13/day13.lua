--- @title: --- Day 13: Point of Incidence ---
local M = {}
local function parse_grids(input)
	local grids = {}
	-- Split on blank lines
	for block in input:gmatch("([^\n]+[^\n]*)") do
		-- We'll collect full grids manually
	end

	local current = {}
	for line in (input .. "\n"):gmatch("([^\n]*)\n") do
		if line == "" then
			if #current > 0 then
				table.insert(grids, current)
				current = {}
			end
		else
			table.insert(current, line)
		end
	end
	if #current > 0 then
		table.insert(grids, current)
	end
	return grids
end

local function find_reflection(grid, allow_smudge)
	local rows = #grid
	local cols = #grid[1]

	-- check horizontal reflection lines
	for i = 1, rows - 1 do
		local diff_count = 0
		local dist = math.min(i, rows - i)
		for d = 1, dist do
			for c = 1, cols do
				if grid[i - d + 1]:sub(c, c) ~= grid[i + d]:sub(c, c) then
					diff_count = diff_count + 1
					if diff_count > (allow_smudge and 1 or 0) then
						break
					end
				end
			end
			if diff_count > (allow_smudge and 1 or 0) then
				break
			end
		end
		if diff_count == (allow_smudge and 1 or 0) then
			return i * 100
		end
	end

	-- check vertical reflection lines
	for j = 1, cols - 1 do
		local diff_count = 0
		local dist = math.min(j, cols - j)
		for d = 1, dist do
			for r = 1, rows do
				if grid[r]:sub(j - d + 1, j - d + 1) ~= grid[r]:sub(j + d, j + d) then
					diff_count = diff_count + 1
					if diff_count > (allow_smudge and 1 or 0) then
						break
					end
				end
			end
			if diff_count > (allow_smudge and 1 or 0) then
				break
			end
		end
		if diff_count == (allow_smudge and 1 or 0) then
			return j
		end
	end

	return 0
end

function M.part1(input)
	local grids = parse_grids(input)
	local sum = 0
	for _, grid in ipairs(grids) do
		sum = sum + find_reflection(grid, false)
	end
	return sum
end

function M.part2(input)
	local grids = parse_grids(input)
	local sum = 0
	for _, grid in ipairs(grids) do
		sum = sum + find_reflection(grid, true)
	end
	return sum
end

return M
