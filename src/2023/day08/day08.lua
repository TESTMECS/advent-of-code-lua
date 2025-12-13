local M = {}
local lpeg = require("lpeg")

local P, R, S, C, Ct, _, _ = lpeg.P, lpeg.R, lpeg.S, lpeg.C, lpeg.Ct, lpeg.Cg, lpeg.Cc

local function gcd(a, b)
	while b ~= 0 do
		a, b = b, a % b
	end
	return a
end

local function lcm(a, b)
	return (a * b) / gcd(a, b)
end

-- LPeg definitions
local space = S(" \t") ^ 0
local newline = P("\r") ^ -1 * P("\n")
local name = C(R("AZ", "09") ^ 1)

local instrs = C(S("LR") ^ 1)

local node = Ct(name * space * P("=") * space * P("(") * space * name * space * P(",") * space * name * space * P(")"))

local grammar = Ct(instrs * newline * newline * Ct((node * newline ^ -1) ^ 1))

local function parse_input(input)
	local parsed = grammar:match(input)
	if not parsed then
		error("Failed to parse input")
	end

	local instr = parsed[1]
	local raw_nodes = parsed[2]

	local nodes = {}
	for _, triple in ipairs(raw_nodes) do
		local node, left, right = triple[1], triple[2], triple[3]
		nodes[node] = { left, right }
	end

	return instr, nodes
end

--- @description: Steps to reach ZZZ from AAA
function M.part1(input)
	local instr, nodes = parse_input(input)

	local current = "AAA"
	local steps, i = 0, 1

	while current ~= "ZZZ" do
		local dir = instr:sub(i, i)
		local idx = (dir == "L") and 1 or 2
		current = nodes[current][idx]
		steps = steps + 1
		i = (i % #instr) + 1
	end

	return steps
end

--- @description: Steps for all ghosts to reach **Z
function M.part2(input)
	local instr, nodes = parse_input(input)

	-- Find all starting nodes (ending with "A")
	local starts = {}
	for node in pairs(nodes) do
		if node:sub(-1) == "A" then
			table.insert(starts, node)
		end
	end

	-- Cycle lengths
	local cycles = {}
	for _, start in ipairs(starts) do
		local current = start
		local steps, i = 0, 1

		while current:sub(-1) ~= "Z" do
			local dir = instr:sub(i, i)
			local idx = (dir == "L") and 1 or 2
			current = nodes[current][idx]
			steps = steps + 1
			i = (i % #instr) + 1
		end

		table.insert(cycles, steps)
	end

	-- LCM of all cycle lengths
	local res = cycles[1]
	for i = 2, #cycles do
		res = lcm(res, cycles[i])
	end
	return res
end

return M
