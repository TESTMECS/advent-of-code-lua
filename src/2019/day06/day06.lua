--- @title: Day 6: Universal Orbit Map ---
local M = {}

--- @function: parse_orbits
--- @param input string the puzzle input
--- @return table the orbits
local function parse_orbits(input)
	local orbits = {} -- maps a child to its parent, e.g., orbits[B] = A for A)B
	for line in input:gmatch("[^\r\n]+") do
		local a, b = line:match("([^%)]+)%)(.+)")
		if a and b then
			orbits[b] = a
		end
	end
	return orbits
end

--- @function: count_orbits
--- @param obj string: the object to count orbits for
--- @param orbits table: the orbits
--- @return number: the orbit count
local function count_orbits(obj, orbits)
	local count = 0
	local current_obj = obj
	while orbits[current_obj] do
		count = count + 1
		current_obj = orbits[current_obj]
	end
	return count
end

--- @description: Count the total number of direct and indirect orbits
--- @param input string: the puzzle input
--- @return number: the total orbit count
function M.part1(input)
	local orbits = parse_orbits(input)
	local total = 0
	for obj in pairs(orbits) do
		total = total + count_orbits(obj, orbits)
	end
	return total
end

--- @description: Find the minimum orbital transfers between YOU and SAN
--- @param input string: the puzzle input
--- @return number: the minimum transfers
function M.part2(input)
	local orbits = parse_orbits(input)

	-- 1. Build a path map from where YOU are orbiting, up to COM.
	-- The map will store {object_name = distance_from_start}.
	local path_from_you = {}
	local current = orbits["YOU"] -- Start from the object YOU are orbiting
	local dist = 0
	while current do
		path_from_you[current] = dist
		current = orbits[current]
		dist = dist + 1
	end

	-- 2. Trace the path up from where SAN is orbiting.
	-- The first object we find that's also in path_from_you is the
	-- lowest common ancestor.
	current = orbits["SAN"] -- Start from the object SAN is orbiting
	dist = 0
	while current do
		if path_from_you[current] ~= nil then
			-- Found the common ancestor!
			-- The total transfers is the distance from SAN's orbit point to here,
			-- plus the distance from YOU's orbit point to here (from the map).
			return dist + path_from_you[current]
		end
		current = orbits[current]
		dist = dist + 1
	end

	return -1 -- Should not happen with valid puzzle input
end

return M
