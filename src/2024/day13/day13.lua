--- @title: Day 13: Claw Contraption
local M = {}

--- @description Calculate the minimum tokens to win all prizes
--- @param input string the puzzle input
--- @return number the total tokens
function M.part1(input)
	local total = 0
	for block in input:gmatch("([^\n]+\n[^\n]+\n[^\n]+\n)") do
		local a, b, c, d, e, f =
			block:match("Button A: X%+(%d+), Y%+(%d+)\nButton B: X%+(%d+), Y%+(%d+)\nPrize: X=(%d+), Y=(%d+)")
		a, b, c, d, e, f = tonumber(a), tonumber(b), tonumber(c), tonumber(d), tonumber(e), tonumber(f)
		local det = a * d - b * c
		if det ~= 0 then
			local p = (e * d - f * c) / det
			local q = (a * f - b * e) / det
			if p == math.floor(p) and q == math.floor(q) and p >= 0 and q >= 0 then
				total = total + 3 * p + q
			end
		end
	end
	return total
end

--- @description Calculate the minimum tokens with corrected prizes
--- @param input string the puzzle input
--- @return number the total tokens
function M.part2(input)
	local total = 0
	for block in input:gmatch("([^\n]+\n[^\n]+\n[^\n]+\n)") do
		local a, b, c, d, e, f =
			block:match("Button A: X%+(%d+), Y%+(%d+)\nButton B: X%+(%d+), Y%+(%d+)\nPrize: X=(%d+), Y=(%d+)")
		a, b, c, d, e, f = tonumber(a), tonumber(b), tonumber(c), tonumber(d), tonumber(e), tonumber(f)
		e = e + 10000000000000
		f = f + 10000000000000
		local det = a * d - b * c
		if det ~= 0 then
			local p = (e * d - f * c) / det
			local q = (a * f - b * e) / det
			if p == math.floor(p) and q == math.floor(q) and p >= 0 and q >= 0 then
				total = total + 3 * p + q
			end
		end
	end
	return total
end

return M
