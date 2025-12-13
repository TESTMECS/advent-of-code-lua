--- @title: Day 22: Sporifica Virus ---
local M = {}

--- @function: Parse the input
--- @param input string: the input
--- @return table: infected nodes
--- @return number: size of the grid
local function parse_input(input)
	local grid = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(grid, line)
	end
	local size = #grid
	local infected = {}
	for y = 1, size do
		for x = 1, size do
			if grid[y]:sub(x, x) == "#" then
				infected[(x - 1) .. "," .. (y - 1)] = true
			end
		end
	end
	return infected, size
end

--- @description: Simulate 10000 bursts and count infections
--- @param input string: the map
--- @return number: count of infections
function M.part1(input)
	local infected, size = parse_input(input)
	local x, y = math.floor(size / 2), math.floor(size / 2)
	local dir = 0 -- 0 up, 1 right, 2 down, 3 left
	local dx = { 0, 1, 0, -1 }
	local dy = { -1, 0, 1, 0 }
	local count = 0
	for _ = 1, 10000 do
		local key = x .. "," .. y
		if infected[key] then
			dir = (dir + 1) % 4
			infected[key] = nil
		else
			dir = (dir - 1) % 4
			infected[key] = true
			count = count + 1
		end
		x = x + dx[dir + 1]
		y = y + dy[dir + 1]
	end
	return count
end

--- @description: Simulate 10000000 bursts with evolved rules
--- @param input string: the map
--- @return number: count of infections
function M.part2(input)
	local infected, size = parse_input(input)
	local states = {}
	for k in pairs(infected) do
		states[k] = 2 -- infected
	end
	local x, y = math.floor(size / 2), math.floor(size / 2)
	local dir = 0
	local dx = { 0, 1, 0, -1 }
	local dy = { -1, 0, 1, 0 }
	local count = 0
	for _ = 1, 10000000 do
		local key = x .. "," .. y
		local state = states[key] or 0
		if state == 0 then -- clean
			dir = (dir - 1) % 4
			states[key] = 1
		elseif state == 1 then -- weakened
			states[key] = 2
			count = count + 1
		elseif state == 2 then -- infected
			dir = (dir + 1) % 4
			states[key] = 3
		elseif state == 3 then -- flagged
			dir = (dir + 2) % 4
			states[key] = 0
		end
		x = x + dx[dir + 1]
		y = y + dy[dir + 1]
	end
	return count
end

return M
