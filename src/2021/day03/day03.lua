---@title: --- Day 3: Binary Diagnostic ---
local M = {}

--- @description: Calculate the power consumption of the submarine
--- @param input string: the puzzle input
--- @return number: the product of gamma and epsilon rates
function M.part1(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local len = #lines[1]
	local gamma = ""
	local epsilon = ""
	for i = 1, len do
		local count0 = 0
		local count1 = 0
		for _, line in ipairs(lines) do
			if line:sub(i, i) == "0" then
				count0 = count0 + 1
			else
				count1 = count1 + 1
			end
		end
		if count1 > count0 then
			gamma = gamma .. "1"
			epsilon = epsilon .. "0"
		else
			gamma = gamma .. "0"
			epsilon = epsilon .. "1"
		end
	end
	local gamma_num = tonumber(gamma, 2)
	local epsilon_num = tonumber(epsilon, 2)
	return gamma_num * epsilon_num
end

--- @description: Calculate the life support rating of the submarine
--- @param input string: the puzzle input
--- @return number: the product of oxygen generator and CO2 scrubber ratings
function M.part2(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local function get_rating(list, is_oxygen)
		local pos = 1
		while #list > 1 do
			local count0 = 0
			local count1 = 0
			for _, line in ipairs(list) do
				if line:sub(pos, pos) == "0" then
					count0 = count0 + 1
				else
					count1 = count1 + 1
				end
			end
			local keep
			if is_oxygen then
				keep = (count1 >= count0) and "1" or "0"
			else
				keep = (count0 <= count1) and "0" or "1"
			end
			local new_list = {}
			for _, line in ipairs(list) do
				if line:sub(pos, pos) == keep then
					table.insert(new_list, line)
				end
			end
			list = new_list
			pos = pos + 1
		end
		return list[1]
	end
	local oxygen = get_rating(lines, true)
	local co2 = get_rating(lines, false)
	local oxygen_num = tonumber(oxygen, 2)
	local co2_num = tonumber(co2, 2)
	return oxygen_num * co2_num
end

return M
