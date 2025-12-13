--- @title: Day 22: Crab Combat ---
local M = {}

--- @description: Play normal game
--- @param input string: the puzzle input
--- @return number: the score
function M.part1(input)
	input = input:gsub("\r", "")
	local sections = {}
	for s in input:gmatch("(.-)\n\n") do
		table.insert(sections, s)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(sections, last)
	end
	local deck1 = {}
	for line in sections[1]:gmatch("[^\n]+") do
		if line:match("%d+") then
			table.insert(deck1, tonumber(line))
		end
	end
	local deck2 = {}
	for line in sections[2]:gmatch("[^\n]+") do
		if line:match("%d+") then
			table.insert(deck2, tonumber(line))
		end
	end
	while #deck1 > 0 and #deck2 > 0 do
		local c1 = table.remove(deck1, 1)
		local c2 = table.remove(deck2, 1)
		if c1 > c2 then
			table.insert(deck1, c1)
			table.insert(deck1, c2)
		else
			table.insert(deck2, c2)
			table.insert(deck2, c1)
		end
	end
	local winner = #deck1 > 0 and deck1 or deck2
	local score = 0
	for i, card in ipairs(winner) do
		score = score + card * (#winner - i + 1)
	end
	return score
end

--- @description: Play recursive game
--- @param input string: the puzzle input
--- @return number: the score
function M.part2(input)
	input = input:gsub("\r", "")
	local sections = {}
	for s in input:gmatch("(.-)\n\n") do
		table.insert(sections, s)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(sections, last)
	end
	local deck1 = {}
	for line in sections[1]:gmatch("[^\n]+") do
		if line:match("%d+") then
			table.insert(deck1, tonumber(line))
		end
	end
	local deck2 = {}
	for line in sections[2]:gmatch("[^\n]+") do
		if line:match("%d+") then
			table.insert(deck2, tonumber(line))
		end
	end
	local function play(deck1, deck2)
		local seen = {}
		while #deck1 > 0 and #deck2 > 0 do
			local state = table.concat(deck1, ",") .. "|" .. table.concat(deck2, ",")
			if seen[state] then
				return 1
			end
			seen[state] = true
			local c1 = table.remove(deck1, 1)
			local c2 = table.remove(deck2, 1)
			local winner
			if #deck1 >= c1 and #deck2 >= c2 then
				local sub1 = {}
				for i = 1, c1 do
					sub1[i] = deck1[i]
				end
				local sub2 = {}
				for i = 1, c2 do
					sub2[i] = deck2[i]
				end
				winner = play(sub1, sub2)
			else
				winner = c1 > c2 and 1 or 2
			end
			if winner == 1 then
				table.insert(deck1, c1)
				table.insert(deck1, c2)
			else
				table.insert(deck2, c2)
				table.insert(deck2, c1)
			end
		end
		return #deck1 > 0 and 1 or 2
	end
	play(deck1, deck2)
	local winner = #deck1 > 0 and deck1 or deck2
	local score = 0
	for i, card in ipairs(winner) do
		score = score + card * (#winner - i + 1)
	end
	return score
end

return M
