--- @title: --- Day 5: Doesn't He Have Intern-Elves For This? ---
--- @description: Read the input file line by line. Check if the string is nice. If it is, count it. Return the count
local util = require("util")
local M = {}

--- @function: Check if a string is nice
--- @param s string: string to check
--- @return boolean: true if the string is nice
local function is_nice_part1(s)
	local vowel_count = 0
	local has_double = false
	local forbidden = { "ab", "cd", "pq", "xy" }
	local vowels = { a = true, e = true, i = true, o = true, u = true }

	-- Count vowels
	for i = 1, #s do
		local c = s:sub(i, i)
		if vowels[c] then
			vowel_count = vowel_count + 1
		end
		-- Check for double letters
		if i < #s and c == s:sub(i + 1, i + 1) then
			has_double = true
		end
	end

	-- Check for forbidden substrings
	local has_forbidden = false
	for _, f in ipairs(forbidden) do
		if s:find(f) then
			has_forbidden = true
			break
		end
	end

	--- Check if all conditions are met
	return vowel_count >= 3 and has_double and not has_forbidden
end

--- @function: Check if a string is nice with the new rules for part 2
--- @param s string
--- @return boolean
local function is_nice_part2(s)
	local has_pair = false
	local has_repeat = false

	-- Check for pair appearing twice without overlapping
	for i = 1, #s - 1 do
		local pair = s:sub(i, i + 1)
		local found = s:find(pair, i + 2)
		if found then
			has_pair = true
			break
		end
	end

	-- Check for letter repeating with one in between
	for i = 1, #s - 2 do
		if s:sub(i, i) == s:sub(i + 2, i + 2) then
			has_repeat = true
			break
		end
	end

	return has_pair and has_repeat
end

--- @description Count number of nice strings for part 1
--- @param input string
--- @return integer
function M.part1(input)
	local lines = util.read_lines(input)
	local count = 0
	for _, line in ipairs(lines) do
		if is_nice_part1(line) then
			count = count + 1
		end
	end
	return count
end

--- @description Count number of nice strings for part 2
--- @param input string
--- @return integer
function M.part2(input)
	local lines = util.read_lines(input)
	local count = 0
	for _, line in ipairs(lines) do
		if is_nice_part2(line) then
			count = count + 1
		end
	end
	return count
end

return M
