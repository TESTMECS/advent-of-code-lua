--- @title Day 3: No M
--- @description: text
local M = {}

--- @description Houses that recieve at least one present
--- @param input string
--- @return integer
function M.part1(input)
	local visited = {}
	local x, y = 0, 0
	visited[x .. "," .. y] = true
	for i = 1, #input do
		local dir = input:sub(i, i)
		if dir == "^" then
			y = y + 1
		elseif dir == "v" then
			y = y - 1
		elseif dir == ">" then
			x = x + 1
		elseif dir == "<" then
			x = x - 1
		end
		visited[x .. "," .. y] = true
	end
	local count = 0
	for _ in pairs(visited) do
		count = count + 1
	end
	return count
end

--- @description Houses that recieve at least one present
--- @param input string
--- @return integer
function M.part2(input)
	local visited = {}
	local santa = { x = 0, y = 0 }
	local robo = { x = 0, y = 0 }
	visited["0,0"] = true
	for i = 1, #input do
		local dir = input:sub(i, i)
		local current = (i % 2 == 1) and santa or robo
		if dir == "^" then
			current.y = current.y + 1
		elseif dir == "v" then
			current.y = current.y - 1
		elseif dir == ">" then
			current.x = current.x + 1
		elseif dir == "<" then
			current.x = current.x - 1
		end
		visited[current.x .. "," .. current.y] = true
	end
	local count = 0
	for _ in pairs(visited) do
		count = count + 1
	end
	return count
end

return M
