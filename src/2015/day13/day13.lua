--- @title: Day 13: Knights of the Dinner Table ---
local M = {}

--- @function: Parse input into a table
--- @param input string
--- @return table, table
local function parse_input(input)
	local people = {}
	local hap = {}
	for line in input:gmatch("[^\n]+") do
		local a, sign, x, b = line:match("(%w+) would (%w+) (%d+) happiness units by sitting next to (%w+).")
		if a and b then
			people[a] = true
			people[b] = true
			hap[a] = hap[a] or {}
			hap[a][b] = (sign == "gain" and 1 or -1) * tonumber(x)
		end
	end
	local person_list = {}
	for p in pairs(people) do
		table.insert(person_list, p)
	end
	return person_list, hap
end

--- @function: Calculate the maximum happiness
--- @param person_list table
--- @param hap table
--- @return number
local function calculate_max_happiness(person_list, hap)
	local max_hap = -math.huge
	local function find_max(perm, used)
		if #perm == #person_list then
			local total = 0
			for i = 1, #perm - 1 do
				total = total + hap[perm[i]][perm[i + 1]] + hap[perm[i + 1]][perm[i]]
			end
			total = total + hap[perm[#perm]][perm[1]] + hap[perm[1]][perm[#perm]]
			if total > max_hap then
				max_hap = total
			end
			return
		end
		for _, p in ipairs(person_list) do
			if not used[p] then
				used[p] = true
				table.insert(perm, p)
				find_max(perm, used)
				table.remove(perm)
				used[p] = false
			end
		end
	end
	local used = {}
	find_max({}, used)
	return max_hap
end

--- @description Run the solution
--- @param input string
--- @return number
function M.part1(input)
	local person_list, hap = parse_input(input)
	return calculate_max_happiness(person_list, hap)
end

--- @description Run the solution
--- @param input string
--- @return number
function M.part2(input)
	local person_list, hap = parse_input(input)
	table.insert(person_list, "Me")
	hap["Me"] = {}
	for _, p in ipairs(person_list) do
		if p ~= "Me" then
			hap["Me"][p] = 0
			hap[p]["Me"] = 0
		end
	end
	return calculate_max_happiness(person_list, hap)
end

return M
