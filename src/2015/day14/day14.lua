--- @title: Day 14: Reindeer Olympics
local M = {}

--- @function: Parse the reindeer input
--- @param input string
--- @return table
local function parse_reindeer(input)
	local reindeer = {}
	for line in input:gmatch("[^\n]+") do
		local name, speed, fly, rest =
			line:match("(%w+) can fly (%d+) km/s for (%d+) seconds, but then must rest for (%d+) seconds.")
		if name then
			reindeer[name] = { speed = tonumber(speed), fly = tonumber(fly), rest = tonumber(rest) } -- table shape
		end
	end
	return reindeer
end

--- @description: What is the max distance the winning reindeer traveled?
--- @param input string
--- @return number
function M.part1(input)
	local reindeer = parse_reindeer(input)
	local max_dist = 0
	for _, r in pairs(reindeer) do
		local cycle = r.fly + r.rest
		local full_cycles = math.floor(2503 / cycle)
		local dist = full_cycles * r.speed * r.fly
		local remaining = 2503 % cycle
		if remaining > r.fly then
			dist = dist + r.speed * r.fly
		else
			dist = dist + r.speed * remaining
		end
		if dist > max_dist then
			max_dist = dist
		end
	end
	return max_dist
end

--- @description: What is the max points the winning reindeer has?
--- @param input string
--- @return number
function M.part2(input)
	local reindeer = parse_reindeer(input)
	for _, r in pairs(reindeer) do
		r.dist = 0
		r.points = 0
	end
	for t = 1, 2503 do
		for _, r in pairs(reindeer) do
			local cycle = r.fly + r.rest
			local time_in_cycle = ((t - 1) % cycle) + 1
			if time_in_cycle <= r.fly then
				r.dist = r.dist + r.speed
			end
		end
		local max_d = 0
		for _, r in pairs(reindeer) do
			if r.dist > max_d then
				max_d = r.dist
			end
		end
		for _, r in pairs(reindeer) do
			if r.dist == max_d then
				r.points = r.points + 1
			end
		end
	end
	local max_points = 0
	for _, r in pairs(reindeer) do
		if r.points > max_points then
			max_points = r.points
		end
	end
	return max_points
end

return M
