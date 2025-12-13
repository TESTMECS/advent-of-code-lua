--- @title: Day 21: Fractal Art ---
local M = {}

local initial = { ".#.", "..#", "###" }

--- @function: Parse a pattern string into a grid
--- @param str string: the pattern string
--- @return table: the grid
local function parse_pattern(str)
	local grid = {}
	for row in str:gmatch("[^/]+") do
		table.insert(grid, row)
	end
	return grid
end

--- @function: Convert a grid to a string
--- @param grid table: the grid
--- @return string: the string
local function to_string(grid)
	return table.concat(grid, "/")
end

--- @function: Rotate a grid
--- @param grid table: the grid
--- @return table: the rotated grid
local function rotate(grid)
	local n = #grid
	local new = {}
	for i = 1, n do
		new[i] = ""
		for j = 1, n do
			new[i] = new[i] .. grid[n - j + 1]:sub(i, i)
		end
	end
	return new
end

local function flip(grid)
	local n = #grid
	local new = {}
	for i = 1, n do
		new[i] = grid[n - i + 1]
	end
	return new
end

local function generate_transforms(grid)
	local transforms = {}
	local current = grid
	for rot = 1, 4 do
		table.insert(transforms, to_string(current))
		table.insert(transforms, to_string(flip(current)))
		current = rotate(current)
	end
	return transforms
end

local function parse_rules(input_str)
	local rules = {}
	for line in input_str:gmatch("[^\n]+") do
		local pat, out = line:match("(.+) => (.+)")
		if pat and out then
			local grid = parse_pattern(pat)
			local outs = parse_pattern(out)
			for _, trans in ipairs(generate_transforms(grid)) do
				rules[trans] = outs
			end
		end
	end
	return rules
end

local function enhance(grid, rules)
	local n = #grid
	local subsize, outsize
	if n % 2 == 0 then
		subsize = 2
		outsize = 3
	else
		subsize = 3
		outsize = 4
	end
	local new_n = n * outsize / subsize
	local new_grid = {}
	for i = 1, new_n do
		new_grid[i] = string.rep(".", new_n)
	end
	local num_subs = n / subsize
	for si = 1, num_subs do
		for sj = 1, num_subs do
			local sub = {}
			for i = 1, subsize do
				local row = ""
				for j = 1, subsize do
					row = row .. grid[(si - 1) * subsize + i]:sub((sj - 1) * subsize + j, (sj - 1) * subsize + j)
				end
				table.insert(sub, row)
			end
			local out = rules[to_string(sub)]
			for i = 1, outsize do
				for j = 1, outsize do
					local ni = (si - 1) * outsize + i
					local nj = (sj - 1) * outsize + j
					local char = out[i]:sub(j, j)
					new_grid[ni] = new_grid[ni]:sub(1, nj - 1) .. char .. new_grid[ni]:sub(nj + 1)
				end
			end
		end
	end
	return new_grid
end

local function count_on(grid)
	local count = 0
	for _, row in ipairs(grid) do
		for c in row:gmatch(".") do
			if c == "#" then
				count = count + 1
			end
		end
	end
	return count
end

--- @description
--- @param input string
--- @return number
function M.part1(input)
	local rules = parse_rules(input)
	local grid = { table.unpack(initial) }
	for i = 1, 5 do
		grid = enhance(grid, rules)
	end
	return count_on(grid)
end

--- @description
--- @param input string
--- @return number
function M.part2(input)
	local rules = parse_rules(input)
	local grid = { table.unpack(initial) }
	for i = 1, 18 do
		grid = enhance(grid, rules)
	end
	return count_on(grid)
end

return M
