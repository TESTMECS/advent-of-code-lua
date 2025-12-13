--- @title Day 2: I Was Told There Would Be No Math ---
--- @description: Read the input file line by line. Parse the line into dimensions. Calculate the surface area and perimeter of the box using the given formula. Add the surface area and perimeter to the total. Return the total
local M = {}
local util = require("util")

--- @description: Formula is 2(lw + wh + hl)
--- @param input string
--- @return number
function M.part1(input)
	local total = 0
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local dims = util.parse_nums(line)
		local l, w, h = dims[1], dims[2], dims[3]
		local sides = { l * w, w * h, h * l }
		local surface = 2 * (l * w + w * h + h * l)
		local min_side = util.min(sides)
		total = total + surface + min_side
	end
	return total
end

--- @description: Formula is min(2(lw + wh + hl), 2(lw + wh + hl))
--- @param input string
--- @return number
function M.part2(input)
	local total = 0
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local dims = util.parse_nums(line)
		local l, w, h = dims[1], dims[2], dims[3]
		local perimeters = { 2 * (l + w), 2 * (w + h), 2 * (h + l) }
		local min_perim = util.min(perimeters) -- min perimeter
		local volume = l * w * h
		total = total + min_perim + volume
	end
	return total
end

return M
