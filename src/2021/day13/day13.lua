--- @title: Day 13: Title ---
local M = {}

--- @description: Perform the first fold and count the visible dots
--- @param input string: the puzzle input
--- @return number: the number of visible dots after the first fold
function M.part1(input)
	local dots = {}
	local folds = {}
	for line in input:gmatch("[^\n]+") do
		if line:match("(%d+),(%d+)") then
			local x, y = line:match("(%d+),(%d+)")
			table.insert(dots, { x = tonumber(x), y = tonumber(y) })
		elseif line:match("fold along") then
			local axis, val = line:match("fold along (%w+) *= *(%d+)")
			table.insert(folds, { axis = axis, val = tonumber(val) })
		end
	end
	--- @function fold
	--- @param dots table
	--- @param f table
	--- @return table
	local function fold(dots, f)
		local new_dots = {}
		local seen = {}
		for _, dot in ipairs(dots) do
			local x, y = dot.x, dot.y
			if f.axis == "x" then
				if x > f.val then
					x = 2 * f.val - x
				end
			elseif f.axis == "y" then
				if y > f.val then
					y = 2 * f.val - y
				end
			end
			local key = x .. "," .. y
			if not seen[key] then
				seen[key] = true
				table.insert(new_dots, { x = x, y = y })
			end
		end
		return new_dots
	end
	dots = fold(dots, folds[1])
	return #dots
end

--- @description: Perform all folds and return the code
--- @param input string: the puzzle input
--- @return string: the code displayed
function M.part2(input)
	local dots = {}
	local folds = {}
	for line in input:gmatch("[^\n]+") do
		if line:match("(%d+),(%d+)") then
			local x, y = line:match("(%d+),(%d+)")
			table.insert(dots, { x = tonumber(x), y = tonumber(y) })
		elseif line:match("fold along") then
			local axis, val = line:match("fold along (%w+) *= *(%d+)")
			table.insert(folds, { axis = axis, val = tonumber(val) })
		end
	end
	local function fold(dots, f)
		local new_dots = {}
		local seen = {}
		for _, dot in ipairs(dots) do
			local x, y = dot.x, dot.y
			if f.axis == "x" then
				if x > f.val then
					x = 2 * f.val - x
				end
			elseif f.axis == "y" then
				if y > f.val then
					y = 2 * f.val - y
				end
			end
			local key = x .. "," .. y
			if not seen[key] then
				seen[key] = true
				table.insert(new_dots, { x = x, y = y })
			end
		end
		return new_dots
	end
	-- apply all folds
	for _, f in ipairs(folds) do
		dots = fold(dots, f)
	end
	-- find bounds
	local min_x, max_x = math.huge, 0
	local min_y, max_y = math.huge, 0
	for _, dot in ipairs(dots) do
		min_x = math.min(min_x, dot.x)
		max_x = math.max(max_x, dot.x)
		min_y = math.min(min_y, dot.y)
		max_y = math.max(max_y, dot.y)
	end
	-- create grid
	local grid = {}
	for y = min_y, max_y do
		grid[y] = {}
		for x = min_x, max_x do
			grid[y][x] = "."
		end
	end
	for _, dot in ipairs(dots) do
		grid[dot.y][dot.x] = "#"
	end
	-- build string
	local result = ""
	for y = min_y, max_y do
		for x = min_x, max_x do
			result = result .. grid[y][x]
		end
		result = result .. "\n"
	end
	return result
end

return M
