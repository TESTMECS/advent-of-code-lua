--- @title: Day 14: Regolith Reservoir ---
local M = {}

local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	local rocks = {}
	for _, line in ipairs(lines) do
		local points = {}
		for x, y in line:gmatch("(%d+),(%d+)") do
			table.insert(points, { tonumber(x), tonumber(y) })
		end
		table.insert(rocks, points)
	end
	return rocks
end

-- compute bounds from rocks
local function find_bounds(rocks)
	local min_x, max_x = math.huge, -math.huge
	local min_y, max_y = 0, -math.huge -- source starts at y=0
	for _, path in ipairs(rocks) do
		for _, pt in ipairs(path) do
			local x, y = pt[1], pt[2]
			if x < min_x then
				min_x = x
			end
			if x > max_x then
				max_x = x
			end
			if y > max_y then
				max_y = y
			end
		end
	end
	return min_x, max_x, min_y, max_y
end

local function create_grid(rocks, with_floor)
	local min_x, max_x, min_y, max_y = find_bounds(rocks)

	if with_floor then
		max_y = max_y + 2
		-- sand can spread sideways as far as floor depth,
		-- so expand horizontally by max_y on each side
		min_x = math.min(min_x, 500 - max_y)
		max_x = math.max(max_x, 500 + max_y)
	end

	-- build grid
	local grid = {}
	for y = min_y, max_y do
		grid[y] = {}
		for x = min_x, max_x do
			grid[y][x] = "."
		end
	end

	-- draw rock paths
	for _, path in ipairs(rocks) do
		for i = 1, #path - 1 do
			local x1, y1 = path[i][1], path[i][2]
			local x2, y2 = path[i + 1][1], path[i + 1][2]
			if x1 == x2 then
				for y = math.min(y1, y2), math.max(y1, y2) do
					grid[y][x1] = "#"
				end
			else
				for x = math.min(x1, x2), math.max(x1, x2) do
					grid[y1][x] = "#"
				end
			end
		end
	end

	if with_floor then
		for x = min_x, max_x do
			grid[max_y][x] = "#"
		end
	end

	return grid, min_x, max_x, min_y, max_y
end

local function drop_sand(grid, sx, sy, max_y)
	local x, y = sx, sy
	-- source blocked
	if grid[y][x] ~= "." then
		return false
	end

	while true do
		-- abyss condition (part 1 only, floor handles itself)
		if y + 1 > max_y then
			return false
		end
		if grid[y + 1][x] == "." then
			y = y + 1
		elseif grid[y + 1][x - 1] == "." then
			y = y + 1
			x = x - 1
		elseif grid[y + 1][x + 1] == "." then
			y = y + 1
			x = x + 1
		else
			-- comes to rest
			grid[y][x] = "o"
			return true
		end
	end
end

--- @description Count sand units before falling into abyss
--- @param input string the puzzle input
--- @return number the count
function M.part1(input)
	local rocks = parse_input(input)
	local grid, _, _, _, max_y = create_grid(rocks, false)
	local count = 0
	while drop_sand(grid, 500, 0, max_y) do
		count = count + 1
	end
	return count
end

--- @description Count sand units until source is blocked
--- @param input string the puzzle input
--- @return number the count
function M.part2(input)
	local rocks = parse_input(input)
	local grid, _, _, _, max_y = create_grid(rocks, true)
	local count = 0
	while drop_sand(grid, 500, 0, max_y) do
		count = count + 1
	end
	return count
end

return M
