--- @title: Day 6: Memory Reallocation ---
local M = {}

--- @description: Count cycles until configuration repeats
--- @param input string: the initial bank values
--- @return number: the cycle count
function M.part1(input)
	local banks = {}
	-- Parse input
	for num in input:gmatch("%d+") do
		table.insert(banks, tonumber(num))
	end
	local seen = {}
	local cycles = 0
	local function serialize(t)
		return table.concat(t, ",")
	end
	while true do
		local key = serialize(banks)
		if seen[key] then
			return cycles
		end
		seen[key] = true
		-- Find bank with most blocks
		local max_val = -1
		local max_idx = -1
		for i = 1, #banks do
			if banks[i] > max_val then
				max_val = banks[i]
				max_idx = i
			end
		end
		-- Redistribute
		local blocks = banks[max_idx]
		banks[max_idx] = 0
		local idx = max_idx
		for _ = 1, blocks do
			idx = idx % #banks + 1
			banks[idx] = banks[idx] + 1
		end
		cycles = cycles + 1
	end
end

--- @description: Count cycles in the loop
--- @param input string: the initial bank values
--- @return number: the loop size
function M.part2(input)
	local banks = {}
	-- Parse input
	for num in input:gmatch("%d+") do
		table.insert(banks, tonumber(num))
	end
	local seen = {}
	local first_seen = {}
	local cycles = 0
	local function serialize(t)
		return table.concat(t, ",")
	end
	while true do
		local key = serialize(banks)
		if seen[key] then
			return cycles - first_seen[key]
		end
		seen[key] = true
		first_seen[key] = cycles
		-- Find bank with most blocks
		local max_val = -1
		local max_idx = -1
		for i = 1, #banks do
			if banks[i] > max_val then
				max_val = banks[i]
				max_idx = i
			end
		end
		-- Redistribute
		local blocks = banks[max_idx]
		banks[max_idx] = 0
		local idx = max_idx
		for _ = 1, blocks do
			idx = idx % #banks + 1
			banks[idx] = banks[idx] + 1
		end
		cycles = cycles + 1
	end
end

return M
