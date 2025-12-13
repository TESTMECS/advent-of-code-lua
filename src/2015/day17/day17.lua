--- @title: Day 17: No Such Thing as Too Much ---
local M = {}

--- @function: Parse the input file into a list of integers
--- @param input string
--- @return table<integer>
local function parse_containers(input)
	local containers = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(containers, tonumber(line))
	end
	return containers
end

--- @description: Find all possible subsets of the containers
--- @param input string: The input file
--- @return integer
function M.part1(input)
	local containers = parse_containers(input)
	local count = 0
	--- @function: Find all possible subsets of the containers
	--- @param index integer: The index of the current container
	--- @param current_sum integer: The current sum of the containers
	local function find_subsets(index, current_sum)
		if current_sum == 150 then
			count = count + 1
			return
		end
		if index > #containers or current_sum > 150 then
			return
		end
		find_subsets(index + 1, current_sum)
		find_subsets(index + 1, current_sum + containers[index])
	end
	find_subsets(1, 0)
	return count
end

--- @description: Find the minimum number of containers that can exactly fit all 150 liters of eggnog
--- @param input string: The input file
--- @return integer
function M.part2(input)
	local containers = parse_containers(input)
	local count = 0
	local min_containers = math.huge
	local min_count = 0
	--- @function: Find the minimum number of containers that can exactly fit all 150 liters of eggnog
	--- @param index integer: The index of the current container
	--- @param current_sum integer: The current sum of the containers
	--- @param num_used integer: The number of containers used
	local function find_subsets(index, current_sum, num_used)
		if current_sum == 150 then
			count = count + 1
			if num_used < min_containers then
				min_containers = num_used
				min_count = 1
			elseif num_used == min_containers then
				min_count = min_count + 1
			end
			return
		end
		if index > #containers or current_sum > 150 then
			return
		end
		find_subsets(index + 1, current_sum, num_used)
		find_subsets(index + 1, current_sum + containers[index], num_used + 1)
	end
	find_subsets(1, 0, 0)
	return min_count
end

return M
