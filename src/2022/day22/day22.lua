local M = {}

local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local path = lines[#lines]
	local grid = {}
	for i = 1, #lines - 1 do
		if lines[i] ~= "" then
			table.insert(grid, lines[i])
		else
			break
		end
	end
	return grid, path
end

local function find_start(grid)
	for c = 1, #grid[1] do
		if grid[1]:sub(c, c) == "." then
			return 1, c, 0
		end
	end
end

local function parse_path(path)
	local instructions = {}
	for num, turn in path:gmatch("(%d+)([LR]?)") do
		table.insert(instructions, { steps = tonumber(num), turn = turn })
	end
	return instructions
end

local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }

-- Flat wrapping for Part 1
local function flat_wrap(grid, r, c, dr, dc)
	local nr, nc = r, c
	repeat
		nr = nr - dr
		nc = nc - dc
		if nr < 1 then
			nr = #grid
		end
		if nr > #grid then
			nr = 1
		end
		if nc < 1 then
			nc = #(grid[nr] or "")
		end
		if nc > #(grid[nr] or "") then
			nc = 1
		end
	until nr >= 1 and nr <= #grid and nc >= 1 and nc <= #(grid[nr] or "") and grid[nr]:sub(nc, nc) ~= " "
	return nr, nc
end

local function simulate_flat(grid, instructions)
	local r, c, dir = find_start(grid)
	for _, inst in ipairs(instructions) do
		for _ = 1, inst.steps do
			local dr, dc = dirs[dir + 1][1], dirs[dir + 1][2]
			local nr, nc = r + dr, c + dc

			if nr < 1 or nr > #grid or nc < 1 or nc > #(grid[nr] or "") or grid[nr]:sub(nc, nc) == " " then
				nr, nc = flat_wrap(grid, r, c, dr, dc)
			end

			if grid[nr]:sub(nc, nc) == "#" then
				break
			end
			r, c = nr, nc
		end

		if inst.turn == "L" then
			dir = (dir - 1) % 4
		elseif inst.turn == "R" then
			dir = (dir + 1) % 4
		end
	end
	return r, c, dir
end

-- Cube part - corrected for your input
local face_size = 50

-- Your cube net:
--    AB    (faces 1,2)
--    C     (face 3)
--   DE     (faces 4,5)
--   F      (face 6)

local faces = {
	{ 1, 51 }, -- Face 1: top-left
	{ 1, 101 }, -- Face 2: top-right
	{ 51, 51 }, -- Face 3: middle
	{ 101, 1 }, -- Face 4: bottom-left
	{ 101, 51 }, -- Face 5: bottom-right
	{ 151, 1 }, -- Face 6: very bottom
}

