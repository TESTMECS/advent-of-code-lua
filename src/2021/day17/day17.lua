--- @title: Day 17: Title ---
local M = {}

--- @description: Find the maximum height reached by a projectile that hits the target
--- @param input string: the puzzle input
--- @return number: the maximum height
function M.part1(input)
	local min_x, max_x, min_y, max_y = input:match("target area: x=(%-?%d+)..(%-?%d+), y=(%-?%d+)..(%-?%d+)")
	min_x, max_x, min_y, max_y = tonumber(min_x), tonumber(max_x), tonumber(min_y), tonumber(max_y)
	local function simulate(vx, vy)
		local x, y = 0, 0
		local max_y_reached = 0
		while x <= max_x and y >= min_y do
			if x >= min_x and y <= max_y then
				return max_y_reached
			end
			x = x + vx
			y = y + vy
			max_y_reached = math.max(max_y_reached, y)
			if vx > 0 then
				vx = vx - 1
			elseif vx < 0 then
				vx = vx + 1
			end
			vy = vy - 1
		end
		return nil
	end
	local max_height = 0
	for vx = 1, max_x do
		for vy = min_y, 1000 do
			local height = simulate(vx, vy)
			if height then
				max_height = math.max(max_height, height)
			end
		end
	end
	return max_height
end

--- @description: Count the number of initial velocities that hit the target
--- @param input string: the puzzle input
--- @return number: the count of velocities
function M.part2(input)
	local min_x, max_x, min_y, max_y = input:match("target area: x=(%-?%d+)..(%-?%d+), y=(%-?%d+)..(%-?%d+)")
	min_x, max_x, min_y, max_y = tonumber(min_x), tonumber(max_x), tonumber(min_y), tonumber(max_y)
	local function simulate(vx, vy)
		local x, y = 0, 0
		while x <= max_x and y >= min_y do
			if x >= min_x and y <= max_y then
				return true
			end
			x = x + vx
			y = y + vy
			if vx > 0 then
				vx = vx - 1
			elseif vx < 0 then
				vx = vx + 1
			end
			vy = vy - 1
		end
		return false
	end
	local count = 0
	for vx = 0, max_x do
		for vy = min_y, 1000 do
			if simulate(vx, vy) then
				count = count + 1
			end
		end
	end
	return count
end

return M
