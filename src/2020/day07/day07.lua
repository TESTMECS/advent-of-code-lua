--- @title: Day 7: Handy Haversacks ---
local M = {}
local util = require("util")

--- @description: Count bags that can contain shiny gold
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local lines = util.read_lines(input)
	local reverse_rules = {}
	for _, line in ipairs(lines) do
		local outer = line:match("(.+) bags contain")
		if line:find("no other bags") then
			-- no inner
		else
			for num, color in line:gmatch("(%d+) ([^,]+) bag") do
				reverse_rules[color] = reverse_rules[color] or {}
				table.insert(reverse_rules[color], outer)
			end
		end
	end
	local visited = {}
	local queue = { "shiny gold" }
	while #queue > 0 do
		local bag = table.remove(queue, 1)
		if not visited[bag] then
			visited[bag] = true
			for _, parent in ipairs(reverse_rules[bag] or {}) do
				table.insert(queue, parent)
			end
		end
	end
	local count = 0
	for _ in pairs(visited) do
		count = count + 1
	end
	return count - 1 -- exclude shiny gold itself
end

--- @description: Count bags inside shiny gold
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local lines = util.read_lines(input)
	local rules = {}
	for _, line in ipairs(lines) do
		local outer = line:match("(.+) bags contain")
		local contents = {}
		if not line:find("no other bags") then
			for num, color in line:gmatch("(%d+) ([^,]+) bag") do
				table.insert(contents, { tonumber(num), color })
			end
		end
		rules[outer] = contents
	end
	local function count_bags(bag)
		local total = 0
		for _, inner in ipairs(rules[bag] or {}) do
			total = total + inner[1] * (1 + count_bags(inner[2]))
		end
		return total
	end
	return count_bags("shiny gold")
end

return M
