--- @title: Day 09: Marble Mania ---
local M = {}

--- @description: Simulates the marble game and finds the highest score
--- @param input string: the puzzle input
--- @return number: the highest score
function M.part1(input)
	local players, last = input:match("(%d+) players; last marble is worth (%d+)")
	players = tonumber(players)
	last = tonumber(last)
	local scores = {}
	for i = 1, players do
		scores[i] = 0
	end
	local circle = { val = 0 }
	circle.next = circle
	circle.prev = circle
	local current = circle
	local player = 1
	for marble = 1, last do
		if marble % 23 == 0 then
			scores[player] = scores[player] + marble
			local remove = current
			for i = 1, 7 do
				remove = remove.prev
			end
			scores[player] = scores[player] + remove.val
			remove.prev.next = remove.next
			remove.next.prev = remove.prev
			current = remove.next
		else
			local insert_pos = current.next
			local new_node = { val = marble, next = insert_pos.next, prev = insert_pos }
			insert_pos.next.prev = new_node
			insert_pos.next = new_node
			current = new_node
		end
		player = player % players + 1
	end
	local max_score = 0
	for _, score in ipairs(scores) do
		if score > max_score then
			max_score = score
		end
	end
	return max_score
end

--- @description: Simulates the marble game with 100 times the last marble
--- @param input string: the puzzle input
--- @return number: the highest score
function M.part2(input)
	local players, last = input:match("(%d+) players; last marble is worth (%d+)")
	players = tonumber(players)
	last = tonumber(last) * 100
	local scores = {}
	for i = 1, players do
		scores[i] = 0
	end
	local circle = { val = 0 }
	circle.next = circle
	circle.prev = circle
	local current = circle
	local player = 1
	for marble = 1, last do
		if marble % 23 == 0 then
			scores[player] = scores[player] + marble
			local remove = current
			for i = 1, 7 do
				remove = remove.prev
			end
			scores[player] = scores[player] + remove.val
			remove.prev.next = remove.next
			remove.next.prev = remove.prev
			current = remove.next
		else
			local insert_pos = current.next
			local new_node = { val = marble, next = insert_pos.next, prev = insert_pos }
			insert_pos.next.prev = new_node
			insert_pos.next = new_node
			current = new_node
		end
		player = player % players + 1
	end
	local max_score = 0
	for _, score in ipairs(scores) do
		if score > max_score then
			max_score = score
		end
	end
	return max_score
end

return M
