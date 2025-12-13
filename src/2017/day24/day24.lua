---@title: Day 24: Electromagnetic Moat ---
local M = {}

--- @function: Parse the components
--- @param input string: the components
--- @return table: the components
local function parse_components(input)
	local components = {}
	for line in input:gmatch("[^\n]+") do
		local a, b = line:match("(%d+)/(%d+)")
		if a and b then
			table.insert(components, { tonumber(a), tonumber(b) })
		end
	end
	return components
end

--- @function: Build a bridge
--- @param components table: the components
--- @param current_port number: the current port
--- @param strength number: the current strength
--- @param length number: the current length
--- @param used table: the used ports
--- @param max_strength table: the max strength
--- @param max_length table: the max length
--- @param max_strength_long table: the max strength of longest
--- @return nil
local function build_bridge(
	components,
	current_port,
	strength,
	length,
	used,
	max_strength,
	max_length,
	max_strength_long
)
	local found = false
	for i, comp in ipairs(components) do
		if not used[i] then
			local a, b = comp[1], comp[2]
			if a == current_port then
				used[i] = true
				build_bridge(
					components,
					b,
					strength + a + b,
					length + 1,
					used,
					max_strength,
					max_length,
					max_strength_long
				)
				used[i] = false
				found = true
			elseif b == current_port then
				used[i] = true
				build_bridge(
					components,
					a,
					strength + a + b,
					length + 1,
					used,
					max_strength,
					max_length,
					max_strength_long
				)
				used[i] = false
				found = true
			end
		end
	end
	if not found then
		if strength > max_strength[1] then
			max_strength[1] = strength
		end
		if length > max_length[1] or (length == max_length[1] and strength > max_strength_long[1]) then
			max_length[1] = length
			max_strength_long[1] = strength
		end
	end
end

--- @description Find the strength of the strongest bridge
--- @param input string the components
--- @return number max strength
function M.part1(input)
	local components = parse_components(input)
	local used = {}
	local max_strength = { 0 }
	local max_length = { 0 }
	local max_strength_long = { 0 }
	build_bridge(components, 0, 0, 0, used, max_strength, max_length, max_strength_long)
	return max_strength[1]
end

--- @description Find the strength of the longest bridge, tie by strength
--- @param input string the components
--- @return number max strength of longest
function M.part2(input)
	local components = parse_components(input)
	local used = {}
	local max_strength = { 0 }
	local max_length = { 0 }
	local max_strength_long = { 0 }
	build_bridge(components, 0, 0, 0, used, max_strength, max_length, max_strength_long)
	return max_strength_long[1]
end

return M
