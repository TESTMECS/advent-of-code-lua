--- @title: Day 23: Crab Cups ---
local M = {}

--- @description: Simulate 100 moves using a linked-list approach.
--- @param input string: the puzzle input
--- @return string: the order of cups after cup 1
function M.part1(input)
	local cups_raw = {}
	for i = 1, #input do
		table.insert(cups_raw, tonumber(input:sub(i, i)))
	end

	-- Use a linked-list representation: next_cup[cup_label] = next_cup_label
	local next_cup = {}
	local num_cups = #cups_raw
	for i = 1, num_cups - 1 do
		next_cup[cups_raw[i]] = cups_raw[i + 1]
	end
	-- Link the last cup back to the first to complete the circle
	next_cup[cups_raw[num_cups]] = cups_raw[1]

	local current_cup = cups_raw[1]

	for _ = 1, 100 do
		-- 1. Pick up the three cups immediately clockwise of the current cup.
		local p1 = next_cup[current_cup]
		local p2 = next_cup[p1]
		local p3 = next_cup[p2]
		local picked = { [p1] = true, [p2] = true, [p3] = true }

		-- 2. Select a destination cup.
		local destination_cup = current_cup - 1
		while true do
			if destination_cup < 1 then
				destination_cup = num_cups
			end
			if not picked[destination_cup] then
				break
			end
			destination_cup = destination_cup - 1
		end

		-- 3. Rewire the pointers to move the picked cups.
		local after_picked = next_cup[p3]
		local after_destination = next_cup[destination_cup]

		next_cup[current_cup] = after_picked -- Current cup now points past the picked ones.
		next_cup[destination_cup] = p1 -- Destination cup now points to the first picked cup.
		next_cup[p3] = after_destination -- Last picked cup now points to what was after the destination.

		-- 4. Select the new current cup.
		current_cup = next_cup[current_cup]
	end

	-- Construct the final string by starting from the cup after 1.
	local result = ""
	local cup = next_cup[1]
	for _ = 1, num_cups - 1 do
		result = result .. cup
		cup = next_cup[cup]
	end

	return result
end

--- @description: Simulate with 1M cups, 10M moves
--- @param input string: the puzzle input
--- @return number: the product of the two cups after cup 1
function M.part2(input)
	local num_cups = 1000000
	local num_moves = 10000000

	-- Efficiently build the linked list directly.
	local next_cup = {}
	local cups_raw = {}
	for i = 1, #input do
		cups_raw[i] = tonumber(input:sub(i, i))
	end

	-- Link the initial cups from the input string.
	for i = 1, #cups_raw - 1 do
		next_cup[cups_raw[i]] = cups_raw[i + 1]
	end

	-- Link the last input cup to cup 10, and then chain the rest up to 1M.
	local last_cup = cups_raw[#cups_raw]
	if num_cups > #cups_raw then
		next_cup[last_cup] = #cups_raw + 1
		for i = #cups_raw + 1, num_cups - 1 do
			next_cup[i] = i + 1
		end
		last_cup = num_cups
	end

	-- Complete the circle.
	next_cup[last_cup] = cups_raw[1]

	local current_cup = cups_raw[1]

	for _ = 1, num_moves do
		-- This logic is identical to Part 1, just with different parameters.
		local p1 = next_cup[current_cup]
		local p2 = next_cup[p1]
		local p3 = next_cup[p2]

		local destination_cup = current_cup - 1
		while true do
			if destination_cup < 1 then
				destination_cup = num_cups
			end
			if destination_cup ~= p1 and destination_cup ~= p2 and destination_cup ~= p3 then
				break
			end
			destination_cup = destination_cup - 1
		end

		local after_picked = next_cup[p3]
		local after_destination = next_cup[destination_cup]

		next_cup[current_cup] = after_picked
		next_cup[destination_cup] = p1
		next_cup[p3] = after_destination

		current_cup = next_cup[current_cup]
	end

	local c1 = next_cup[1]
	local c2 = next_cup[c1]
	return c1 * c2
end

return M
