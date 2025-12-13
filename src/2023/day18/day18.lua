--- @title: --- Day 18: Lavaduct Lagoon ---
local M = {}

-- This problem can be solved by modeling the dig plan as a polygon on an integer grid.
-- The total area of lava is the number of integer points on the boundary (B) plus the number
-- of integer points in its interior (I). This can be calculated using two geometric theorems:
--
-- 1. Shoelace Formula: Calculates twice the area (2A) of a polygon given the coordinates of its vertices.
--    2A = |(x1*y2 - y1*x2) + (x2*y3 - y2*x3) + ...|
--
-- 2. Pick's Theorem: Relates the area (A) of a simple polygon to B and I.
--    A = I + B/2 - 1
--
-- By combining them, we can find the total number of points (I + B):
--    I = A - B/2 + 1
--    Total = I + B = (A - B/2 + 1) + B = A + B/2 + 1
--    To avoid floating point issues, we use 2A:
--    Total = (2A / 2) + (B / 2) + 1 = (2A + B) / 2 + 1

-- --- HELPER FUNCTIONS ---

--- Parses a line for Part 1, e.g., "R 6 (#70c710)".
local function parse_part1(line)
	local dir, dist_str = line:match("(%S) (%d+)")
	return dir, tonumber(dist_str)
end

-- Maps the last digit of the hex code to a direction character.
local DIR_MAP = { [0] = "R", [1] = "D", [2] = "L", [3] = "U" }

--- Parses a line for Part 2, extracting instructions from the hex code.
local function parse_part2(line)
	local hex_dist, hex_dir = line:match("#(.....)(.)")
	local dist = tonumber(hex_dist, 16)
	local dir = DIR_MAP[tonumber(hex_dir)]
	return dir, dist
end

--- Calculates the total lagoon capacity using a given line parser.
local function solve(input, line_parser)
	-- Directions: Positive y is Down, Positive x is Right. {dy, dx}
	local DIRS = {
		U = { -1, 0 },
		D = { 1, 0 },
		L = { 0, -1 },
		R = { 0, 1 },
	}

	local y, x = 0, 0
	local vertices = { { 0, 0 } }
	local boundary_len = 0

	-- 1. Generate vertices and calculate boundary length (perimeter).
	for line in input:gmatch("[^\n]+") do
		if #line > 0 then
			local dir_char, dist = line_parser(line)
			local move = DIRS[dir_char]
			y = y + move[1] * dist
			x = x + move[2] * dist
			table.insert(vertices, { y, x })
			boundary_len = boundary_len + dist
		end
	end

	-- 2. Calculate 2 * Area (the "shoelace sum") using the Shoelace formula.
	-- This keeps the calculation in the integer domain.
	local shoelace_sum_2A = 0
	for i = 1, #vertices - 1 do
		local y1, x1 = table.unpack(vertices[i])
		local y2, x2 = table.unpack(vertices[i + 1])
		shoelace_sum_2A = shoelace_sum_2A + (x1 * y2 - x2 * y1)
	end

	-- 3. Use the rearranged Pick's Theorem formula to find the total points.
	-- This avoids floating-point division until the last possible moment
	-- on a number that is guaranteed to be even.
	local total_points = (math.abs(shoelace_sum_2A) + boundary_len) / 2 + 1

	return total_points
end

-- --- PUBLIC API ---

--- @description Calculates the lagoon capacity based on the digger's instructions.
--- @param input string the puzzle input
--- @return number The total capacity in cubic meters.
function M.part1(input)
	return solve(input, parse_part1)
end

--- @description Calculates the lagoon capacity by decoding instructions from the hex color codes.
--- @param input string the puzzle input
--- @return number The total capacity in cubic meters.
function M.part2(input)
	return string.format("Part 2: %.0f", solve(input, parse_part2))
end

return M
