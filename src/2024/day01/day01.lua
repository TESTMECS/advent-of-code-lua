--- @title: --- Day 1: Historian Hysteria ---
local M = {}

--- @description Calculate the total distance between the two lists after sorting
--- @param input string the puzzle input
--- @return number the total distance
function M.part1(input)
	local left = {}
	local right = {}
	for line in input:gmatch("[^\n]+") do
		local a, b = line:match("(%d+)%s+(%d+)")
		table.insert(left, tonumber(a))
		table.insert(right, tonumber(b))
	end
	table.sort(left)
	table.sort(right)
	local sum = 0
	for i = 1, #left do
		sum = sum + math.abs(left[i] - right[i])
	end
	return sum
end

--- @description Calculate the similarity score by multiplying each left number by its count in the right list
--- @param input string the puzzle input
--- @return number the similarity score
function M.part2(input)
	local left = {}
	local right = {}
	for line in input:gmatch("[^\n]+") do
		local a, b = line:match("(%d+)%s+(%d+)")
		table.insert(left, tonumber(a))
		table.insert(right, tonumber(b))
	end
	local count = {}
	for _, v in ipairs(right) do
		count[v] = (count[v] or 0) + 1
	end
	local sum = 0
	for _, v in ipairs(left) do
		sum = sum + v * (count[v] or 0)
	end
	return sum - 1
end

return M
