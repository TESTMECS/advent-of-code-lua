local util = require("src.util")
local M = {}
local ex = [[
3-5
10-14
16-20
12-18

1
5
8
11
17
32
]]

-- Range class
---@alias Range {start: integer, stop: integer}
local Range = {}
Range.__index = Range
function Range:new(start, stop)
	return setmetatable({ start = start, stop = stop }, self)
end
--- @description Trims whitespace from the start and end of a string.
local function trim(s)
	return s:match("^%s*(.-)%s*$")
end
--- @description Parses the input into a list of ranges and numbers.
--- @alias idx number
--- @return table<idx, Range>, table<idx, number>
local function PARSE_INPUT(input)
	local lines = util.split(input, "\n")
	local blank -- index of first blank (whitespace-only) line
	local ranges, nums = {}, {}
	-- find blank line (whitespace-only). If none, look for first non-range line.
	for i, raw in ipairs(lines) do
		local line = raw:gsub("\r$", "")
		if line:match("^%s*$") then
			blank = i
			break
		end
	end
	-- fallback if util.split removed empty lines
	if not blank then
		for i, raw in ipairs(lines) do
			local line = raw:gsub("\r$", ""):match("^%s*(.-)%s*$")
			if not line:match("^%d+%-%d+$") then
				blank = i
				break
			end
		end
	end
	if not blank then
		error("missing separator between ranges and numbers")
	end
	-- parse ranges (lines 1 .. blank-1)
	for i = 1, math.max(0, blank - 1) do
		local raw = lines[i]:gsub("\r$", "")
		raw = trim(raw)
		if raw ~= "" then
			local a_s, b_s = raw:match("^(%S+)%-(%S+)$")
			if a_s and b_s then
				local a = tonumber(trim(a_s))
				local b = tonumber(trim(b_s))
				if a and b then
					table.insert(ranges, Range:new(a, b))
				end
			end
		end
	end
	-- parse numbers (lines after blank)
	for i = blank, #lines do
		local raw = lines[i]:gsub("\r$", "")
		local s = trim(raw)
		if s ~= "" then
			local n = tonumber(s)
			if n then
				table.insert(nums, n)
			end
		end
	end
	return ranges, nums
end
--- @description Checks if a number is in a range.
local function IS_IN_RANGE(n, ranges)
	for _, r in ipairs(ranges) do
		if n >= r.start and n <= r.stop then
			return true
		end
	end
	return false
end
--- @description Counts the amount of numbers(Bottom of input) inside ranges(Top of input) <_<
function M.part1(input)
	local ranges, nums = PARSE_INPUT(input)
	local count = 0
	for _, n in ipairs(nums) do
		if IS_IN_RANGE(n, ranges) then
			count = count + 1
		end
	end
	return count
end
--- @description Counts the amount of unique numbers inside ranges.
--- @param ranges table<idx, Range>
--- @return number
local function COUNT_UNIQUE(ranges)
	if #ranges == 0 then
		return 0
	end
	-- sort in-place
	table.sort(ranges, function(a, b)
		return a.start < b.start
	end)
	local cs = ranges[1].start
	local ce = ranges[1].stop
	local total = 0
	for i = 2, #ranges do
		local r = ranges[i]
		if r.start <= ce + 1 then
			if r.stop > ce then
				ce = r.stop
			end
		else
			total = total + (ce - cs + 1)
			cs, ce = r.start, r.stop
		end
	end

	total = total + (ce - cs + 1)
	return total
end

--- @description Counts the amount of unique numbers inside ranges.
function M.part2(input)
	local ranges, _ = PARSE_INPUT(input)
	local count = COUNT_UNIQUE(ranges)
	return count
end

return M
