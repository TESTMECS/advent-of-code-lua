--- @title: Day 22: Reactor Reboot ---

--- @function: Parse the input into a list of instructions
--- @param input string: the puzzle input
--- @return table: the list of instructions
local function parse_input(input)
	local instructions = {}
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("\r", "")
		line = line:gsub("^\xef\xbb\xbf", "")
		local state
		if line:match("^on") then
			state = "on"
		elseif line:match("^off") then
			state = "off"
		end
		if state then
			local x1, x2, y1, y2, z1, z2 =
				line:match(state .. " x=(-?%d+)%.%.(-?%d+),y=(-?%d+)%.%.(-?%d+),z=(-?%d+)%.%.(-?%d+)")
			if x1 then
				table.insert(instructions, {
					state = state,
					x1 = tonumber(x1),
					x2 = tonumber(x2),
					y1 = tonumber(y1),
					y2 = tonumber(y2),
					z1 = tonumber(z1),
					z2 = tonumber(z2),
				})
			end
		end
	end
	return instructions
end

--- @description: Count the number of on cubes
--- @param input string: the puzzle input
--- @return number: the number of on cubes
local function part1(input)
	local instructions = parse_input(input)
	local on_cubes = {}
	local min_coord = -50
	local max_coord = 50

	for _, inst in ipairs(instructions) do
		local x1 = math.max(inst.x1, min_coord)
		local x2 = math.min(inst.x2, max_coord)
		local y1 = math.max(inst.y1, min_coord)
		local y2 = math.min(inst.y2, max_coord)
		local z1 = math.max(inst.z1, min_coord)
		local z2 = math.min(inst.z2, max_coord)

		if x1 <= x2 and y1 <= y2 and z1 <= z2 then
			for x = x1, x2 do
				for y = y1, y2 do
					for z = z1, z2 do
						local key = string.format("%d_%d_%d", x, y, z)
						if inst.state == "on" then
							on_cubes[key] = true
						else
							on_cubes[key] = nil
						end
					end
				end
			end
		end
	end

	local count = 0
	for _ in pairs(on_cubes) do
		count = count + 1
	end
	return count
end

--- @function: Calculate the intersection of two cubes
--- @param a table: the first cube
--- @param b table: the second cube
--- @return table: the intersection of the two cubes, or nil if there is no intersection
local function intersect(a, b)
	local x1 = math.max(a.x1, b.x1)
	local x2 = math.min(a.x2, b.x2)
	local y1 = math.max(a.y1, b.y1)
	local y2 = math.min(a.y2, b.y2)
	local z1 = math.max(a.z1, b.z1)
	local z2 = math.min(a.z2, b.z2)
	if x1 <= x2 and y1 <= y2 and z1 <= z2 then
		return { x1 = x1, x2 = x2, y1 = y1, y2 = y2, z1 = z1, z2 = z2 }
	end
	return nil
end

--- @function: Subtract the second cube from the first cube
--- @param a table: the first cube
--- @param b table: the second cube
--- @return table: the list of cubes that remain after subtracting the second cube from the first cube
local function subtract(a, b)
	local inter = intersect(a, b)
	if not inter then
		return { a }
	end
	local result = {}
	-- left
	if a.x1 < inter.x1 then
		table.insert(result, { x1 = a.x1, x2 = inter.x1 - 1, y1 = a.y1, y2 = a.y2, z1 = a.z1, z2 = a.z2 })
	end
	-- right
	if inter.x2 < a.x2 then
		table.insert(result, { x1 = inter.x2 + 1, x2 = a.x2, y1 = a.y1, y2 = a.y2, z1 = a.z1, z2 = a.z2 })
	end
	-- bottom
	if a.y1 < inter.y1 then
		table.insert(result, { x1 = inter.x1, x2 = inter.x2, y1 = a.y1, y2 = inter.y1 - 1, z1 = a.z1, z2 = a.z2 })
	end
	-- top
	if inter.y2 < a.y2 then
		table.insert(result, { x1 = inter.x1, x2 = inter.x2, y1 = inter.y2 + 1, y2 = a.y2, z1 = a.z1, z2 = a.z2 })
	end
	-- front
	if a.z1 < inter.z1 then
		table.insert(
			result,
			{ x1 = inter.x1, x2 = inter.x2, y1 = inter.y1, y2 = inter.y2, z1 = a.z1, z2 = inter.z1 - 1 }
		)
	end
	-- back
	if inter.z2 < a.z2 then
		table.insert(
			result,
			{ x1 = inter.x1, x2 = inter.x2, y1 = inter.y1, y2 = inter.y2, z1 = inter.z2 + 1, z2 = a.z2 }
		)
	end
	return result
end

--- @function: Calculate the volume of a cube
--- @param c table: the cube
--- @return number: the volume of the cube
local function volume(c)
	return (c.x2 - c.x1 + 1) * (c.y2 - c.y1 + 1) * (c.z2 - c.z1 + 1)
end

--- @description: Count the number of on cubes
--- @param input string: the puzzle input
--- @return number: the number of on cubes
local function part2(input)
	local instructions = parse_input(input)
	local on_cuboids = {}
	for _, inst in ipairs(instructions) do
		local cuboid = { x1 = inst.x1, x2 = inst.x2, y1 = inst.y1, y2 = inst.y2, z1 = inst.z1, z2 = inst.z2 }
		if inst.state == "on" then
			-- add the new cuboid minus existing on cuboids
			local new_parts = { cuboid }
			for _, existing in ipairs(on_cuboids) do
				local temp = {}
				for _, part in ipairs(new_parts) do
					local sub = subtract(part, existing)
					for _, s in ipairs(sub) do
						table.insert(temp, s)
					end
				end
				new_parts = temp
			end
			-- add new_parts to on_cuboids
			for _, p in ipairs(new_parts) do
				table.insert(on_cuboids, p)
			end
		else -- off
			-- subtract cuboid from existing on_cuboids
			local new_on = {}
			for _, existing in ipairs(on_cuboids) do
				local sub = subtract(existing, cuboid)
				for _, s in ipairs(sub) do
					table.insert(new_on, s)
				end
			end
			on_cuboids = new_on
		end
	end
	-- calculate total volume
	local total = 0
	for _, c in ipairs(on_cuboids) do
		total = total + volume(c)
	end
	return total
end

return {
	part1 = part1,
	part2 = part2,
}
