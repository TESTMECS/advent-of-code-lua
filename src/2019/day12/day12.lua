--- @title: Day 12: The N-Body Problem ---
local M = {}

--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
local function parse_input(input)
	local moons = {}
	for line in input:gmatch("<x=([^>]+)>") do
		local x, y, z = line:match("(-?%d+), y=(-?%d+), z=(-?%d+)")
		table.insert(
			moons,
			{ pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }, vel = { x = 0, y = 0, z = 0 } }
		)
	end
	return moons
end

--- @function: Simulates a single step of the simulation.
--- @param moons table: The moons.
--- @return nil
local function simulate_step(moons)
	-- Apply gravity
	for i = 1, #moons do
		for j = i + 1, #moons do
			local a = moons[i]
			local b = moons[j]
			if a.pos.x > b.pos.x then
				a.vel.x = a.vel.x - 1
				b.vel.x = b.vel.x + 1
			elseif a.pos.x < b.pos.x then
				a.vel.x = a.vel.x + 1
				b.vel.x = b.vel.x - 1
			end
			if a.pos.y > b.pos.y then
				a.vel.y = a.vel.y - 1
				b.vel.y = b.vel.y + 1
			elseif a.pos.y < b.pos.y then
				a.vel.y = a.vel.y + 1
				b.vel.y = b.vel.y - 1
			end
			if a.pos.z > b.pos.z then
				a.vel.z = a.vel.z - 1
				b.vel.z = b.vel.z + 1
			elseif a.pos.z < b.pos.z then
				a.vel.z = a.vel.z + 1
				b.vel.z = b.vel.z - 1
			end
		end
	end
	-- Apply velocity
	for _, moon in ipairs(moons) do
		moon.pos.x = moon.pos.x + moon.vel.x
		moon.pos.y = moon.pos.y + moon.vel.y
		moon.pos.z = moon.pos.z + moon.vel.z
	end
end

--- @function: Calculates the total energy of the system.
--- @param moons table: The moons.
--- @return number: The total energy.
local function calculate_energy(moons)
	local total = 0
	for _, moon in ipairs(moons) do
		local pot = math.abs(moon.pos.x) + math.abs(moon.pos.y) + math.abs(moon.pos.z)
		local kin = math.abs(moon.vel.x) + math.abs(moon.vel.y) + math.abs(moon.vel.z)
		total = total + pot * kin
	end
	return total
end

--- @function: Copies the moons.
--- @param moons table: The moons.
--- @return table: The copy.
local function copy_moons(moons)
	local copy = {}
	for _, moon in ipairs(moons) do
		table.insert(copy, {
			pos = { x = moon.pos.x, y = moon.pos.y, z = moon.pos.z },
			vel = { x = moon.vel.x, y = moon.vel.y, z = moon.vel.z },
		})
	end
	return copy
end

--- @function: Calculates the greatest common divisor using integer arithmetic.
--- @param a number: The first number.
--- @param b number: The second number.
--- @return number: The greatest common divisor.
local function gcd(a, b)
	while b ~= 0 do
		a, b = b, a % b
	end
	return a
end

---@function: Calculates the least common multiple using integer arithmetic.
---@param a number: The first number.
---@param b number: The second number.
---@return number: The least common multiple.
local function lcm(a, b)
	if a == 0 or b == 0 then
		return 0
	end
	-- Use math.floor to perform integer division. This is crucial for large numbers
	-- to avoid floating-point inaccuracies. Performing division first also
	-- prevents intermediate numbers from becoming unnecessarily large.
	return math.floor(a / gcd(a, b)) * b
end

--- @description Calculate total energy after 1000 steps
--- @param input string the puzzle input
--- @return number the total energy
function M.part1(input)
	local moons = parse_input(input)
	for _ = 1, 1000 do
		simulate_step(moons)
	end
	return calculate_energy(moons)
end

--- @description Find the number of steps until the system repeats
--- @param input string the puzzle input
--- @return number the steps
function M.part2(input)
	local initial_state = parse_input(input)
	local moons = copy_moons(initial_state)

	local periods = { x = 0, y = 0, z = 0 }
	local steps = 0

	while periods.x == 0 or periods.y == 0 or periods.z == 0 do
		simulate_step(moons)
		steps = steps + 1

		local x_match, y_match, z_match = true, true, true
		for i = 1, #moons do
			if moons[i].pos.x ~= initial_state[i].pos.x or moons[i].vel.x ~= initial_state[i].vel.x then
				x_match = false
			end
			if moons[i].pos.y ~= initial_state[i].pos.y or moons[i].vel.y ~= initial_state[i].vel.y then
				y_match = false
			end
			if moons[i].pos.z ~= initial_state[i].pos.z or moons[i].vel.z ~= initial_state[i].vel.z then
				z_match = false
			end
		end

		if x_match and periods.x == 0 then
			periods.x = steps
		end
		if y_match and periods.y == 0 then
			periods.y = steps
		end
		if z_match and periods.z == 0 then
			periods.z = steps
		end
	end

	local result = lcm(lcm(periods.x, periods.y), periods.z)
	return result
end

return M
