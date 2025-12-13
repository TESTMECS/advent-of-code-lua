--- @title: Day 14: Space Stoichiometry ---
local M = {}

--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
local function parse_input(input)
	local recipes = {}
	for line in input:gmatch("[^\n]+") do
		local inputs_str, output_str = line:match("(.+) => (.+)")
		local output_qty, output_chem = output_str:match("(%d+) (%w+)")
		local inputs = {}
		for qty, chem in inputs_str:gmatch("(%d+) (%w+)") do
			table.insert(inputs, { tonumber(qty), chem })
		end
		recipes[output_chem] = { tonumber(output_qty), inputs }
	end
	return recipes
end

--- @function: Calculates the ore required to produce a given quantity of a given chemical.
--- @param recipes table: The recipes.
--- @param surplus table: The surplus of each chemical.
--- @param chem string: The chemical.
--- @param qty number: The quantity.
--- @return number: The ore required.
local function get_ore(recipes, surplus, chem, qty)
	if chem == "ORE" then
		return qty
	end
	if surplus[chem] and surplus[chem] > 0 then
		local take = math.min(surplus[chem], qty)
		surplus[chem] = surplus[chem] - take
		qty = qty - take
		if qty == 0 then
			return 0
		end
	end
	local recipe = recipes[chem]
	local output_qty = recipe[1]
	local inputs = recipe[2]
	local batches = math.ceil(qty / output_qty)
	local produced = batches * output_qty
	surplus[chem] = (surplus[chem] or 0) + (produced - qty)
	local ore = 0
	for _, input in ipairs(inputs) do
		ore = ore + get_ore(recipes, surplus, input[2], input[1] * batches)
	end
	return ore
end

--- @description Calculate the minimum ORE required to produce 1 FUEL
--- @param input string the puzzle input
--- @return number the ORE required
function M.part1(input)
	local recipes = parse_input(input)
	local surplus = {}
	return get_ore(recipes, surplus, "FUEL", 1)
end

--- @description Find the maximum FUEL that can be produced with 1 trillion ORE
--- @param input string the puzzle input
--- @return number the maximum FUEL
function M.part2(input)
	local recipes = parse_input(input)
	local max_ore = 1000000000000
	local function can_produce(fuel_qty)
		local surplus = {}
		local ore_needed = get_ore(recipes, surplus, "FUEL", fuel_qty)
		return ore_needed <= max_ore
	end
	local low = 1
	local high = 1000000000000
	while low <= high do
		local mid = math.floor((low + high) / 2)
		if can_produce(mid) then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	return high
end

return M
