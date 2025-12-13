--- @title: Day 14: Docking Data ---
local M = {}
local util = require("util")

--- @description: Sum memory with mask applied to values
--- @param input string: the puzzle input
--- @return number: the sum
function M.part1(input)
	local memory = {}
	local mask = ""
	for _, line in ipairs(util.read_lines(input)) do
		if line:find("mask") then
			mask = line:match("mask = (.+)")
		else
			local addr, val = line:match("mem%[(%d+)%] = (%d+)")
			addr = tonumber(addr)
			val = tonumber(val)
			local new_val = 0
			for i = 1, 36 do
				local bit = 36 - i
				local m = mask:sub(i, i)
				if m == "1" then
					new_val = new_val | (1 << bit)
				elseif m == "0" then
					-- 0
				else
					if val & (1 << bit) ~= 0 then
						new_val = new_val | (1 << bit)
					end
				end
			end
			memory[addr] = new_val
		end
	end
	local sum = 0
	for _, v in pairs(memory) do
		sum = sum + v
	end
	return sum
end

--- @description: Sum memory with mask applied to addresses
--- @param input string: the puzzle input
--- @return number: the sum
function M.part2(input)
	local memory = {}
	local mask = ""
	local function apply_mask(addr, mask)
		local base = 0
		local floats = {}
		for i = 1, 36 do
			local bit = 36 - i
			local m = mask:sub(i, i)
			if m == "1" then
				base = base | (1 << bit)
			elseif m == "0" then
				if addr & (1 << bit) ~= 0 then
					base = base | (1 << bit)
				end
			else
				table.insert(floats, bit)
			end
		end
		local addresses = { base }
		for _, f in ipairs(floats) do
			local new_addrs = {}
			for _, a in ipairs(addresses) do
				table.insert(new_addrs, a)
				table.insert(new_addrs, a | (1 << f))
			end
			addresses = new_addrs
		end
		return addresses
	end
	for _, line in ipairs(util.read_lines(input)) do
		if line:find("mask") then
			mask = line:match("mask = (.+)")
		else
			local addr, val = line:match("mem%[(%d+)%] = (%d+)")
			addr = tonumber(addr)
			val = tonumber(val)
			local addrs = apply_mask(addr, mask)
			for _, a in ipairs(addrs) do
				memory[a] = val
			end
		end
	end
	local sum = 0
	for _, v in pairs(memory) do
		sum = sum + v
	end
	return sum
end

return M
