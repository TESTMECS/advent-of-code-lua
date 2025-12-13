--- @title: --- Day 7: The Treachery of Whales ---
local M = {}

--- @description: Calculate the minimum fuel to align crabs to the median position
--- @param input string: the puzzle input
--- @return number: the minimum fuel required
function M.part1(input)
	local positions = {}
	for num in input:gmatch("%d+") do
		table.insert(positions, tonumber(num))
	end
	table.sort(positions)
	local n = #positions
	local median = positions[math.floor(n / 2) + 1]
	local fuel = 0
	for _, p in ipairs(positions) do
		fuel = fuel + math.abs(p - median)
	end
	return fuel
end

--- @description: Calculate the minimum fuel to align crabs with increasing fuel cost
--- @param input string: the puzzle input
--- @return number: the minimum fuel required
function M.part2(input)
	local positions = {}
	local sum = 0
	local n = 0
	for num in input:gmatch("%d+") do
		local p = tonumber(num)
		table.insert(positions, p)
		sum = sum + p
		n = n + 1
	end
	local mean = sum / n
	local target1 = math.floor(mean)
	local target2 = math.ceil(mean)
	local function calc_fuel(target)
		local fuel = 0
		for _, p in ipairs(positions) do
			local d = math.abs(p - target)
			fuel = fuel + d * (d + 1) / 2
		end
		return fuel
	end
	local fuel1 = calc_fuel(target1)
	local fuel2 = calc_fuel(target2)
	return math.min(fuel1, fuel2)
end

return M
