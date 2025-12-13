--- @title: --- Day 5: Hydrothermal Venture ---
local M = {}

--- @description: Count points where at least two horizontal or vertical lines overlap
--- @param input string: the puzzle input
--- @return number: the number of overlapping points
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		local x1, y1, x2, y2 = line:match("(%d+),(%d+) *-> *(%d+),(%d+)")
		table.insert(lines, { x1 = tonumber(x1), y1 = tonumber(y1), x2 = tonumber(x2), y2 = tonumber(y2) })
	end
	local grid = {}
	for i = 0, 999 do
		grid[i] = {}
		for j = 0, 999 do
			grid[i][j] = 0
		end
	end
	for _, ln in ipairs(lines) do
		if ln.x1 == ln.x2 then
			local y1, y2 = math.min(ln.y1, ln.y2), math.max(ln.y1, ln.y2)
			for y = y1, y2 do
				grid[ln.x1][y] = grid[ln.x1][y] + 1
			end
		elseif ln.y1 == ln.y2 then
			local x1, x2 = math.min(ln.x1, ln.x2), math.max(ln.x1, ln.x2)
			for x = x1, x2 do
				grid[x][ln.y1] = grid[x][ln.y1] + 1
			end
		end
	end
	local count = 0
	for i = 0, 999 do
		for j = 0, 999 do
			if grid[i][j] >= 2 then
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Count points where at least two lines overlap, including diagonals
--- @param input string: the puzzle input
--- @return number: the number of overlapping points
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		local x1, y1, x2, y2 = line:match("(%d+),(%d+) *-> *(%d+),(%d+)")
		table.insert(lines, { x1 = tonumber(x1), y1 = tonumber(y1), x2 = tonumber(x2), y2 = tonumber(y2) })
	end
	local grid = {}
	for i = 0, 999 do
		grid[i] = {}
		for j = 0, 999 do
			grid[i][j] = 0
		end
	end
	for _, ln in ipairs(lines) do
		if ln.x1 == ln.x2 then
			local y1, y2 = math.min(ln.y1, ln.y2), math.max(ln.y1, ln.y2)
			for y = y1, y2 do
				grid[ln.x1][y] = grid[ln.x1][y] + 1
			end
		elseif ln.y1 == ln.y2 then
			local x1, x2 = math.min(ln.x1, ln.x2), math.max(ln.x1, ln.x2)
			for x = x1, x2 do
				grid[x][ln.y1] = grid[x][ln.y1] + 1
			end
		else
			-- diagonal
			local dx = ln.x2 > ln.x1 and 1 or ln.x2 < ln.x1 and -1 or 0
			local dy = ln.y2 > ln.y1 and 1 or ln.y2 < ln.y1 and -1 or 0
			local x, y = ln.x1, ln.y1
			while true do
				grid[x][y] = grid[x][y] + 1
				if x == ln.x2 and y == ln.y2 then
					break
				end
				x = x + dx
				y = y + dy
			end
		end
	end
	local count = 0
	for i = 0, 999 do
		for j = 0, 999 do
			if grid[i][j] >= 2 then
				count = count + 1
			end
		end
	end
	return count
end

return M
