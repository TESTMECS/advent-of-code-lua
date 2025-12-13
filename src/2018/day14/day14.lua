--- @title: Day 14: Chocolate Charts
local M = {}

--- @description: Simulates the recipe scoreboard and returns the 10 recipes after the given number
--- @param input string: the puzzle input
--- @return string: the 10 recipes
function M.part1(input)
	local n = tonumber(input:match("%d+"))
	local recipes = { 3, 7 }
	local elf1 = 1
	local elf2 = 2
	while #recipes < n + 10 do
		local sum = recipes[elf1] + recipes[elf2]
		if sum >= 10 then
			table.insert(recipes, 1)
			table.insert(recipes, sum - 10)
		else
			table.insert(recipes, sum)
		end
		elf1 = (elf1 + recipes[elf1]) % #recipes + 1
		elf2 = (elf2 + recipes[elf2]) % #recipes + 1
	end
	local result = ""
	for i = n + 1, n + 10 do
		result = result .. recipes[i]
	end
	return result
end

--- @description: Finds the number of recipes before the input sequence appears
--- @param input string: the puzzle input
--- @return number: the number of recipes
function M.part2(input)
	local target = input:match("%d+")
	local target_len = #target
	local recipes = { 3, 7 }
	local elf1 = 1
	local elf2 = 2
	while true do
		local sum = recipes[elf1] + recipes[elf2]
		if sum >= 10 then
			table.insert(recipes, 1)
			table.insert(recipes, sum - 10)
		else
			table.insert(recipes, sum)
		end
		elf1 = (elf1 + recipes[elf1]) % #recipes + 1
		elf2 = (elf2 + recipes[elf2]) % #recipes + 1
		if #recipes >= target_len then
			local last = ""
			for i = #recipes - target_len + 1, #recipes do
				last = last .. recipes[i]
			end
			if last == target then
				return #recipes - target_len
			end
			if #recipes > target_len then
				local prev = ""
				for i = #recipes - target_len, #recipes - 1 do
					prev = prev .. recipes[i]
				end
				if prev == target then
					return #recipes - target_len - 1
				end
			end
		end
	end
end

return M
