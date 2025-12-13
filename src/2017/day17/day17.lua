--- @title: Day 17: Spinlock ---
local M = {}

--- @description: Find the value after 2017
--- @param input string: the steps
--- @return number: the value
function M.part1(input)
	local steps = tonumber(input:match("%d+"))
	local buffer = { 0 }
	local current = 1
	for value = 1, 2017 do
		local new_pos = (current + steps - 1) % #buffer + 1
		table.insert(buffer, new_pos + 1, value)
		current = new_pos + 1
	end
	local idx
	for i, v in ipairs(buffer) do
		if v == 2017 then
			idx = i
			break
		end
	end
	return buffer[(idx % #buffer) + 1]
end

--- @description: Find the value after 0 after 50 million
--- @param input string: the steps
--- @return number: the value
function M.part2(input)
	local steps = tonumber(input:match("%d+"))
	local size = 1
	local current = 1
	local pos_of_0 = 1
	local value_after_0 = 0
	for value = 1, 50000000 do
		local new_pos = (current + steps - 1) % size + 1
		local insert_index = new_pos + 1
		if insert_index == pos_of_0 + 1 then
			value_after_0 = value
		end
		if insert_index <= pos_of_0 then
			pos_of_0 = pos_of_0 + 1
		end
		size = size + 1
		current = insert_index
	end
	return value_after_0
end

return M
