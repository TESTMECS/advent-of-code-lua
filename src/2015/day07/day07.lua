--- @title: --- Day 7: Some Assembly Required ---
--- @note: Note that bitwise operations were introduced in Lua 5.3, therfore not JIT possible, Lua 5.2 use the bit32 module that ships with lua and for 5.1 consider 'numlua' via luarocks.
local util = require("util")
local M = {}

--- @function: parse input and return a table for all the wires
--- @param input string
--- @return table wires
local function parse_input(input)
	local wires = {}
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		local wire
		local _, arg1, arg2
		if line:match("(%S+) AND (%S+) %-> (%w+)") then
			arg1, arg2, wire = line:match("(%S+) AND (%S+) %-> (%w+)")
			wires[wire] = { op = "AND", arg1 = arg1, arg2 = arg2 }
		elseif line:match("(%S+) OR (%S+) %-> (%w+)") then
			arg1, arg2, wire = line:match("(%S+) OR (%S+) %-> (%w+)")
			wires[wire] = { op = "OR", arg1 = arg1, arg2 = arg2 }
		elseif line:match("(%S+) LSHIFT (%d+) %-> (%w+)") then
			arg1, arg2, wire = line:match("(%S+) LSHIFT (%d+) %-> (%w+)")
			wires[wire] = { op = "LSHIFT", arg1 = arg1, arg2 = arg2 }
		elseif line:match("(%S+) RSHIFT (%d+) %-> (%w+)") then
			arg1, arg2, wire = line:match("(%S+) RSHIFT (%d+) %-> (%w+)")
			wires[wire] = { op = "RSHIFT", arg1 = arg1, arg2 = arg2 }
		elseif line:match("NOT (%S+) %-> (%w+)") then
			arg1, wire = line:match("NOT (%S+) %-> (%w+)")
			wires[wire] = { op = "NOT", arg1 = arg1 }
		elseif line:match("(%S+) %-> (%w+)") then
			arg1, wire = line:match("(%S+) %-> (%w+)")
			wires[wire] = { op = "ASSIGN", arg1 = arg1 }
		end
	end
	return wires
end

--- @function: compute the value of a wire, given the wires and the memo table
--- @param wire string
--- @param wires table
--- @param memo table
--- @return integer
local function compute(wire, wires, memo)
	if memo[wire] then
		return memo[wire]
	end
	local info = wires[wire]
	if not info then
		error("no wire " .. wire)
	end
	local val
	local a1 = tonumber(info.arg1) or compute(info.arg1, wires, memo)
	local a2 = info.arg2 and (tonumber(info.arg2) or compute(info.arg2, wires, memo))
	if info.op == "ASSIGN" then
		val = a1
	elseif info.op == "AND" then
		val = a1 & a2
	elseif info.op == "OR" then
		val = a1 | a2
	elseif info.op == "LSHIFT" then
		val = a1 << a2 & 0xFFFF
	elseif info.op == "RSHIFT" then
		val = a1 >> a2
	elseif info.op == "NOT" then
		val = ~a1 & 0xFFFF
	end
	local constant = 2 ^ 16 - 1
	val = val & constant
	memo[wire] = val
	return val
end

--- @description Part 1
--- @param input string
--- @return integer
function M.part1(input)
	local wires = parse_input(input)
	local memo = {}
	return compute("a", wires, memo)
end

--- @description Part 2 - Different encoding
--- @param input string
--- @return integer
function M.part2(input)
	local wires = parse_input(input)
	local memo = {}
	local val_a = compute("a", wires, memo)
	wires["b"] = { op = "ASSIGN", arg1 = tostring(val_a) }
	memo = {}
	return compute("a", wires, memo)
end

return M
