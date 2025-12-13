--- @title: Day 8: Handheld Halting ---
local M = {}
local util = require("util")

--- @description: Run the program until it loops, return accumulator
--- @param input string: the puzzle input
--- @return number: the accumulator
function M.part1(input)
	local lines = util.read_lines(input)
	local instructions = {}
	for _, line in ipairs(lines) do
		local op, arg = line:match("(%w+) ([+-]%d+)")
		table.insert(instructions, { op = op, arg = tonumber(arg) })
	end
	local acc = 0
	local pc = 1
	local visited = {}
	while not visited[pc] do
		visited[pc] = true
		local inst = instructions[pc]
		if inst.op == "nop" then
			pc = pc + 1
		elseif inst.op == "acc" then
			acc = acc + inst.arg
			pc = pc + 1
		elseif inst.op == "jmp" then
			pc = pc + inst.arg
		end
	end
	return acc
end

--- @description: Fix the program by changing one instruction, return accumulator
--- @param input string: the puzzle input
--- @return number: the accumulator
function M.part2(input)
	local lines = util.read_lines(input)
	local instructions = {}
	for _, line in ipairs(lines) do
		local op, arg = line:match("(%w+) ([+-]%d+)")
		table.insert(instructions, { op = op, arg = tonumber(arg) })
	end
	local function simulate()
		local acc = 0
		local pc = 1
		local visited = {}
		while pc <= #instructions and not visited[pc] do
			visited[pc] = true
			local inst = instructions[pc]
			if inst.op == "nop" then
				pc = pc + 1
			elseif inst.op == "acc" then
				acc = acc + inst.arg
				pc = pc + 1
			elseif inst.op == "jmp" then
				pc = pc + inst.arg
			end
		end
		if pc > #instructions then
			return acc
		else
			return nil
		end
	end
	for i = 1, #instructions do
		if instructions[i].op == "nop" or instructions[i].op == "jmp" then
			local original = instructions[i].op
			instructions[i].op = (original == "nop") and "jmp" or "nop"
			local result = simulate()
			instructions[i].op = original
			if result then
				return result
			end
		end
	end
	return 0
end

return M
