--- @title: Day 1: The Tyranny of the Rocket Equation ---
local M = {}
local util = require("util")

--- @description: Follow the fuel requirements.
--- @param input string: the puzzle input
--- @return number: the sum
function M.part1(input)
	local sum = 0 --  result sum
	for _, line in ipairs(util.read_lines(input)) do
		local num = tonumber(line)
		if num then
			sum = sum + (math.floor(num / 3) - 2)
		end
	end
	return sum
end

--- @function: calc_fuel
--- @param mass number: the mass
--- @return number: the fuel
local function calc_fuel(mass)
	local fuel = math.floor(mass / 3) - 2
	if fuel <= 0 then
		return 0
	end
	return fuel + calc_fuel(fuel)
end

--- @description: Follow the fuel requirements.
--- @param input string: the puzzle input
--- @return number: the sum
function M.part2(input)
	local sum = 0
	for _, line in ipairs(util.read_lines(input)) do
		local num = tonumber(line)
		if num then
			sum = sum + calc_fuel(num)
		end
	end
	return sum
end

return M
