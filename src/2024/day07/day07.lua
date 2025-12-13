--- @title: --- Day 7: Bridge Repair ---
local M = {}

--- @description Sum targets that can be made with + and *
--- @param input string the puzzle input
--- @return number the sum of valid targets
function M.part1(input)
	local function can_make(target, nums, index, current)
		if index > #nums then
			return current == target
		end
		local num = nums[index]
		return can_make(target, nums, index + 1, current + num) or can_make(target, nums, index + 1, current * num)
	end

	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local target_str, nums_str = line:match("(%d+): (.+)")
		local target = tonumber(target_str)
		local nums = {}
		for num in nums_str:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		if can_make(target, nums, 2, nums[1]) then
			sum = sum + target
		end
	end
	return sum
end

--- @description Sum targets that can be made with +, *, ||
--- @param input string the puzzle input
--- @return number the sum of valid targets
function M.part2(input)
	local function can_make(target, nums, index, current)
		if index > #nums then
			return current == target
		end
		local num = nums[index]
		if can_make(target, nums, index + 1, current + num) then
			return true
		end
		if can_make(target, nums, index + 1, current * num) then
			return true
		end
		local concat = tonumber(tostring(current) .. tostring(num))
		if can_make(target, nums, index + 1, concat) then
			return true
		end
		return false
	end

	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local target_str, nums_str = line:match("(%d+): (.+)")
		local target = tonumber(target_str)
		local nums = {}
		for num in nums_str:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		if can_make(target, nums, 2, nums[1]) then
			sum = sum + target
		end
	end
	return sum
end

return M
