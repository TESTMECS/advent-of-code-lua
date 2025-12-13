-- @title: Day 9: Rope Bridge
-- Simulate rope with head and tail(s) following moves.
local M = {}

local function simulate(input, num_knots)
	local moves = {}
	for line in input:gmatch("[^\n]+") do
		local dir, steps = line:match("(%u) (%d+)")
		if dir then
			table.insert(moves, { dir, tonumber(steps) })
		end
	end
	local knots = {}
	for i = 1, num_knots do
		knots[i] = { 0, 0 }
	end
	local visited = {}
	visited["0,0"] = true
	local count = 1
	for _, move in ipairs(moves) do
		local dir, steps = table.unpack(move)
		for _ = 1, steps do
			-- move head
			if dir == "U" then
				knots[1][2] = knots[1][2] + 1
			elseif dir == "D" then
				knots[1][2] = knots[1][2] - 1
			elseif dir == "L" then
				knots[1][1] = knots[1][1] - 1
			elseif dir == "R" then
				knots[1][1] = knots[1][1] + 1
			end
			-- move tails
			for i = 2, num_knots do
				local dx = knots[i - 1][1] - knots[i][1]
				local dy = knots[i - 1][2] - knots[i][2]
				if math.abs(dx) > 1 or math.abs(dy) > 1 then
					if dx > 0 then
						knots[i][1] = knots[i][1] + 1
					elseif dx < 0 then
						knots[i][1] = knots[i][1] - 1
					end
					if dy > 0 then
						knots[i][2] = knots[i][2] + 1
					elseif dy < 0 then
						knots[i][2] = knots[i][2] - 1
					end
				end
			end
			-- record tail
			local tail = knots[num_knots]
			local key = tail[1] .. "," .. tail[2]
			if not visited[key] then
				visited[key] = true
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Count positions visited by tail with 2 knots
--- @param input string the puzzle input
--- @return number: the count
function M.part1(input)
	return simulate(input, 2)
end

--- @description: Count positions visited by tail with 10 knots
--- @param input string the puzzle input
--- @return number: the count
function M.part2(input)
	return simulate(input, 10)
end

return M
