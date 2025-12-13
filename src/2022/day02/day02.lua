--- @title: -- Day 2: Rock Paper Scissors ---
local M = {}
local util = require("util")

--- @description:
--- @param input string:
--- @return number:
function M.part1(input)
	local lines = util.read_lines(input)
	local score = 0

	local opp_map = { A = 1, B = 2, C = 3 }
	local me_map = { X = 1, Y = 2, Z = 3 }

	for _, line in ipairs(lines) do
		local opp, me = line:match("(%a) (%a)")
		local o = opp_map[opp]
		local m = me_map[me]

		-- outcome: 0 = tie, 1 = win, 2 = loss
		local outcome = (m - o) % 3

		if outcome == 0 then -- tie
			score = score + m + 3
		elseif outcome == 1 then -- win
			score = score + m + 6
		else -- loss
			score = score + m
		end
	end

	return score
end

--- @description:
--- @param input string:
--- @return number:
function M.part2(input)
	local lines = util.read_lines(input)
	local score = 0

	local opp_map = { A = 1, B = 2, C = 3 }
	local outcome_map = { X = "lose", Y = "draw", Z = "win" }

	for _, line in ipairs(lines) do
		local opp, outcome_code = line:match("(%a) (%a)")
		local o = opp_map[opp]
		local outcome = outcome_map[outcome_code]

		local m
		if outcome == "draw" then
			m = o
			score = score + m + 3
		elseif outcome == "win" then
			m = (o % 3) + 1
			score = score + m + 6
		else -- lose
			m = ((o + 1) % 3) + 1
			score = score + m
		end
	end

	return score
end

return M
