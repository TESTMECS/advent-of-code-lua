--- @title: --- Day 5: Supply Stacks ---
local M = {}

local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local stacks = {}
	local num_stacks = 0
	local move_start = 0
	for i, line in ipairs(lines) do
		if line:match("move") then
			move_start = i
			break
		end
		if line:match("%d") then
			local nums = {}
			for num in line:gmatch("%d+") do
				table.insert(nums, tonumber(num))
			end
			num_stacks = #nums
		end
	end
	for i = 1, num_stacks do
		stacks[i] = {}
	end
	for i = move_start - 2, 1, -1 do
		local line = lines[i]
		for j = 1, num_stacks do
			local pos = 2 + 4 * (j - 1)
			local crate = line:sub(pos, pos)
			if crate and crate:match("%a") then
				table.insert(stacks[j], crate)
			end
		end
	end
	local moves = {}
	for i = move_start, #lines do
		local n, from, to = lines[i]:match("move (%d+) from (%d+) to (%d+)")
		if n then
			table.insert(moves, {tonumber(n), tonumber(from), tonumber(to)})
		end
	end
	return stacks, moves
end

local function get_tops(stacks)
	local result = ""
	for i = 1, #stacks do
		if #stacks[i] > 0 then
			result = result .. stacks[i][#stacks[i]]
		end
	end
	return result
end

--- @description: Simulate moves with CrateMover 9000 and get top crates
--- @param input string the puzzle input
--- @return string: the top crates
function M.part1(input)
	local stacks, moves = parse_input(input)
	for _, move in ipairs(moves) do
		local n, from, to = table.unpack(move)
		for i = 1, n do
			local crate = table.remove(stacks[from])
			table.insert(stacks[to], crate)
		end
	end
	return get_tops(stacks)
end

--- @description: Simulate moves with CrateMover 9001 and get top crates
--- @param input string the puzzle input
--- @return string: the top crates
function M.part2(input)
	local stacks, moves = parse_input(input)
	for _, move in ipairs(moves) do
		local n, from, to = table.unpack(move)
		local temp = {}
		for i = 1, n do
			table.insert(temp, table.remove(stacks[from]))
		end
		for i = #temp, 1, -1 do
			table.insert(stacks[to], temp[i])
		end
	end
	return get_tops(stacks)
end

return M
