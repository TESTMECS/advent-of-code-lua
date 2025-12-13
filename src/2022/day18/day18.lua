 --- @title: Day 18: Boiling Boulders ---
local M = {}

local function parse_cubes(input)
	local cubes = {}
	for line in input:gmatch("[^\n]+") do
		local x, y, z = line:match("(%d+),(%d+),(%d+)")
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		cubes[string.format("%d,%d,%d", x, y, z)] = true
	end
	return cubes
end

local dirs = { { -1, 0, 0 }, { 1, 0, 0 }, { 0, -1, 0 }, { 0, 1, 0 }, { 0, 0, -1 }, { 0, 0, 1 } }

--- @description Count total surface area
--- @param input string the puzzle input
--- @return number the surface area
function M.part1(input)
	local cubes = parse_cubes(input)
	local count = 0
	for cube in pairs(cubes) do
		local x, y, z = cube:match("(%d+),(%d+),(%d+)")
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		for _, d in ipairs(dirs) do
			local nx, ny, nz = x + d[1], y + d[2], z + d[3]
			local nkey = string.format("%d,%d,%d", nx, ny, nz)
			if not cubes[nkey] then
				count = count + 1
			end
		end
	end
	return count
end

--- @description Count external surface area
--- @param input string the puzzle input
--- @return number the surface area
function M.part2(input)
	local cubes = parse_cubes(input)
	local min_x, max_x = 0, 20
	local min_y, max_y = 0, 21
	local min_z, max_z = 0, 21
	local visited = {}
	local queue = {}
	for x = min_x, max_x do
		for y = min_y, max_y do
			for z = min_z, max_z do
				if x == min_x or x == max_x or y == min_y or y == max_y or z == min_z or z == max_z then
					local key = string.format("%d,%d,%d", x, y, z)
					if not cubes[key] then
						visited[key] = true
						table.insert(queue, { x, y, z })
					end
				end
			end
		end
	end
	while #queue > 0 do
		local curr = table.remove(queue, 1)
		local x, y, z = curr[1], curr[2], curr[3]
		for _, d in ipairs(dirs) do
			local nx, ny, nz = x + d[1], y + d[2], z + d[3]
			if nx >= min_x and nx <= max_x and ny >= min_y and ny <= max_y and nz >= min_z and nz <= max_z then
				local nkey = string.format("%d,%d,%d", nx, ny, nz)
				if not cubes[nkey] and not visited[nkey] then
					visited[nkey] = true
					table.insert(queue, { nx, ny, nz })
				end
			end
		end
	end
	local count = 0
	for cube in pairs(cubes) do
		local x, y, z = cube:match("(%d+),(%d+),(%d+)")
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		for _, d in ipairs(dirs) do
			local nx, ny, nz = x + d[1], y + d[2], z + d[3]
			local nkey = string.format("%d,%d,%d", nx, ny, nz)
			if nx < min_x or nx > max_x or ny < min_y or ny > max_y or nz < min_z or nz > max_z or visited[nkey] then
				count = count + 1
			end
		end
	end
	return count
end

return M
