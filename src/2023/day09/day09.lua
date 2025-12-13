--- @title: --- Day 9: Smoke Basin ---
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local seq = {}
		for num in line:gmatch("%S+") do
			table.insert(seq, tonumber(num))
		end
		local diffs = { seq }
		while true do
			local new_diff = {}
			local all_zero = true
			for i = 2, #diffs[#diffs] do
				local d = diffs[#diffs][i] - diffs[#diffs][i - 1]
				table.insert(new_diff, d)
				if d ~= 0 then
					all_zero = false
				end
			end
			table.insert(diffs, new_diff)
			if all_zero then
				break
			end
		end
		local next_val = 0
		for i = #diffs, 1, -1 do
			next_val = diffs[i][#diffs[i]] + next_val
		end
		sum = sum + next_val
	end
	return sum
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local seq = {}
		for num in line:gmatch("%S+") do
			table.insert(seq, tonumber(num))
		end
		local diffs = { seq }
		while true do
			local new_diff = {}
			local all_zero = true
			for i = 2, #diffs[#diffs] do
				local d = diffs[#diffs][i] - diffs[#diffs][i - 1]
				table.insert(new_diff, d)
				if d ~= 0 then
					all_zero = false
				end
			end
			table.insert(diffs, new_diff)
			if all_zero then
				break
			end
		end
		local prev_val = 0
		for i = #diffs, 1, -1 do
			prev_val = diffs[i][1] - prev_val
		end
		sum = sum + prev_val
	end
	return sum
end

return M
