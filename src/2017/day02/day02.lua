---@title: Day 2: Corruption Checksum ---
local M = {}

--- @description: Calculate checksum by summing differences between max and min in each row
--- @param input string: the spreadsheet as a string with tab-separated numbers
--- @return number: the checksum
function M.part1(input)
	local sum = 0
	-- Iterate over each line in the input
	for line in input:gmatch("[^\n]+") do
		local nums = {}
		-- Extract numbers from the line
		for num in line:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		if #nums > 0 then
			-- Find min and max values
			local min_val = math.min(table.unpack(nums))
			local max_val = math.max(table.unpack(nums))
			-- Add the difference to the sum
			sum = sum + (max_val - min_val)
		end
	end
	return sum
end

--- @description: Calculate checksum by summing quotients of evenly divisible pairs in each row
--- @param input string: the spreadsheet as a string with tab-separated numbers
--- @return number: the checksum
function M.part2(input)
	local sum = 0
	-- Iterate over each line in the input
	for line in input:gmatch("[^\n]+") do
		local nums = {}
		-- Extract numbers from the line
		for num in line:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		-- Find the pair where one divides the other evenly
		for i = 1, #nums do
			for j = i + 1, #nums do
				local a, b = nums[i], nums[j]
				if a % b == 0 then
					sum = sum + a / b
				elseif b % a == 0 then
					sum = sum + b / a
				end
			end
		end
	end
	return sum
end

return M
