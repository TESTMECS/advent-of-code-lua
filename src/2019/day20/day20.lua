--- @title: Day 20: Donut Maze ---
local M = {}

--- Parses the grid and finds all portals, their locations, and their pairings.
local function parse_and_find_portals(input)
	local grid = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(grid, line)
	end

	local height, width = #grid, #grid[1]
	local portal_points = {} -- { label -> { {x,y}, {x,y} } }
	local start_pos, end_pos

	-- Find all letter pairs and associate them with an adjacent '.'
	for y = 1, height - 1 do
		for x = 1, width - 1 do
			local c1 = grid[y]:sub(x, x)
			if c1:match("[A-Z]") then
				local c2
				-- Check horizontal pair
				c2 = grid[y]:sub(x + 1, x + 1)
				if c2:match("[A-Z]") then
					local label = c1 .. c2
					if x > 1 and grid[y]:sub(x - 1, x - 1) == "." then -- Portal is to the right
						if not portal_points[label] then
							portal_points[label] = {}
						end
						table.insert(portal_points[label], { x = x - 1, y = y })
					elseif x + 2 <= width and grid[y]:sub(x + 2, x + 2) == "." then -- Portal is to the left
						if not portal_points[label] then
							portal_points[label] = {}
						end
						table.insert(portal_points[label], { x = x + 2, y = y })
					end
				end
				-- Check vertical pair
				c2 = grid[y + 1]:sub(x, x)
				if c2:match("[A-Z]") then
					local label = c1 .. c2
					if y > 1 and grid[y - 1]:sub(x, x) == "." then -- Portal is below
						if not portal_points[label] then
							portal_points[label] = {}
						end
						table.insert(portal_points[label], { x = x, y = y - 1 })
					elseif y + 2 <= height and grid[y + 2]:sub(x, x) == "." then -- Portal is above
						if not portal_points[label] then
							portal_points[label] = {}
						end
						table.insert(portal_points[label], { x = x, y = y + 2 })
					end
				end
			end
		end
	end

	-- Create the final portal lookup map: portal_at[y..','..x] -> {dest_x, dest_y, type}
	local portal_at = {}
	start_pos = portal_points["AA"][1]
	end_pos = portal_points["ZZ"][1]

	for label, points in pairs(portal_points) do
		if #points == 2 then
			local p1, p2 = points[1], points[2]
			-- Determine inner/outer
			local p1_type = (p1.x == 3 or p1.x == width - 2 or p1.y == 3 or p1.y == height - 2) and "outer" or "inner"
			local p2_type = (p2.x == 3 or p2.x == width - 2 or p2.y == 3 or p2.y == height - 2) and "outer" or "inner"

			portal_at[p1.y .. "," .. p1.x] = { x = p2.x, y = p2.y, type = p1_type }
			portal_at[p2.y .. "," .. p2.x] = { x = p1.x, y = p1.y, type = p2_type }
		end
	end

	return grid, portal_at, start_pos, end_pos
end

--- @description Find the shortest path in the non-recursive donut maze.
function M.part1(input)
	local grid, portal_at, start_pos, end_pos = parse_and_find_portals(input)

	local q = { { x = start_pos.x, y = start_pos.y, dist = 0 } }
	local visited = { [start_pos.y .. "," .. start_pos.x] = true }

	while #q > 0 do
		local curr = table.remove(q, 1)

		if curr.x == end_pos.x and curr.y == end_pos.y then
			return curr.dist
		end

		-- 1. Try walking
		for _, d in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
			local nx, ny = curr.x + d[1], curr.y + d[2]
			local key = ny .. "," .. nx
			if not visited[key] and grid[ny]:sub(nx, nx) == "." then
				visited[key] = true
				table.insert(q, { x = nx, y = ny, dist = curr.dist + 1 })
			end
		end

		-- 2. Try teleporting
		local key = curr.y .. "," .. curr.x
		local portal_dest = portal_at[key]
		if portal_dest then
			local dest_key = portal_dest.y .. "," .. portal_dest.x
			if not visited[dest_key] then
				visited[dest_key] = true
				table.insert(q, { x = portal_dest.x, y = portal_dest.y, dist = curr.dist + 1 })
			end
		end
	end
end

--- @description Find the shortest path in the recursive donut maze.
function M.part2(input)
	local grid, portal_at, start_pos, end_pos = parse_and_find_portals(input)

	local q = { { x = start_pos.x, y = start_pos.y, level = 0, dist = 0 } }
	local visited = { ["0," .. start_pos.y .. "," .. start_pos.x] = true }

	while #q > 0 do
		local curr = table.remove(q, 1)

		if curr.x == end_pos.x and curr.y == end_pos.y and curr.level == 0 then
			return curr.dist
		end

		-- 1. Try walking
		for _, d in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
			local nx, ny = curr.x + d[1], curr.y + d[2]
			local key = curr.level .. "," .. ny .. "," .. nx
			if not visited[key] and grid[ny]:sub(nx, nx) == "." then
				visited[key] = true
				table.insert(q, { x = nx, y = ny, level = curr.level, dist = curr.dist + 1 })
			end
		end

		-- 2. Try teleporting
		local portal_key = curr.y .. "," .. curr.x
		local portal_dest = portal_at[portal_key]
		if portal_dest then
			local new_level
			if portal_dest.type == "inner" then
				new_level = curr.level + 1
			elseif portal_dest.type == "outer" then
				new_level = curr.level - 1
			end

			if new_level >= 0 then
				local dest_key = new_level .. "," .. portal_dest.y .. "," .. portal_dest.x
				if not visited[dest_key] then
					visited[dest_key] = true
					table.insert(q, { x = portal_dest.x, y = portal_dest.y, level = new_level, dist = curr.dist + 1 })
				end
			end
		end
	end
end

return M
