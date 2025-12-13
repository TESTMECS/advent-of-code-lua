--- @title: --- Day 3: Mull It Over ---
local M = {}

--- @description Sum the results of all mul instructions
--- @param input string the puzzle input
--- @return number the sum of multiplications
function M.part1(input)
	local sum = 0
	for a, b in input:gmatch("mul%((%d+),(%d+)%)") do
		sum = sum + tonumber(a) * tonumber(b)
	end
	return sum
end

--- @description Sum the results of enabled mul instructions considering do and don't
--- @param input string the puzzle input
--- @return number the sum of enabled multiplications
function M.part2(input)
	local tins = table.insert
	local function parse(line)
		local instrs = {}
		for instr_str in line:gmatch("[%a']+%([%d,]*%)") do
			local left, right = string.match(instr_str, "mul%((%d%d?%d?),(%d%d?%d?)%)")
			if left ~= nil then
				tins(instrs, {
					type = "MUL",
					left = tonumber(left),
					right = tonumber(right),
				})
			elseif string.match(instr_str, "do%(%)") then
				tins(instrs, { type = "DO" })
			elseif string.match(instr_str, "don't%(%)") then
				tins(instrs, { type = "DONT" })
			end
		end
		return instrs
	end
	local function run(instrs)
		local num = 0
		local is_enabled = true
		for _, instr in ipairs(instrs) do
			if is_enabled and instr.type == "MUL" then
				num = num + instr.left * instr.right
			elseif instr.type == "DO" then
				is_enabled = true
			elseif instr.type == "DONT" then
				is_enabled = false
			end
		end
		return num
	end
	local instrs = parse(input)
	local res = run(instrs)
	return res
end

return M
