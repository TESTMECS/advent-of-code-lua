 --- @title: Day 20: Grove Positioning System ---
local M = {}

local function mix(list, times)
	for _ = 1, times do
		for i = 1, #list do
			local pos = 1
			for j = 1, #list do
				if list[j][2] == i - 1 then
					pos = j
					break
				end
			end
			local val = table.remove(list, pos)
			local new_pos = (pos - 1 + val[1]) % #list + 1
			table.insert(list, new_pos, val)
		end
	end
	local zero_pos
	for i = 1, #list do
		if list[i][1] == 0 then
			zero_pos = i
			break
		end
	end
	local sum = 0
	for _, off in ipairs({ 1000, 2000, 3000 }) do
		local idx = (zero_pos - 1 + off) % #list + 1
		sum = sum + list[idx][1]
	end
	return sum
end

--- @description Mix once and find sum
--- @param input string the puzzle input
--- @return number the sum
function M.part1(input)
	local nums = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(nums, { tonumber(line), #nums })
	end
	local list = {}
	for i, v in ipairs(nums) do
		list[i] = v
	end
	return mix(list, 1)
end

--- @description Mix 10 times with decryption key and find sum
--- @param input string the puzzle input
--- @return number the sum
function M.part2(input)
	local nums = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(nums, { tonumber(line) * 811589153, #nums })
	end
	local list = {}
	for i, v in ipairs(nums) do
		list[i] = v
	end
	return mix(list, 10)
end

return M
