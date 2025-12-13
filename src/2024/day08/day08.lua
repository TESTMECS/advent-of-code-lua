--- @title: --- Day 8: Resonant Collinearity ---
local M = {}
local util = require("util")

--- @description Count unique antinode positions
--- @param input string the puzzle input
--- @return number the count of unique antinodes
function M.part1(input)
	local grid = {}
	local row = 1
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			grid[row][col] = line:sub(col, col)
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local antennas = {}
	for i = 1, rows do
		for j = 1, cols do
			local c = grid[i][j]
			if c ~= "." then
				antennas[c] = antennas[c] or {}
				table.insert(antennas[c], { i, j })
			end
		end
	end
	local antinodes = {}
	for _, positions in pairs(antennas) do
		for i = 1, #positions do
			for j = i + 1, #positions do
				local x1, y1 = positions[i][1], positions[i][2]
				local x2, y2 = positions[j][1], positions[j][2]
				local ax, ay = 2 * x2 - x1, 2 * y2 - y1
				if ax >= 1 and ax <= rows and ay >= 1 and ay <= cols then
					antinodes[ax .. "," .. ay] = true
				end
				local bx, by = 2 * x1 - x2, 2 * y1 - y2
				if bx >= 1 and bx <= rows and by >= 1 and by <= cols then
					antinodes[bx .. "," .. by] = true
				end
			end
		end
	end
	local count = 0
	for _ in pairs(antinodes) do
		count = count + 1
	end
	return count
end

--- @description Count unique antinode positions with harmonics
--- @param input string the puzzle input
--- @return number the count of unique antinodes
function M.part2(input)
	local function find_nodes(map)
		local freq2coords = {}
		for r, _ in ipairs(map) do
			for c, _ in ipairs(map[r]) do
				local freq = map[r][c]
				if map[r][c] ~= "." then
					if not freq2coords[freq] then
						freq2coords[freq] = {}
					end
					table.insert(freq2coords[freq], { row = r, col = c })
				end
			end
		end
		return freq2coords
	end
	local function find_anti(nodes, max_r, max_c)
		local antinodes = {}
		for i in ipairs(nodes) do
			for j in ipairs(nodes) do
				if i == j then
					goto continue
				end
				local left, right = nodes[i], nodes[j]

				local r_diff = right.row - left.row
				local c_diff = right.col - left.col

				local anti_r = right.row
				local anti_c = right.col

				while anti_r <= max_r and anti_r >= 1 and anti_c <= max_c and anti_c >= 1 do
					table.insert(antinodes, { row = anti_r, col = anti_c })
					anti_r = anti_r + r_diff
					anti_c = anti_c + c_diff
				end
				::continue::
			end
		end
		return antinodes
	end
	do
		local map = {}
		local r = 1
		for _, line in ipairs(util.read_lines(input)) do
			local row = {}
			for c = 1, #line do
				local ch = string.sub(line, c, c)
				table.insert(row, ch)
			end
			table.insert(map, row)
			r = r + 1
		end
		local freq2coords = find_nodes(map)
		local anti_set = {}
		for _, nodes in pairs(freq2coords) do
			local antinodes = find_anti(nodes, #map, #map[1])
			for _, anti in pairs(antinodes) do
				local key = anti.row .. "|" .. anti.col
				anti_set[key] = true
			end
		end
		local count = 0
		for _, _ in pairs(anti_set) do
			count = count + 1
		end
		return count
	end
end

return M
