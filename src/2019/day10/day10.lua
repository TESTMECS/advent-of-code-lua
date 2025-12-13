--- @title: Day 10: Monitoring Station ---
local M = {}

--- @function: Parses the map into a list of asteroid coordinates {x, y}.
--- @param input string the puzzle input
--- @return table the asteroids
local function parse_map(input)
	local asteroids = {}
	local y = 0
	for line in input:gmatch("[^\r\n]+") do
		for x = 0, #line - 1 do
			if line:sub(x + 1, x + 1) == "#" then
				table.insert(asteroids, { x = x, y = y })
			end
		end
		y = y + 1
	end
	return asteroids
end

--- @function: Finds the best location and the number of asteroids visible from it.
--- @param asteroids table: the asteroids
--- @return table: the best location
--- @return number: the number of asteroids visible from the best location
local function find_best_location(asteroids)
	local best_location = nil
	local max_visible = 0

	for _, station in ipairs(asteroids) do
		local visible_angles = {}
		for _, target in ipairs(asteroids) do
			if station.x ~= target.x or station.y ~= target.y then
				local angle = math.atan(target.y - station.y, target.x - station.x)
				visible_angles[angle] = true
			end
		end

		local current_visible = 0
		for _ in pairs(visible_angles) do
			current_visible = current_visible + 1
		end

		if current_visible > max_visible then
			max_visible = current_visible
			best_location = station
		end
	end

	return best_location, max_visible
end

--- @description: Find the best location and count how many other asteroids can be detected.
--- @param input string: the puzzle input
--- @return number: The number of asteroids detectable from the best location.
function M.part1(input)
	local asteroids = parse_map(input)
	local _, max_visible = find_best_location(asteroids)
	return max_visible
end

--- @description: Vaporize asteroids and find the 200th one.
--- @param input string: the puzzle input
--- @return number: The result of `x * 100 + y` for the 200th vaporized asteroid.
function M.part2(input)
	local asteroids = parse_map(input)
	local station, _ = find_best_location(asteroids)

	local targets_by_angle = {}

	for _, target in ipairs(asteroids) do
		if station.x ~= target.x or station.y ~= target.y then
			local dx = target.x - station.x
			local dy = target.y - station.y

			-- Convert atan2 angle to "up = 0, clockwise"
			local angle = math.atan(dy, dx) + (math.pi / 2)
			if angle < 0 then
				angle = angle + (2 * math.pi)
			end

			local dist = dx * dx + dy * dy -- Use squared distance for sorting (faster)

			if not targets_by_angle[angle] then
				targets_by_angle[angle] = {}
			end
			table.insert(targets_by_angle[angle], { x = target.x, y = target.y, dist = dist })
		end
	end

	-- Sort asteroids at the same angle by distance (closest first)
	for angle in pairs(targets_by_angle) do
		table.sort(targets_by_angle[angle], function(a, b)
			return a.dist < b.dist
		end)
	end

	-- Get a sorted list of unique angles for clockwise firing
	local sorted_angles = {}
	for angle in pairs(targets_by_angle) do
		table.insert(sorted_angles, angle)
	end
	table.sort(sorted_angles)

	local vaporized_count = 0
	while true do
		for _, angle in ipairs(sorted_angles) do
			if #targets_by_angle[angle] > 0 then
				local target = table.remove(targets_by_angle[angle], 1)
				vaporized_count = vaporized_count + 1

				if vaporized_count == 200 then
					return target.x * 100 + target.y
				end
			end
		end
	end
end

return M
