--- @title: Day 2: 1202 Program Alarm ---
local M = {}
local util = require("util")

--- @description:
--- @param input string:
--- @return number: value at position 0 when the program halts
function M.part1(input)
	local tinput = util.split(input, ",")
	for i, v in ipairs(tinput) do
		tinput[i] = tonumber(v)
	end
	-- Restore program
	tinput[2] = 12
	tinput[3] = 2
	-- Run Intcode
	local i = 1
	while i <= #tinput do
		local opcode = tinput[i]
		if opcode == 1 then
			local a = tinput[tinput[i + 1] + 1]
			local b = tinput[tinput[i + 2] + 1]
			tinput[tinput[i + 3] + 1] = a + b
			i = i + 4
		elseif opcode == 2 then
			local a = tinput[tinput[i + 1] + 1]
			local b = tinput[tinput[i + 2] + 1]
			tinput[tinput[i + 3] + 1] = a * b
			i = i + 4
		elseif opcode == 99 then
			break
		else
			error("Unknown opcode: " .. opcode)
		end
	end
	return tinput[1]
end

--- @description:
--- @param input string:
--- @return number:
function M.part2(input)
	local original = util.split(input, ",")
	for i, v in ipairs(original) do
		original[i] = tonumber(v)
	end
	for noun = 0, 99 do
		for verb = 0, 99 do
			local prog = { table.unpack(original) }
			prog[2] = noun
			prog[3] = verb
			-- Run Intcode (same loop as part1)
			local i = 1
			while i <= #prog do
				local opcode = prog[i]
				if opcode == 1 then
					local a = prog[prog[i + 1] + 1]
					local b = prog[prog[i + 2] + 1]
					prog[prog[i + 3] + 1] = a + b
					i = i + 4
				elseif opcode == 2 then
					local a = prog[prog[i + 1] + 1]
					local b = prog[prog[i + 2] + 1]
					prog[prog[i + 3] + 1] = a * b
					i = i + 4
				elseif opcode == 99 then
					break
				else
					break -- Skip invalid
				end
			end
			if prog[1] == 19690720 then
				return 100 * noun + verb
			end
		end
	end
	return -1 -- Not found
end

return M
