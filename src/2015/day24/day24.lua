--- @title: Day 24: It Hangs in the Balance ---
local M = {}
local util = require("util")

--- @function: parse the instructions
--- @param weights table
--- @param target number
--- @return number
local function find_best(weights, target)
	table.sort(weights, function(a, b)
		return a > b
	end)
	local best_size = math.huge
	local best_qe = math.huge

	local function search(start, current_sum, current_qe, current_size)
		if current_sum == target then
			if current_size < best_size or (current_size == best_size and current_qe < best_qe) then
				best_size = current_size
				best_qe = current_qe
			end
			return
		end
		if current_sum > target or start > #weights or current_size >= best_size then
			return
		end
		-- skip
		search(start + 1, current_sum, current_qe, current_size)
		-- take
		local w = weights[start]
		if current_sum + w <= target then
			search(start + 1, current_sum + w, current_qe * w, current_size + 1)
		end
	end

	search(1, 0, 1, 0)
	return best_qe
end

--- @description: Day 24: It Hangs in the Balance
--- @param input string
--- @return number
function M.part1(input)
	local weights = {}
	for _, line in ipairs(util.read_lines(input)) do
		if line ~= "" then
			table.insert(weights, tonumber(line))
		end
	end
	local total = 0
	for _, w in ipairs(weights) do
		total = total + w
	end
	local target = total / 3
	return find_best(weights, target)
end

--- @description: Day 24: It hangs in the balance.
--- @param input string
--- @return number
function M.part2(input)
	local weights = {}
	for _, line in ipairs(util.read_lines(input)) do
		if line ~= "" then
			table.insert(weights, tonumber(line))
		end
	end
	local total = 0
	for _, w in ipairs(weights) do
		total = total + w
	end
	local target = total / 4
	return find_best(weights, target)
end

return M
