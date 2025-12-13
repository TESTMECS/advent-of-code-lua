--- @title: Day 3: Squares With Three Sides ---
local M = {}

--- @description Counts the number of valid triangles from the input, where each line represents a triangle's side lengths. A triangle is valid if the sum of any two sides is greater than the third side
--- @param input string three cols of numbers separated by spaces
--- @return integer
function M.part1(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local nums = {}
		for num in line:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		if #nums == 3 then
			local a, b, c = nums[1], nums[2], nums[3]
			if a + b > c and a + c > b and b + c > a then
				count = count + 1
			end
		end
	end
	return count
end

--- @description Part 2: Reads the triangles by columns instead of rows (every 3 lines form 3 triangles from their respective columns)
--- @param input string three cols of numbers separated by spaces
--- @return integer
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		local nums = {}
		for num in line:gmatch("%d+") do
			table.insert(nums, tonumber(num))
		end
		table.insert(lines, nums)
	end
	local count = 0
	for i = 1, #lines, 3 do
		if i + 2 <= #lines then
			local l1, l2, l3 = lines[i], lines[i + 1], lines[i + 2]
			-- triangle 1: col 1
			local a, b, c = l1[1], l2[1], l3[1]
			if a + b > c and a + c > b and b + c > a then
				count = count + 1
			end
			-- triangle 2: col 2
			a, b, c = l1[2], l2[2], l3[2]
			if a + b > c and a + c > b and b + c > a then
				count = count + 1
			end
			-- triangle 3: col 3
			a, b, c = l1[3], l2[3], l3[3]
			if a + b > c and a + c > b and b + c > a then
				count = count + 1
			end
		end
	end
	return count
end

return M
