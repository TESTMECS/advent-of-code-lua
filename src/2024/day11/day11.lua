--- @title: --- Day 11: Plutonian Pebbles ---
local M = {}

--- @description Count stones after 25 blinks
--- @param input string the puzzle input
--- @return number the count of stones
function M.part1(input)
	local stones = {}
	for num in input:gmatch("%d+") do
		table.insert(stones, tonumber(num))
	end
	for _ = 1, 25 do
		local new_stones = {}
		for _, stone in ipairs(stones) do
			if stone == 0 then
				table.insert(new_stones, 1)
			else
				local s = tostring(stone)
				if #s % 2 == 0 then
					local mid = #s / 2
					table.insert(new_stones, tonumber(s:sub(1, mid)))
					table.insert(new_stones, tonumber(s:sub(mid + 1)))
				else
					table.insert(new_stones, stone * 2024)
				end
			end
		end
		stones = new_stones
	end
	return #stones
end

--- @description Count stones after 75 blinks
--- @param input string the puzzle input
--- @return number the count of stones
function M.part2(input)
	local memo = {}
	local function count(stone, blinks)
		if blinks == 0 then
			return 1
		end
		local key = stone .. "," .. blinks
		if memo[key] then
			return memo[key]
		end
		local res
		if stone == 0 then
			res = count(1, blinks - 1)
		else
			local s = tostring(stone)
			if #s % 2 == 0 then
				local mid = #s / 2
				local a = tonumber(s:sub(1, mid))
				local b = tonumber(s:sub(mid + 1))
				res = count(a, blinks - 1) + count(b, blinks - 1)
			else
				res = count(stone * 2024, blinks - 1)
			end
		end
		memo[key] = res
		return res
	end
	local total = 0
	for num in input:gmatch("%d+") do
		total = total + count(tonumber(num), 75)
	end
	return total
end

return M
