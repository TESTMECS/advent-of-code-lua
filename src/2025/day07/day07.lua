local util = require("src.util")
local M = {}
function M.part1(input)
	local rows = {}
	for _, line in ipairs(util.read_lines(input)) do
		local row = {}
		for i = 1, #line do
			row[i] = line:sub(i, i)
		end
		table.insert(rows, row)
	end
	local function add(r, c, v)
		if rows[r][c] == "." then
			rows[r][c] = 0
		end
		rows[r][c] = rows[r][c] + v
	end
	local splits = 0
	for r = 1, #rows - 1 do
		for c = 1, #rows[r] do
			if rows[r][c] == "S" then
				rows[r + 1][c] = 1
			elseif type(rows[r][c]) == "number" then
				local n = rows[r][c]
				if rows[r + 1][c] == "^" then
					splits = splits + 1
					add(r + 1, c - 1, n)
					add(r + 1, c + 1, n)
				else
					add(r + 1, c, n)
				end
			end
		end
	end
	local sum = 0
	for _, v in ipairs(rows[#rows]) do
		if type(v) == "number" then
			sum = sum + v
		end
	end
	print("Num Splits | Sum:")
	return splits, sum
end

function M.part2(_)
	return "See P1"
end

return M
