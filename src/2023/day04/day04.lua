--- @title: --- Day 4: Scratchcards ---
local M = {}

--- @description: Sum points from scratchcards (2^(matches-1))
--- @param input string: the puzzle input
--- @return number: the total points
function M.part1(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local part = line:match(": (.+)")
		local win_str, your_str = part:match("(.+) | (.+)")
		local winning = {}
		for num in win_str:gmatch("%d+") do
			winning[tonumber(num)] = true
		end
		local matches = 0
		for num in your_str:gmatch("%d+") do
			if winning[tonumber(num)] then
				matches = matches + 1
			end
		end
		if matches > 0 then
			sum = sum + 2 ^ (matches - 1)
		end
	end
	return sum
end

--- @description: Count total scratchcards including copies
--- @param input string: the puzzle input
--- @return number: the total number of cards
function M.part2(input)
	local cards = {}
	for line in input:gmatch("[^\n]+") do
		local card_id = line:match("Card (%d+)")
		local part = line:match(": (.+)")
		local win_str, your_str = part:match("(.+) | (.+)")
		local winning = {}
		for num in win_str:gmatch("%d+") do
			winning[tonumber(num)] = true
		end
		local your = {}
		for num in your_str:gmatch("%d+") do
			table.insert(your, tonumber(num))
		end
		table.insert(cards, { id = card_id, winning = winning, your = your })
	end
	local counts = {}
	for i = 1, #cards do
		counts[i] = 1
	end
	for i = 1, #cards do
		local matches = 0
		for _, num in ipairs(cards[i].your) do
			if cards[i].winning[num] then
				matches = matches + 1
			end
		end
		for j = 1, matches do
			if i + j <= #cards then
				counts[i + j] = counts[i + j] + counts[i]
			end
		end
	end
	local total = 0
	for _, c in ipairs(counts) do
		total = total + c
	end
	return total
end

return M
