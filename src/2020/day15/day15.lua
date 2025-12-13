--- @title: Day 15: Rambunctious Recitation ---
local M = {}

--- @description: Find the 2020th number spoken
--- @param input string: the puzzle input
--- @return number: the number
function M.part1(input)
	local starting = {}
	for num in input:gmatch("%d+") do
		table.insert(starting, tonumber(num))
	end
	local turns = {}
	for i, num in ipairs(starting) do
		turns[num] = turns[num] or {}
		table.insert(turns[num], i)
	end
	local said = starting[#starting]
	for turn = #starting + 1, 2020 do
		local prev_num = said
		local tlist = turns[prev_num]
		if #tlist >= 2 then
			said = tlist[#tlist] - tlist[#tlist - 1]
		else
			said = 0
		end
		table.insert(tlist, turn - 1)
		if #tlist > 2 then
			table.remove(tlist, 1)
		end
		turns[said] = turns[said] or {}
		table.insert(turns[said], turn)
		if #turns[said] > 2 then
			table.remove(turns[said], 1)
		end
	end
	return said
end

--- @description: Find the 30000000th number spoken
--- @param input string: the puzzle input
--- @return number: the number
function M.part2(input)
	local starting = {}
	for num in input:gmatch("%d+") do
		table.insert(starting, tonumber(num))
	end
	local turns = {}
	for i, num in ipairs(starting) do
		turns[num] = turns[num] or {}
		table.insert(turns[num], i)
	end
	local said = starting[#starting]
	for turn = #starting + 1, 30000000 do
		local prev_num = said
		local tlist = turns[prev_num]
		if #tlist >= 2 then
			said = tlist[#tlist] - tlist[#tlist - 1]
		else
			said = 0
		end
		table.insert(tlist, turn - 1)
		if #tlist > 2 then
			table.remove(tlist, 1)
		end
		turns[said] = turns[said] or {}
		table.insert(turns[said], turn)
		if #turns[said] > 2 then
			table.remove(turns[said], 1)
		end
	end
	return said
end

return M
