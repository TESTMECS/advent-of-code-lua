--- @title: Day 16: Aunt Sue
local M = {}

--- @description: Parse input string
--- @param input string
--- @return table
local function parse_input(input)
	local sues = {}
	for line in input:gmatch("[^\n]+") do
		local sue = {}
		local num = line:match("Sue (%d+):")
		for prop, val in line:gmatch("(%w+): (%d+)") do
			sue[prop] = tonumber(val)
		end
		sues[tonumber(num)] = sue
	end
	return sues
end

--- @description: Check if sue matches gift
--- @param sue table
--- @param gift table
--- @return boolean
local function matches1(sue, gift)
	for prop, val in pairs(sue) do
		if gift[prop] and gift[prop] ~= val then
			return false
		end
	end
	return true
end

--- @description: Check if sue matches gift
--- @param sue table
--- @param gift table
--- @return boolean
local function matches2(sue, gift)
	local greater = { cats = true, trees = true }
	local lesser = { pomeranians = true, goldfish = true }
	for prop, val in pairs(sue) do
		if gift[prop] then
			if greater[prop] then
				if val <= gift[prop] then
					return false
				end
			elseif lesser[prop] then
				if val >= gift[prop] then
					return false
				end
			else
				if val ~= gift[prop] then
					return false
				end
			end
		end
	end
	return true
end

--- @description: what is the number of the Sue that got you the gift?
--- @param input string
--- @return integer
function M.part1(input)
	local gift = {
		children = 3,
		cats = 7,
		samoyeds = 2,
		pomeranians = 3,
		akitas = 0,
		vizslas = 0,
		goldfish = 5,
		trees = 3,
		cars = 2,
		perfumes = 1,
	}
	local sues = parse_input(input)
	for i, sue in pairs(sues) do
		if matches1(sue, gift) then
			return i
		end
	end
	return 0
end

--- @description: what is the number of the real Aunt Sue?
--- @param input string
--- @return integer
function M.part2(input)
	local gift = {
		children = 3,
		cats = 7,
		samoyeds = 2,
		pomeranians = 3,
		akitas = 0,
		vizslas = 0,
		goldfish = 5,
		trees = 3,
		cars = 2,
		perfumes = 1,
	}
	local sues = parse_input(input)
	for i, sue in pairs(sues) do
		if matches2(sue, gift) then
			return i
		end
	end
	return 0
end

return M
