--- @title: Day 19: Medicine for Rudolph ---
local M = {}
local util = require("util")

--- @function: Parse the molecules and the replacements
--- @param input_str string
--- @return table, table, string
local function parse(input_str)
	local lines = util.read_lines(input_str)
	local map = {}
	local pam = {}
	local molecule
	for i, line in ipairs(lines) do
		if line == "" or line:match("^%s*$") then
			molecule = lines[i + 1]
			break
		end
		local parts = util.split(line, " => ")
		if #parts == 2 then
			local k = parts[1]
			local v = parts[2]
			if not map[k] then
				map[k] = {}
			end
			table.insert(map[k], v)
			pam[v] = k
		end
	end
	if not molecule then
		molecule = lines[#lines]
	end
	return map, pam, molecule
end

--- @function: Replace all occurences of pattern with repl
--- @param s string
--- @param pattern string
--- @param repl string
--- @return table
local function rep(s, pattern, repl)
	local res = {}
	local idx = 1
	while true do
		local start, stop = string.find(s, pattern, idx, true)
		if not start then
			break
		else
			local before = string.sub(s, 1, start - 1)
			local behind = string.sub(s, stop + 1)
			table.insert(res, before .. repl .. behind)
			idx = stop + 1
		end
	end
	return res
end

--- @function: Calibrate the replacements
--- @param map table
--- @param molecule string
--- @return table
local function calibrate(map, molecule)
	local molecules = {}
	for k, ps in pairs(map) do
		for _, p in ipairs(ps) do
			local reps = rep(molecule, k, p)
			for _, r in ipairs(reps) do
				molecules[r] = (molecules[r] or 0) + 1
			end
		end
	end
	return molecules
end

--- @function: Fabricate the molecule
--- @param pam table
--- @param molecule string
--- @return integer
local function fabricate(pam, molecule)
	local step = 0
	local patterns = util.keyset(pam)
	table.sort(patterns, function(a, b)
		return #a > #b
	end)
	while molecule ~= "e" and step < 300 do
		local replaced = false
		for _, l in ipairs(patterns) do
			local r = pam[l]
			if molecule:find(l, 1, true) then
				molecule = molecule:gsub(l, r, 1)
				step = step + 1
				replaced = true
				break
			end
		end
		if not replaced then
			return -1
		end
	end
	return step
end

--- @description: Day 19: Medicine for Rudolph
--- @param input string	The input
--- @return integer
function M.part1(input)
	local map, _, molecule = parse(input)
	local replacements = calibrate(map, molecule)
	return util.numel(replacements)
end

--- @description: Day 19: Medicine for Rudolph
--- @param input string	The input
--- @return integer
function M.part2(input)
	local _, pam, molecule = parse(input)
	return fabricate(pam, molecule)
end

return M
