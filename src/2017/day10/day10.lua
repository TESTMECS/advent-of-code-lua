--- @title: Day 10: Knot Hash ---
local M = {}
local util = require("util")

--- @description: Compute the knot hash checksum for part 1
--- @param input string: the comma-separated lengths
--- @return number: the product of first two elements
function M.part1(input)
	local lengths = {}
	for num in input:gmatch("%d+") do
		table.insert(lengths, tonumber(num))
	end

	local list = {}
	for i = 0, 255 do
		list[i + 1] = i
	end

	local position = 1
	local skip = 0

	for _, len in ipairs(lengths) do
		-- Reverse the sublist
		local sub = {}
		for i = 0, len - 1 do
			sub[i + 1] = list[(position + i - 1) % 256 + 1]
		end
		for i = 0, len - 1 do
			list[(position + i - 1) % 256 + 1] = sub[len - i]
		end
		-- Move position
		position = (position + len + skip - 1) % 256 + 1
		skip = skip + 1
	end

	return list[1] * list[2]
end

--- @description: Compute the full knot hash
--- @param input string: the input string
--- @return string: the hex hash
function M.part2(input)
	local lengths = {}
	input = util.trim(input)
	for i = 1, #input do
		table.insert(lengths, input:byte(i))
	end
	table.insert(lengths, 17)
	table.insert(lengths, 31)
	table.insert(lengths, 73)
	table.insert(lengths, 47)
	table.insert(lengths, 23)

	local list = {}
	for i = 0, 255 do
		list[i + 1] = i
	end

	local position = 1
	local skip = 0

	for _ = 1, 64 do
		for _, len in ipairs(lengths) do
			-- Reverse the sublist
			local sub = {}
			for i = 0, len - 1 do
				sub[i + 1] = list[(position + i - 1) % 256 + 1]
			end
			for i = 0, len - 1 do
				list[(position + i - 1) % 256 + 1] = sub[len - i]
			end
			-- Move position
			position = (position + len + skip - 1) % 256 + 1
			skip = skip + 1
		end
	end

	-- Dense hash
	local dense = {}
	for i = 0, 15 do
		local xor_val = 0
		for j = 0, 15 do
			xor_val = xor_val ~ list[i * 16 + j + 1]
		end
		table.insert(dense, xor_val)
	end

	-- To hex
	local hex = ""
	for _, v in ipairs(dense) do
		hex = hex .. string.format("%02x", v)
	end

	return hex
end

return M
