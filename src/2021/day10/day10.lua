--- @title: Day 10: Title ---
local M = {}

--- @description: Calculate the total syntax error score for corrupted lines
--- @param input string: the puzzle input
--- @return number: the total score
function M.part1(input)
	local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }
	local scores = { [")"] = 3, ["]"] = 57, ["}"] = 1197, [">"] = 25137 }
	local score = 0
	for line in input:gmatch("[^\n]+") do
		local stack = {}
		for c in line:gmatch(".") do
			if pairs[c] then
				table.insert(stack, c)
			else
				local top = table.remove(stack)
				if pairs[top] ~= c then
					score = score + scores[c]
					break
				end
			end
		end
	end
	return score
end

--- @description: Calculate the middle completion score for incomplete lines
--- @param input string: the puzzle input
--- @return number: the middle score
function M.part2(input)
	local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }
	local scores = { [")"] = 1, ["]"] = 2, ["}"] = 3, [">"] = 4 }
	local all_scores = {}
	for line in input:gmatch("[^\n]+") do
		local stack = {}
		local corrupted = false
		for c in line:gmatch(".") do
			if pairs[c] then
				table.insert(stack, c)
			else
				local top = table.remove(stack)
				if pairs[top] ~= c then
					corrupted = true
					break
				end
			end
		end
		if not corrupted and #stack > 0 then
			local completion_score = 0
			for i = #stack, 1, -1 do
				local c = pairs[stack[i]]
				completion_score = completion_score * 5 + scores[c]
			end
			table.insert(all_scores, completion_score)
		end
	end
	table.sort(all_scores)
	local n = #all_scores
	return all_scores[math.floor(n / 2) + 1]
end

return M
