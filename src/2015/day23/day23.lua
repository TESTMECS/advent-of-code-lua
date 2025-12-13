--- @title: Day 23: Opening the Turing Lock ---
local M = {}
local util = require("util")

--- @function: parse the instructions
--- @param input string
--- @return table
local function parse_instructions(input)
	local lines = util.read_lines(input)
	local instructions = {}
	for _, line in ipairs(lines) do
		local parts = util.split(line, " ")
		local op = parts[1]
		if op == "jmp" then
			local offset = parts[2]
			table.insert(instructions, { op = op, arg1 = tonumber(offset) })
		elseif op == "jio" or op == "jie" then
			local reg = parts[2]:gsub(",", "")
			local offset = parts[3]
			table.insert(instructions, { op = op, arg1 = reg, arg2 = tonumber(offset) })
		else
			local reg = parts[2]
			table.insert(instructions, { op = op, arg1 = reg })
		end
	end
	return instructions
end

--- @function: simulate the instructions
--- @param instructions table
--- @param a_start number
--- @return number
local function simulate(instructions, a_start)
	local regs = { a = a_start, b = 0 }
	local pc = 1
	local steps = 0
	local max_steps = 10000000
	while pc >= 1 and pc <= #instructions and steps < max_steps do
		steps = steps + 1
		local inst = instructions[pc]
		if inst.op == "hlf" then
			regs[inst.arg1] = math.floor(regs[inst.arg1] / 2)
			pc = pc + 1
		elseif inst.op == "tpl" then
			regs[inst.arg1] = regs[inst.arg1] * 3
			pc = pc + 1
		elseif inst.op == "inc" then
			regs[inst.arg1] = regs[inst.arg1] + 1
			pc = pc + 1
		elseif inst.op == "jmp" then
			pc = pc + inst.arg1
		elseif inst.op == "jie" then
			if regs[inst.arg1] % 2 == 0 then
				pc = pc + inst.arg2
			else
				pc = pc + 1
			end
		elseif inst.op == "jio" then
			if regs[inst.arg1] == 1 then
				pc = pc + inst.arg2
			else
				pc = pc + 1
			end
		end
	end
	if steps >= max_steps then
		return -1
	end
	return regs.b
end

--- @description: Day 23: Opening the Turing Lock
--- @param input string
--- @return number
function M.part1(input)
	local instructions = parse_instructions(input)
	return simulate(instructions, 0)
end

--- @description: Day 23: Opening the Turing Lock
--- @param input string
--- @return number
function M.part2(input)
	local instructions = parse_instructions(input)
	return simulate(instructions, 1)
end

return M
