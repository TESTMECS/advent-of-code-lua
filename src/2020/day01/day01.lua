--- @title: Day 1: Report Repair ---
local M = {}

--- @description Find two numbers that sum to 2020 and return their product
--- @param input string the puzzle input
--- @return number the product of the two numbers
function M.part1(input)
	local numbers = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(numbers, tonumber(line))
	end
	local seen = {}
	for _, num in ipairs(numbers) do
		local complement = 2020 - num
		if seen[complement] then
			return num * complement
		end
		seen[num] = true
	end
	return 0
end

--- @description Find three numbers that sum to 2020 and return their product
--- @param input string the puzzle input
--- @return number the product of the three numbers
function M.part2(input)
	local numbers = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(numbers, tonumber(line))
	end
	for i = 1, #numbers - 2 do
		for j = i + 1, #numbers - 1 do
			for k = j + 1, #numbers do
				if numbers[i] + numbers[j] + numbers[k] == 2020 then
					return numbers[i] * numbers[j] * numbers[k]
				end
			end
		end
	end
	return 0
end

return M
