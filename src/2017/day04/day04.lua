--- @title: Day 4: High-Entropy Passphrases ---
local M = {}

--- @description Count valid passphrases with no duplicate words
--- @param input string the list of passphrases
--- @return number the count of valid passphrases
function M.part1(input)
	local count = 0
	-- Iterate over each line (passphrase)
	for line in input:gmatch("[^\n]+") do
		local seen = {}
		local valid = true
		-- Check each word in the line
		for word in line:gmatch("%S+") do
			if seen[word] then
				valid = false
				break
			end
			seen[word] = true
		end
		if valid then
			count = count + 1
		end
	end
	return count
end

--- @description Count valid passphrases with no anagram duplicates
--- @param input string the list of passphrases
--- @return number the count of valid passphrases
function M.part2(input)
	local count = 0
	-- Iterate over each line (passphrase)
	for line in input:gmatch("[^\n]+") do
		local seen = {}
		local valid = true
		-- Check each word in the line
		for word in line:gmatch("%S+") do
			-- Create signature by sorting characters
			local chars = {}
			for c in word:gmatch(".") do
				table.insert(chars, c)
			end
			table.sort(chars)
			local sig = table.concat(chars)
			if seen[sig] then
				valid = false
				break
			end
			seen[sig] = true
		end
		if valid then
			count = count + 1
		end
	end
	return count
end

return M
