--- @title: Day 1: No Time for a Taxicab ---
local M = {}

--- @description: Find the sum of the absolute values of the coordinates of every point you visit.
--- @param input string L or R followed by a number
--- @return integer
function M.part1(input)
	local x, y = 0, 0
	local dir = 0 -- 0=N, 1=E, 2=S, 3=W
	local directions = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }

	for instr in input:gmatch("[RL]%d+") do
		local turn = instr:sub(1, 1)
		local steps = tonumber(instr:sub(2))
		if turn == "R" then
			dir = (dir + 1) % 4
		else
			dir = (dir - 1) % 4
		end
		x = x + directions[dir + 1][1] * steps
		y = y + directions[dir + 1][2] * steps
	end
	return math.abs(x) + math.abs(y)
end

--- @description: Find the first location you visit twice.
--- @param input string L or R followed by a number
--- @return integer the first location you visit twice
function M.part2(input)
	local x, y = 0, 0
	local dir = 0
	local directions = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
	local visited = {}
	visited["0,0"] = true
	local found = false
	local first_x, first_y

	for instr in input:gmatch("[RL]%d+") do
		local turn = instr:sub(1, 1)
		local steps = tonumber(instr:sub(2))
		if turn == "R" then
			dir = (dir + 1) % 4
		else
			dir = (dir - 1) % 4
		end
		for _ = 1, steps do
			x = x + directions[dir + 1][1]
			y = y + directions[dir + 1][2]
			local key = tostring(x) .. "," .. tostring(y)
			if visited[key] then
				if not found then
					first_x, first_y = x, y
					found = true
				end
			else
				visited[key] = true
			end
		end
		if found then
			break
		end
	end
	return math.abs(first_x) + math.abs(first_y)
end

return M
