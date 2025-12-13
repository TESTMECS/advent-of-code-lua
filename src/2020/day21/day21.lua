--- @title: Day 21: Allergen Assessment ---
local M = {}
local util = require("util")

--- @description: Count safe ingredients
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local lines = util.read_lines(input)
	local possible = {}
	local all_ingredients = {}
	local ingredient_count = {}
	for _, line in ipairs(lines) do
		local ing_str, all_str = line:match("(.-) %(contains (.+)%)")
		local ingredients = {}
		for ing in ing_str:gmatch("%w+") do
			ingredients[ing] = true
			all_ingredients[ing] = true
			ingredient_count[ing] = (ingredient_count[ing] or 0) + 1
		end
		local allergens = {}
		for all in all_str:gmatch("%w+") do
			allergens[all] = true
		end
		for allergen in pairs(allergens) do
			if not possible[allergen] then
				possible[allergen] = {}
				for ing in pairs(ingredients) do
					possible[allergen][ing] = true
				end
			else
				for ing in pairs(possible[allergen]) do
					if not ingredients[ing] then
						possible[allergen][ing] = nil
					end
				end
			end
		end
	end
	local safe = {}
	for ing in pairs(all_ingredients) do
		local is_safe = true
		for _, poss in pairs(possible) do
			if poss[ing] then
				is_safe = false
				break
			end
		end
		if is_safe then
			safe[ing] = true
		end
	end
	local count = 0
	for ing in pairs(safe) do
		count = count + ingredient_count[ing]
	end
	return count
end

--- @description: List dangerous ingredients
--- @param input string: the puzzle input
--- @return string: the list
function M.part2(input)
	local lines = util.read_lines(input)
	local possible = {}
	for _, line in ipairs(lines) do
		local ing_str, all_str = line:match("(.-) %(contains (.+)%)")
		local ingredients = {}
		for ing in ing_str:gmatch("%w+") do
			ingredients[ing] = true
		end
		local allergens = {}
		for all in all_str:gmatch("%w+") do
			allergens[all] = true
		end
		for allergen in pairs(allergens) do
			if not possible[allergen] then
				possible[allergen] = {}
				for ing in pairs(ingredients) do
					possible[allergen][ing] = true
				end
			else
				for ing in pairs(possible[allergen]) do
					if not ingredients[ing] then
						possible[allergen][ing] = nil
					end
				end
			end
		end
	end
	local assigned = {}
	local mapping = {}
	while true do
		local found = false
		for allergen, poss in pairs(possible) do
			local count = 0
			local ing
			for i in pairs(poss) do
				count = count + 1
				ing = i
			end
			if count == 1 and not assigned[ing] then
				assigned[ing] = true
				mapping[allergen] = ing
				found = true
				for _, p in pairs(possible) do
					p[ing] = nil
				end
			end
		end
		if not found then
			break
		end
	end
	local allergens = {}
	for all in pairs(mapping) do
		table.insert(allergens, all)
	end
	table.sort(allergens)
	local result = {}
	for _, all in ipairs(allergens) do
		table.insert(result, mapping[all])
	end
	return table.concat(result, ",")
end

return M
