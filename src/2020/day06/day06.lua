--- @title: Day 6: Custom Customs ---
local M = {}

--- @description Sum the counts of unique yes answers per group
--- @param input string the puzzle input
--- @return number the sum
function M.part1(input)
	input = input:gsub("\r", "")
	local groups = {}
	for group in input:gmatch("(.-)\n\n") do
		table.insert(groups, group)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(groups, last)
	end
	local total = 0
	for _, group in ipairs(groups) do
		local people = {}
		for person in group:gmatch("[^\n]+") do
			table.insert(people, person)
		end
		local yes = {}
		for _, person in ipairs(people) do
			for i = 1, #person do
				yes[person:sub(i, i)] = true
			end
		end
		local count = 0
		for _ in pairs(yes) do
			count = count + 1
		end
		total = total + count
	end
	return total
end

--- @description Sum the counts of questions answered yes by everyone per group
--- @param input string the puzzle input
--- @return number the sum
function M.part2(input)
	input = input:gsub("\r", "")
	local groups = {}
	for group in input:gmatch("(.-)\n\n") do
		table.insert(groups, group)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(groups, last)
	end
	local total = 0
	for _, group in ipairs(groups) do
		local people = {}
		for person in group:gmatch("[^\n]+") do
			table.insert(people, person)
		end
		local num_people = #people
		local yes_count = {}
		for _, person in ipairs(people) do
			for i = 1, #person do
				local q = person:sub(i, i)
				yes_count[q] = (yes_count[q] or 0) + 1
			end
		end
		local count = 0
		for _, c in pairs(yes_count) do
			if c == num_people then
				count = count + 1
			end
		end
		total = total + count
	end
	return total
end

return M
