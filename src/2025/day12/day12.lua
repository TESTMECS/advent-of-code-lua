local util = require("src.util")
local M = {}
---@diagnostic disable
local ex = [[ 
0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2
]]
---@param grid_lines string[]
---@return coords
local function parse_grid(grid_lines)
	---@class coords
	---@field r number
	---@field c number
	local coords = {}
	for r, line in ipairs(grid_lines) do
		for c = 1, #line do
			if line:sub(c, c) == "#" then
				table.insert(coords, { r = r - 1, c = c - 1 })
			end
		end
	end
	return coords
end
---@param coords coords
---@return coords, number, number
local function normalize(coords)
	-- 1. Sort coordinates by reading order (row then col)
	table.sort(coords, function(a, b)
		if a.r == b.r then
			return a.c < b.c
		end
		return a.r < b.r
	end)

	-- 2. Calculate the offset based on the FIRST cell
	-- The first cell MUST be at (0,0) for the anchor logic to work.
	local r_offset = coords[1].r
	local c_offset = coords[1].c

	local new_coords = {}
	local max_r, max_c = 0, 0

	for _, p in ipairs(coords) do
		local nr = p.r - r_offset
		local nc = p.c - c_offset
		table.insert(new_coords, { r = nr, c = nc })
		if nr > max_r then
			max_r = nr
		end
		if nc > max_c then
			max_c = nc
		end
	end

	return new_coords, max_r + 1, max_c + 1
end
---@param coords coords
---@return string
local function shape_to_key(coords)
	local s = ""
	for _, p in ipairs(coords) do
		s = s .. string.format("(%d, %d)", p.r, p.c)
	end
	return s
end
-- Generate all 8 symmetries (rotations + flips)
---@param original_coords coords
---@return variants
local function generate_variants(original_coords)
	---@class variants
	---@field coords coords
	---@field h number
	---@field w number
	local variants = {}
	local seen = {}

	---@param coords coords
	local function add(coords)
		local norm, h, w = normalize(coords)
		local k = shape_to_key(norm)
		if not seen[k] then
			seen[k] = true
			table.insert(variants, { coords = norm, h = h, w = w })
		end
	end

	local current = original_coords
	-- 4 Rotations
	for _ = 1, 4 do
		-- Rotate 90 degrees clockwise: (r, c) -> (c, -r)
		local rotated = {}
		for _, p in ipairs(current) do
			table.insert(rotated, { r = p.c, c = -p.r })
		end
		current = rotated
		add(current)

		-- Flip current (Reflection over Y-axis: c -> -c)
		local flipped = {}
		for _, p in ipairs(current) do
			table.insert(flipped, { r = p.r, c = -p.c })
		end
		add(flipped) -- add flipped.
	end

	return variants
end
---@description Check if a shape fits at (row, col)
---@param grid number[][]
---@param W number
---@param H number
---@param shape_obj variants
---@param r_offset number
---@param c_offset number
---@return boolean
local function can_fit(grid, W, H, shape_obj, r_offset, c_offset)
	-- Quick bounds check
	if r_offset + shape_obj.h > H then
		return false
	end
	if c_offset + shape_obj.w > W then
		return false
	end

	for _, p in ipairs(shape_obj.coords) do
		local nr = r_offset + p.r
		local nc = c_offset + p.c
		-- Only check grid collision (bounds checked above implicitly mostly, but good to be safe)
		if nr >= H or nc >= W or grid[nr][nc] == 1 then
			return false
		end
	end
	return true
end
---@param grid number[][]
---@param shape_obj variants
---@param r_offset number
---@param c_offset number
---@param val number
local function toggle_shape(grid, shape_obj, r_offset, c_offset, val)
	for _, p in ipairs(shape_obj.coords) do
		grid[r_offset + p.r][c_offset + p.c] = val
	end
end
---@param grid number[][]
---@param W number
---@param H number
---@return number?, number?
local function find_first_empty(grid, W, H)
	for r = 0, H - 1 do
		for c = 0, W - 1 do
			if grid[r][c] == 0 then
				return r, c
			end
		end
	end
	return nil
