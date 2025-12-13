--- @title: Day 25: Let It Snow ---
local M = {}
local util = require("util")

--- @description: Day 25: Let It Snow
--- @param input string
--- @return number
function M.part1(input)
	local line = util.read_lines(input)[1]
	local r, c = line:match("row (%d+), column (%d+)")
	r = tonumber(r)
	c = tonumber(c)
	local d = r + c - 1
	local n = (d - 1) * d / 2 + c
	local code = 20151125
	for i = 2, n do
		code = (code * 252533) % 33554393
	end
	return code
end

--- @description: Day 25: Let It Snow
--- @return string
function M.part2(_)
	return "click the button"
end

return M