-- Corrected cube transitions based on your net structure
-- Each transition: { target_face, new_direction, coordinate_transform }
local transitions = {
	[1] = {
		[0] = {
			2,
			0,
			function(r, c)
				return r, 1
			end,
		}, -- right -> face 2 left edge
		[1] = {
			3,
			1,
			function(r, c)
				return 1, c
			end,
		}, -- down -> face 3 top edge
		[2] = {
			4,
			0,
			function(r, c)
				return 51 - r + 1, 1
			end,
		}, -- left -> face 4 left edge (flipped)
		[3] = {
			6,
			0,
			function(r, c)
				return c, 1
			end,
		}, -- up -> face 6 left edge (rotated)
	},
	[2] = {
		[0] = {
			5,
			2,
			function(r, c)
				return 51 - r + 1, 50
			end,
		}, -- right -> face 5 right edge (flipped)
		[1] = {
			3,
			2,
			function(r, c)
				return c, 50
			end,
		}, -- down -> face 3 right edge (rotated)
		[2] = {
			1,
			2,
			function(r, c)
				return r, 50
			end,
		}, -- left -> face 1 right edge
		[3] = {
			6,
			3,
			function(r, c)
				return 50, c
			end,
		}, -- up -> face 6 bottom edge
	},
	[3] = {
		[0] = {
			2,
			3,
			function(r, c)
				return 50, r
			end,
		}, -- right -> face 2 bottom edge (rotated)
		[1] = {
			5,
			1,
			function(r, c)
				return 1, c
			end,
		}, -- down -> face 5 top edge
		[2] = {
			4,
			1,
			function(r, c)
				return 1, r
			end,
		}, -- left -> face 4 top edge (rotated)
		[3] = {
			1,
			3,
			function(r, c)
				return 50, c
			end,
		}, -- up -> face 1 bottom edge
	},
	[4] = {
		[0] = {
			5,
			0,
			function(r, c)
				return r, 1
			end,
		}, -- right -> face 5 left edge
		[1] = {
			6,
			1,
			function(r, c)
				return 1, c
			end,
		}, -- down -> face 6 top edge
		[2] = {
			1,
			0,
			function(r, c)
				return 51 - r + 1, 1
			end,
		}, -- left -> face 1 left edge (flipped)
		[3] = {
			3,
			0,
			function(r, c)
				return c, 1
			end,
		}, -- up -> face 3 left edge (rotated)
	},
	[5] = {
		[0] = {
			2,
			2,
			function(r, c)
				return 51 - r + 1, 50
			end,
		}, -- right -> face 2 right edge (flipped)
		[1] = {
			6,
			2,
			function(r, c)
				return c, 50
			end,
		}, -- down -> face 6 right edge (rotated)
		[2] = {
			4,
			2,
			function(r, c)
				return r, 50
			end,
		}, -- left -> face 4 right edge
		[3] = {
			3,
			3,
			function(r, c)
				return 50, c
			end,
		}, -- up -> face 3 bottom edge
	},
	[6] = {
		[0] = {
			5,
			3,
			function(r, c)
				return 50, r
			end,
		}, -- right -> face 5 bottom edge (rotated)
		[1] = {
			2,
			1,
			function(r, c)
				return 1, c
			end,
		}, -- down -> face 2 top edge
		[2] = {
			1,
			1,
			function(r, c)
				return 1, r
			end,
		}, -- left -> face 1 top edge (rotated)
		[3] = {
			4,
			3,
			function(r, c)
				return 50, c
			end,
		}, -- up -> face 4 bottom edge
	},
}

local function get_face(r, c)
	for i, f in ipairs(faces) do
		local fr, fc = f[1], f[2]
		if r >= fr and r < fr + face_size and c >= fc and c < fc + face_size then
			return i, r - fr + 1, c - fc + 1
		end
	end
end

local function simulate_cube(grid, instructions)
	local r, c, dir = find_start(grid)

	for _, inst in ipairs(instructions) do
		for _ = 1, inst.steps do
			local dr, dc = dirs[dir + 1][1], dirs[dir + 1][2]
			local nr, nc = r + dr, c + dc
			local ndir = dir

			-- Check if we need to wrap around cube edge
			if nr < 1 or nr > #grid or nc < 1 or nc > #(grid[nr] or "") or grid[nr]:sub(nc, nc) == " " then
				-- Get current face and local coordinates
				local face, fr, fc = get_face(r, c)
				if not face then
					print("Error: position not on any face:", r, c)
					break
				end

				-- Get the transition for this face and direction
				local trans = transitions[face][dir]
				if not trans then
					print("Error: no transition for face", face, "direction", dir)
					break
				end

				local nface, new_dir, transform = trans[1], trans[2], trans[3]
				local nfr, nfc = transform(fr, fc)

				-- Convert back to absolute coordinates
				local nface_r, nface_c = faces[nface][1], faces[nface][2]
				nr = nface_r + nfr - 1
				nc = nface_c + nfc - 1
				ndir = new_dir
			end

			-- Check if the new position is a wall
			if nr >= 1 and nr <= #grid and nc >= 1 and nc <= #(grid[nr] or "") and grid[nr]:sub(nc, nc) == "#" then
				break -- Hit a wall, stop moving
			end

			r, c, dir = nr, nc, ndir
		end

		-- Apply turn
		if inst.turn == "L" then
			dir = (dir - 1) % 4
		elseif inst.turn == "R" then
			dir = (dir + 1) % 4
		end
	end

	return r, c, dir
end

function M.part1(input)
	local grid, path = parse_input(input)
	local instructions = parse_path(path)
	local r, c, dir = simulate_flat(grid, instructions)
	return 1000 * r + 4 * c + dir
end

function M.part2(input)
	local grid, path = parse_input(input)
	local instructions = parse_path(path)
	local r, c, dir = simulate_cube(grid, instructions)
	return 1000 * r + 4 * c + dir
end

return M
