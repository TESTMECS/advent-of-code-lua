--- @title: --- Day 3: Rucksack Reorganization ---
local M = {}

--- @function: as given in the problem statement
--- @param c string: a character
--- @return number: the priority of the character
local function priority(c)
	if c >= "a" and c <= "z" then
		return string.byte(c) - string.byte("a") + 1
	else
		return string.byte(c) - string.byte("A") + 27
	end
end

--- @description: Find the sum of priorities of items that appear in both compartments of each rucksack
--- @param input string:
--- @return number: the sum of priorities
function M.part1(input)
	local total = 0
	for line in input:gmatch("[^\n]+") do
		local len = #line
		local half = len // 2
		local comp1 = line:sub(1, half)
		local comp2 = line:sub(half + 1)
		-- Create a set to store the characters in the first compartment.
		local set1 = {}
		for i = 1, #comp1 do
			set1[comp1:sub(i, i)] = true
		end
		for i = 1, #comp2 do
			local c = comp2:sub(i, i)
			if set1[c] then
				total = total + priority(c)
				break
			end
		end
	end
	return total
end

--- @description: Find the sum of priorities of badges (common items) in groups of three elves
--- @param input string the puzzle input
--- @return number: the sum of priorities
function M.part2(input)
	local total = 0
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	for i = 1, #lines, 3 do
		local set1 = {}
		for j = 1, #lines[i] do
			set1[lines[i]:sub(j, j)] = true
		end
		local set2 = {}
		for j = 1, #lines[i + 1] do
			local c = lines[i + 1]:sub(j, j)
			if set1[c] then
				set2[c] = true
			end
		end
		for j = 1, #lines[i + 2] do
			local c = lines[i + 2]:sub(j, j)
			if set2[c] then
				total = total + priority(c)
				break
			end
		end
	end
	return total
end

return M
