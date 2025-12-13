--- @title: --- Day 2: Red-Nosed Reports ---
local M = {}

--- @description Count the number of safe reports
--- @param input string the puzzle input
--- @return number the number of safe reports
function M.part1(input)
	local function is_safe(levels)
		if #levels < 2 then
			return true
		end
		local increasing = levels[2] > levels[1]
		for i = 2, #levels do
			local diff = levels[i] - levels[i - 1]
			if (increasing and diff <= 0) or (not increasing and diff >= 0) then
				return false
			end
			if math.abs(diff) < 1 or math.abs(diff) > 3 then
				return false
			end
		end
		return true
	end

	local count = 0
	for line in input:gmatch("[^\n]+") do
		local levels = {}
		for num in line:gmatch("%d+") do
			table.insert(levels, tonumber(num))
		end
		if is_safe(levels) then
			count = count + 1
		end
	end
	return count
end

--- @description Count the number of safe reports with the Problem Dampener
--- @param input string the puzzle input
--- @return number the number of safe reports
function M.part2(input)
	local function is_safe(levels)
		if #levels < 2 then
			return true
		end
		local increasing = levels[2] > levels[1]
		for i = 2, #levels do
			local diff = levels[i] - levels[i - 1]
			if (increasing and diff <= 0) or (not increasing and diff >= 0) then
				return false
			end
			if math.abs(diff) < 1 or math.abs(diff) > 3 then
				return false
			end
		end
		return true
	end

	local count = 0
	for line in input:gmatch("[^\n]+") do
		local levels = {}
		for num in line:gmatch("%d+") do
			table.insert(levels, tonumber(num))
		end
		if is_safe(levels) then
			count = count + 1
		else
			local safe = false
			for i = 1, #levels do
				local new_levels = {}
				for j = 1, #levels do
					if j ~= i then
						table.insert(new_levels, levels[j])
					end
				end
				if is_safe(new_levels) then
					safe = true
					break
				end
			end
			if safe then
				count = count + 1
			end
		end
	end
	return count
end

return M
