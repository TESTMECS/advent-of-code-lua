--- @title: Day 12: Subterranean Sustainability ---
local M = {}
local util = require("util")

--- @description: Solves the puzzle for a given number of generations using a set-based simulation.
--- @param input string: The puzzle input.
--- @param generations number: The number of generations to simulate.
--- @return number: The sum of the numbers of all pots containing plants.
local function solve(input, generations)
	local lines = util.read_lines(input)

	-- Initial state
	local initial_state_str = lines[1]:match("initial state: (.*)")
	local plants = {}
	for i = 1, #initial_state_str do
		if initial_state_str:sub(i, i) == "#" then
			plants[i - 1] = true
		end
	end

	-- Rules
	local rules = {}
	for i = 2, #lines do
		local pattern, result = lines[i]:match("^(.....) => (.)$")
		if pattern and result then
			rules[pattern] = (result == "#")
		end
	end

	local last_sum = 0
	local stable_diff = nil
	local stable_count = 0

	for gen = 1, generations do
		local next_plants = {}
		local min_pot, max_pot = math.huge, -math.huge
		for pot in pairs(plants) do
			if pot < min_pot then
				min_pot = pot
			end
			if pot > max_pot then
				max_pot = pot
			end
		end

		if min_pot == math.huge then
			return 0
		end

		for i = min_pot - 2, max_pot + 2 do
			local pattern = {}
			for k = -2, 2 do
				table.insert(pattern, plants[i + k] and "#" or ".")
			end
			pattern = table.concat(pattern)
			if rules[pattern] then
				next_plants[i] = true
			end
		end

		plants = next_plants

		-- sum pots
		local current_sum = 0
		for pot in pairs(plants) do
			current_sum = current_sum + pot
		end

		-- detect stabilization
		local diff = current_sum - last_sum
		if stable_diff ~= nil and diff == stable_diff then
			stable_count = stable_count + 1
			if stable_count > 5 then
				local remaining = generations - gen
				return current_sum + remaining * diff
			end
		else
			stable_diff = diff
			stable_count = 1
		end

		last_sum = current_sum
	end

	local total_sum = 0
	for pot in pairs(plants) do
		total_sum = total_sum + pot
	end
	return total_sum
end

--- @description: Simulates 20 generations and sums the pot numbers with plants.
--- @param input string: the puzzle input
--- @return number: the sum
function M.part1(input)
	return solve(input, 20)
end

--- @description: Simulates 50 billion generations and sums the pot numbers with plants.
--- @param input string: the puzzle input
--- @return number: the sum
function M.part2(input)
	return solve(input, 50000000000)
end

return M
