--- @title: --- Day 14: Restroom Redoubt ---
local M = {}

--- @description Calculate the safety factor after 100 seconds
--- @param input string the puzzle input
--- @return number the safety factor
function M.part1(input)
	local robots = {}
	for line in input:gmatch("[^\n]+") do
		local px, py, vx, vy = line:match("p=(%d+),(%d+) v=(-?%d+),(-?%d+)")
		table.insert(robots, { tonumber(px), tonumber(py), tonumber(vx), tonumber(vy) })
	end
	local width, height = 101, 103
	for _ = 1, 100 do
		for _, r in ipairs(robots) do
			r[1] = (r[1] + r[3]) % width
			r[2] = (r[2] + r[4]) % height
		end
	end
	local q1, q2, q3, q4 = 0, 0, 0, 0
	local mx, my = width // 2, height // 2
	for _, r in ipairs(robots) do
		local x, y = r[1], r[2]
		if x < mx and y < my then
			q1 = q1 + 1
		elseif x > mx and y < my then
			q2 = q2 + 1
		elseif x < mx and y > my then
			q3 = q3 + 1
		elseif x > mx and y > my then
			q4 = q4 + 1
		end
	end
	return q1 * q2 * q3 * q4
end

--- @description Find the fewest seconds for the Easter egg
--- @param input string the puzzle input
--- @return number the seconds
function M.part2(input)
	local robots = {}
	for line in input:gmatch("[^\n]+") do
		local px, py, vx, vy = line:match("p=(%d+),(%d+) v=(-?%d+),(-?%d+)")
		table.insert(robots, { tonumber(px), tonumber(py), tonumber(vx), tonumber(vy) })
	end
	local width, height = 101, 103
	local seconds = 0
	while true do
		local pos = {}
		local unique = true
		for _, r in ipairs(robots) do
			local x, y = r[1], r[2]
			local key = x .. "," .. y
			if pos[key] then
				unique = false
				break
			end
			pos[key] = true
		end
		if unique then
			return seconds
		end
		for _, r in ipairs(robots) do
			r[1] = (r[1] + r[3]) % width
			r[2] = (r[2] + r[4]) % height
		end
		seconds = seconds + 1
		if seconds > 10000 then
			break
		end -- safety
	end
	return 0
end

return M
