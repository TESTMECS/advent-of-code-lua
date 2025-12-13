--- Day 7: Camel Cards ---
local M = {}
local card_order1 = {
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	["T"] = 10,
	["J"] = 11,
	["Q"] = 12,
	["K"] = 13,
	["A"] = 14,
}
local card_order2 = {
	["J"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	["T"] = 10,
	["Q"] = 12,
	["K"] = 13,
	["A"] = 14,
}
local function get_type1(hand)
	local counts = {}
	for i = 1, 5 do
		local c = hand:sub(i, i)
		counts[c] = (counts[c] or 0) + 1
	end
	local freq = {}
	for _, v in pairs(counts) do
		freq[v] = (freq[v] or 0) + 1
	end
	if freq[5] then
		return 7
	elseif freq[4] then
		return 6
	elseif freq[3] and freq[2] then
		return 5
	elseif freq[3] then
		return 4
	elseif freq[2] == 2 then
		return 3
	elseif freq[2] then
		return 2
	else
		return 1
	end
end
local function get_type2(hand)
	local counts = {}
	local jokers = 0
	for i = 1, 5 do
		local c = hand:sub(i, i)
		if c == "J" then
			jokers = jokers + 1
		else
			counts[c] = (counts[c] or 0) + 1
		end
	end

	-- Special case: all jokers
	if jokers == 5 then
		return 7 -- five of a kind
	end

	-- Get counts in descending order
	local count_list = {}
	for _, v in pairs(counts) do
		table.insert(count_list, v)
	end
	table.sort(count_list, function(a, b)
		return a > b
	end)

	-- Add jokers to the highest count
	count_list[1] = count_list[1] + jokers

	-- Determine hand type based on the count pattern
	if count_list[1] == 5 then
		return 7 -- five of a kind
	elseif count_list[1] == 4 then
		return 6 -- four of a kind
	elseif count_list[1] == 3 and count_list[2] == 2 then
		return 5 -- full house
	elseif count_list[1] == 3 then
		return 4 -- three of a kind
	elseif count_list[1] == 2 and count_list[2] == 2 then
		return 3 -- two pair
	elseif count_list[1] == 2 then
		return 2 -- one pair
	else
		return 1 -- high card
	end
end
local function compare_hands(a, b, order)
	if a.type ~= b.type then
		return a.type < b.type -- Changed from > to <
	end
	for i = 1, 5 do
		local ca = order[a.hand:sub(i, i)]
		local cb = order[b.hand:sub(i, i)]
		if ca ~= cb then
			return ca < cb -- Changed from > to <
		end
	end
	return false
end
--- @description: Total winnings with standard rules
--- @param input string: the puzzle input
--- @return number: the total winnings
function M.part1(input)
	local hands = {}
	for line in input:gmatch("[^\n]+") do
		local hand, bid = line:match("(%S+) (%d+)")
		bid = tonumber(bid)
		local typ = get_type1(hand)
		table.insert(hands, { hand = hand, bid = bid, type = typ })
	end
	table.sort(hands, function(a, b)
		return compare_hands(a, b, card_order1)
	end)
	local sum = 0
	for i, h in ipairs(hands) do
		sum = sum + h.bid * i
	end
	return sum
end
--- @description: Total winnings with jokers
--- @param input string: the puzzle input
--- @return number: the total winnings
function M.part2(input)
	local hands = {}
	for line in input:gmatch("[^\n]+") do
		local hand, bid = line:match("(%S+) (%d+)")
		bid = tonumber(bid)
		local typ = get_type2(hand)
		table.insert(hands, { hand = hand, bid = bid, type = typ })
	end
	table.sort(hands, function(a, b)
		return compare_hands(a, b, card_order2)
	end)
	local sum = 0
	for i, h in ipairs(hands) do
		sum = sum + h.bid * i
	end
	return sum
end
return M
