--- @title: Day 16: Dragon Checksum ---
local M = {}

--- @function: Generates the data for the disk
--- @param initial_state string: The initial state.
--- @param disk_length integer: The length of the disk.
--- @return string: The generated data.
local function generate_data(initial_state, disk_length)
	local data = initial_state
	while #data < disk_length do
		local b = data:reverse()
		b = b:gsub("0", "x"):gsub("1", "0"):gsub("x", "1")
		data = data .. "0" .. b
	end
	return data:sub(1, disk_length)
end

--- @function: Calculates the checksum
--- @param data string: The generated data.
--- @return string: The checksum.
local function calculate_checksum(data)
	local checksum = data
	while #checksum % 2 == 0 do
		local next_checksum = {}
		for i = 1, #checksum, 2 do
			if checksum:sub(i, i) == checksum:sub(i + 1, i + 1) then
				table.insert(next_checksum, "1")
			else
				table.insert(next_checksum, "0")
			end
		end
		checksum = table.concat(next_checksum)
	end
	return checksum
end

--- @function: Solves the problem by generating the data and calculating the checksum
--- @param initial_state string: The initial state.
--- @param disk_length integer: The length of the disk.
--- @return string: The final checksum.
local function solve(initial_state, disk_length)
	local data = generate_data(initial_state, disk_length)
	local checksum = calculate_checksum(data)
	return checksum
end

--- @description: Calculates the Dragon Checksum for a disk of length 272.
--- @param input string: The initial state.
--- @return string: The final checksum.
function M.part1(input)
	local initial_state = input:match("%S+")
	return solve(initial_state, 272)
end

--- @description: Calculates the Dragon Checksum for a disk of length 35651584.
--- @param input string: The initial state.
--- @return string: The final checksum.
function M.part2(input)
	local initial_state = input:match("%S+")
	return solve(initial_state, 35651584)
end

return M