end
---@param grid number[][]
---@param W number
---@param H number
---@param pieces table
---@param used_mask table<number, boolean>
---@param pieces_left number
---@param current_empty_area number
---@param remaining_piece_area number
---@return boolean
local function solve_recursive(grid, W, H, pieces, used_mask, pieces_left, current_empty_area, remaining_piece_area)
	-- SUCCESS: If no pieces left to place, we found a valid packing!
	if pieces_left == 0 then
		return true
	end

	-- PRUNING 1: Not enough space left?
	if current_empty_area < remaining_piece_area then
		return false
	end

	-- 1. Find the target square we MUST handle (fill or skip)
	local r, c = find_first_empty(grid, W, H)
	if not c or not r then
		error("First empty grid failed to be found.")
	end

	-- If no empty squares but we still have pieces (checked at top), fail.
	if not r then
		return false
	end

	-- OPTION A: Try to fill (r,c) with a piece
	for i, p_info in ipairs(pieces) do
		if not used_mask[i] then
			-- Symmetry Breaking: Force identical pieces to be used in order
			local skip_piece = false
			if i > 1 and pieces[i].id == pieces[i - 1].id and not used_mask[i - 1] then
				skip_piece = true
			end

			if not skip_piece then
				for _, shape in ipairs(p_info.variants) do
					-- Check fit
					if can_fit(grid, W, H, shape, r, c) then
						-- Place
						toggle_shape(grid, shape, r, c, 1)
						used_mask[i] = true

						-- Recurse
						if
							solve_recursive(
								grid,
								W,
								H,
								pieces,
								used_mask,
								pieces_left - 1,
								current_empty_area - p_info.area,
								remaining_piece_area - p_info.area
							)
						then
							return true
						end

						-- Backtrack
						used_mask[i] = false
						toggle_shape(grid, shape, r, c, 0)
					end
				end
			end
		end
	end

	-- OPTION B: Leave (r,c) empty (Skip this cell)
	-- We mark it with '2' so find_first_empty ignores it, effectively declaring it a "hole"
	grid[r][c] = 2
	if solve_recursive(grid, W, H, pieces, used_mask, pieces_left, current_empty_area - 1, remaining_piece_area) then
		return true
	end
	grid[r][c] = 0 -- Backtrack

	return false
end
---@param input string
---@return nil
function M.part1(input)
	local all_lines = util.read_lines(input)
	local shape_defs = {}
	local queries = {}
	local current_shape_id = nil
	local current_shape_lines = {}
	local function finalize_shape()
		if current_shape_id ~= nil then
			local base_coords = parse_grid(current_shape_lines)
			shape_defs[current_shape_id] = generate_variants(base_coords)
		end
		current_shape_id = nil
		current_shape_lines = {}
	end
	for _, line in ipairs(all_lines) do
		-- Shape Header "0:"
		local id_match = line:match("^(%d+):")
		if id_match then
			finalize_shape()
			current_shape_id = tonumber(id_match)

		-- Query Line "4x4: 0 0..."
		elseif line:match("^%d+x%d+:") then
			finalize_shape() -- ensure previous shape is saved
			table.insert(queries, line)

		-- Shape Body "#.."
		elseif line:find("[#%.]") then
			table.insert(current_shape_lines, line)
		else
			-- Empty lines finalize shapes
			finalize_shape()
		end
	end
	finalize_shape()

	-- Run Queries
	print("Processing " .. #queries .. " regions...")
	local success_count = 0

	for _, q_line in ipairs(queries) do
		local w_str, h_str, counts_str = q_line:match("^(%d+)x(%d+):%s*(.*)")
		local W, H = tonumber(w_str), tonumber(h_str)
		if not W or not H then
			error("failed to parse W and H query")
		end

		-- Build list of pieces to place
		local pieces_to_place = {}
		local p_idx = 0
		for count in counts_str:gmatch("%d+") do
			local c = tonumber(count)
			for _ = 1, c do
				local area = #shape_defs[p_idx][1].coords
				-- We store the id and the precomputed variants
				table.insert(pieces_to_place, {
					id = p_idx,
					variants = shape_defs[p_idx],
					placed_pos = -1,
					area = area,
				})
			end
			p_idx = p_idx + 1
		end

		-- Sort pieces: Placing larger/more complex pieces first helps fail faster.
		-- Here we simply sort by ID, but sorting by size of variants would be better optimization.
		-- However, for symmetry breaking to work easily, identical IDs must be adjacent.
		-- Calculate total required area for initial call
		local total_piece_area = 0
		for _, p in ipairs(pieces_to_place) do
			total_piece_area = total_piece_area + p.area
		end
		table.sort(pieces_to_place, function(a, b)
			-- We can estimate size by number of coords in the first variant
			local size_a = #a.variants[1].coords
			local size_b = #b.variants[1].coords
			if size_a == size_b then
				return a.id < b.id
			end
			return size_a > size_b
		end)

		-- Create empty grid (0 = empty, 1 = filled)
		local grid = {}
		for r = 0, H - 1 do
			grid[r] = {}
			for c = 0, W - 1 do
				grid[r][c] = 0
			end
		end

		print(string.format("Checking Region %dx%d...", W, H))

		if solve_recursive(grid, W, H, pieces_to_place, {}, #pieces_to_place, W * H, total_piece_area) then
			print("  -> Fits!")
			success_count = success_count + 1
		else
			print("  -> Impossible.")
		end
	end

	print("---------------------------")
	print("Total regions that fit: " .. success_count)
end

---@return nil
function M.part2() end

return M
