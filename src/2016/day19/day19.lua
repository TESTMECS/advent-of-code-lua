--- @title: Day 19: An Elephant Named Joseph ---
local M = {}

--- @description: Solves the Josephus problem variant where each elf steals from the one to their left.
--- @param input string: The number of elves.
--- @return number: The number of the winning elf.
function M.part1(input)
	local num_elves = tonumber(input)

	-- This is a known mathematical solution to this variant of the Josephus problem.
	-- The formula is W(n) = 2*l + 1, where n = 2^k + l and 2^k is the largest
	-- power of 2 less than or equal to n.
	local highest_power_of_2 = 1
	while highest_power_of_2 * 2 <= num_elves do
		highest_power_of_2 = highest_power_of_2 * 2
	end

	local l = num_elves - highest_power_of_2
	return 2 * l + 1
end

--- @description: Solves the Josephus problem variant where each elf steals from the one across the circle.
--- @param input string: The number of elves.
--- @return number|nil: The number of the winning elf.
function M.part2(input)
	local num_elves = tonumber(input)

	-- This solution is derived from observing the pattern of winners for n elves.
	-- The pattern is based on the largest power of 3 less than or equal to n.
	local highest_power_of_3 = 1
	while highest_power_of_3 * 3 <= num_elves do
		highest_power_of_3 = highest_power_of_3 * 3
	end

	if num_elves == highest_power_of_3 then
		return num_elves
	end

	if num_elves <= 2 * highest_power_of_3 then
		return num_elves - highest_power_of_3
	else
		return highest_power_of_3 + 2 * (num_elves - 2 * highest_power_of_3)
	end
end

return M
