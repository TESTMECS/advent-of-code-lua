local M = {}

---@description Helper function to create a point.
---@param x number
---@param y number
---@return {x:number,y:number}
local function Pos(x, y)
	return { x = x, y = y }
end

---@description Parse input into a list of points.
---@param input string
---@return {x:number,y:number}[]
local function parse_input(input)
	local tiles = {}
	for x_str, y_str in input:gmatch("(%d+),(%d+)") do
		local x = tonumber(x_str)
		local y = tonumber(y_str)
		if not x or not y then
			error("Invalid input: " .. input)
		end
		table.insert(tiles, Pos(x, y))
	end
	return tiles
end

---@param input string
---@return number
function M.part1(input)
	-- Parse numbers into points{x,y}
	---@type {x:number,y:number}[]
	local points = parse_input(input)
	--- Find the max area by checking all pairs of points
	local max = 0 ---@type number
	for i = 1, #points - 1 do
		for j = i + 1, #points do
			local p1 = points[i]
			local p2 = points[j]
			local width = math.abs(p2.x - p1.x) + 1
			local height = math.abs(p2.y - p1.y) + 1
			local area = width * height
			if area > max then
				max = area
			end
		end
	end
	return max
end

---@description Helper function to find the min and max of two numbers.
---@param a number
---@param b number
---@return number, number
local function min_max(a, b)
	if a < b then
		return a, b
	else
		return b, a
	end
end

local function check_intersection(rect_line, poly_line)
	-- Ignore parallel lines
	if rect_line.dir == poly_line.dir then
		return false
	end
	if rect_line.dir == "Horizontal" then
		-- Poly is Vertical. Check if Poly X is within Rect X
		local r_min_x, r_max_x = min_max(rect_line.a.x, rect_line.b.x)
		local x_overlap = poly_line.a.x > r_min_x and poly_line.a.x < r_max_x
		-- Check if Rect Y is within Poly Y range
		local p_min_y, p_max_y = min_max(poly_line.a.y, poly_line.b.y)
		local y_overlap = rect_line.a.y > p_min_y and rect_line.a.y < p_max_y

		return x_overlap and y_overlap
	elseif rect_line.dir == "Vertical" then
		-- Poly is Horizontal. Check if Rect X is within Poly X range
		local p_min_x, p_max_x = min_max(poly_line.a.x, poly_line.b.x)
		local x_overlap = rect_line.a.x > p_min_x and rect_line.a.x < p_max_x
		-- Check if Poly Y is within Rect Y range
		local r_min_y, r_max_y = min_max(rect_line.a.y, rect_line.b.y)
		local y_overlap = poly_line.a.y > r_min_y and poly_line.a.y < r_max_y

		return x_overlap and y_overlap
	end
	return false
end

local function is_point_in_polygon(p, outline)
	local intersections = 0
	for _, line in ipairs(outline) do
		if line.dir == "Vertical" then
			local min_y, max_y = min_max(line.a.y, line.b.y)
			if p.y > min_y and p.y <= max_y and line.a.x > p.x then
				intersections = intersections + 1
			end
		end
	end
	return intersections % 2 ~= 0
end

---@param input string
---@return number
function M.part2(input)
	---@type {x:number,y:number}[]
	local tiles = parse_input(input)
	local n = #tiles
	local outline = {}

	-- Generate the outline of the polygon.
	for i = 1, n do
		local prev_idx = (i - 2) % n + 1
		local curr_idx = (i - 1) % n + 1
		local next_idx = i % n + 1

		local prev = tiles[prev_idx]
		local curr = tiles[curr_idx]
		local next_node = tiles[next_idx]

		local offset = Pos(0, 0)
		local dir = ""

		if curr.y == prev.y then
			dir = "Horizontal"
			if curr.x > prev.x then
				if next_node.y < curr.y then
					offset = Pos(-0.5, -0.5)
				else
					offset = Pos(0.5, -0.5)
				end
			else
				if next_node.y > curr.y then
					offset = Pos(0.5, 0.5)
				else
					offset = Pos(-0.5, 0.5)
				end
			end
		else
			dir = "Vertical"
			if curr.y > prev.y then
				if next_node.x > curr.x then
					offset = Pos(-0.5, 0.5)
				else
					offset = Pos(0.5, 0.5)
				end
			else
				if next_node.x < curr.x then
					offset = Pos(-0.5, 0.5)
				else
					offset = Pos(-0.5, -0.5)
				end
			end
		end
		-- Calculate the start and end points of the line.
		local line_start
		if i == 1 then
			line_start = Pos(0, 0) -- Placeholder fixed after loop
		else
			line_start = outline[i - 1].b
		end
		local line_end = Pos(curr.x + offset.x, curr.y + offset.y)
		table.insert(outline, { a = line_start, b = line_end, dir = dir })
	end
	-- Fix the wrap-around connection
	outline[1].a = outline[n].b
	-- Find candidates
	local candidates = {}
	for i = 1, n - 1 do
		for j = i + 1, n do
			local c1 = tiles[i]
			local c3 = tiles[j]
			local w = math.abs(c1.x - c3.x) + 1
			local h = math.abs(c1.y - c3.y) + 1
			local area = w * h
			table.insert(candidates, { p1 = c1, p2 = c3, area = area })
		end
	end
	-- Sort candidates area descending order
	table.sort(candidates, function(a, b)
		return a.area > b.area
	end)
	-- Search for the max square
	local max_square = 0
	for _, cand in ipairs(candidates) do
		local c1 = cand.p1
		local c3 = cand.p2
		local c2 = Pos(c1.x, c3.y)
		local c4 = Pos(c3.x, c1.y)
		local rect_lines = {
			{ a = c1, b = c2, dir = (c1.x == c2.x) and "Vertical" or "Horizontal" },
			{ a = c2, b = c3, dir = (c2.x == c3.x) and "Vertical" or "Horizontal" },
			{ a = c3, b = c4, dir = (c3.x == c4.x) and "Vertical" or "Horizontal" },
			{ a = c4, b = c1, dir = (c4.x == c1.x) and "Vertical" or "Horizontal" },
		}
		local valid = true
		-- check intersections
		for _, r_line in ipairs(rect_lines) do
			for _, o_line in ipairs(outline) do
				if check_intersection(r_line, o_line) then
					valid = false
					break
				end
			end
			if not valid then
				break
			end
		end
		-- check center point
		if valid then
			local center = Pos((c1.x + c3.x) / 2, (c1.y + c3.y) / 2)
			if not is_point_in_polygon(center, outline) then
				valid = false
			end
		end
		if valid then
			max_square = cand.area
			break
		end
	end
	print("Max Square: " .. string.format("%.0f", max_square))
	return max_square
end

return M
