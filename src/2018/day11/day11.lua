--- @title: Day 11: Chronal Charge ---
local M = {}

--- @description: Finds the 3x3 square with the highest total power
--- @param input string: the puzzle input (serial number)
--- @return string: the coordinates "x,y"
function M.part1(input)
	local serial = tonumber(input)
	local grid = {}
	for x = 1, 300 do
		grid[x] = {}
		for y = 1, 300 do
			local rack = x + 10
			local power = rack * y + serial
			power = power * rack
			power = math.floor(power / 100) % 10 - 5
			grid[x][y] = power
		end
	end
	local prefix = {}
	for x = 0, 301 do
		prefix[x] = {}
		for y = 0, 301 do
			prefix[x][y] = 0
		end
	end
	for x = 1, 300 do
		for y = 1, 300 do
			prefix[x][y] = grid[x][y] + prefix[x - 1][y] + prefix[x][y - 1] - prefix[x - 1][y - 1]
		end
	end
	local function get_sum(x1, y1, x2, y2)
		return prefix[x2][y2] - prefix[x2][y1 - 1] - prefix[x1 - 1][y2] + prefix[x1 - 1][y1 - 1]
	end
	local max_power = -math.huge
	local best_x, best_y
	for x = 1, 298 do
		for y = 1, 298 do
			local power = get_sum(x, y, x + 2, y + 2)
			if power > max_power then
				max_power = power
				best_x, best_y = x, y
			end
		end
	end
	return best_x .. "," .. best_y
end

--- @description: Finds the square of any size with the highest total power
--- @param input string: the puzzle input (serial number)
--- @return string: the coordinates and size "x,y,size"
function M.part2(input)
	local serial = tonumber(input)
	local grid = {}
	for x = 1, 300 do
		grid[x] = {}
		for y = 1, 300 do
			local rack = x + 10
			local power = rack * y + serial
			power = power * rack
			power = math.floor(power / 100) % 10 - 5
			grid[x][y] = power
		end
	end
	local prefix = {}
	for x = 0, 301 do
		prefix[x] = {}
		for y = 0, 301 do
			prefix[x][y] = 0
		end
	end
	for x = 1, 300 do
		for y = 1, 300 do
			prefix[x][y] = grid[x][y] + prefix[x - 1][y] + prefix[x][y - 1] - prefix[x - 1][y - 1]
		end
	end
	local function get_sum(x1, y1, x2, y2)
		return prefix[x2][y2] - prefix[x2][y1 - 1] - prefix[x1 - 1][y2] + prefix[x1 - 1][y1 - 1]
	end
	local max_power = -math.huge
	local best_x, best_y, best_size
	for s = 1, 300 do
		for x = 1, 301 - s do
			for y = 1, 301 - s do
				local power = get_sum(x, y, x + s - 1, y + s - 1)
				if power > max_power then
					max_power = power
					best_x, best_y, best_size = x, y, s
				end
			end
		end
	end
	return best_x .. "," .. best_y .. "," .. best_size
end

return M
