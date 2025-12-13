--- @title: --- Day 15: Lens Library ---
local M = {}
local util = require("util")

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local res = 0
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		for pattern in line:gmatch("([^,]+)") do
			local x = 0
			for i = 1, #pattern do
				x = ((x + string.byte(pattern:sub(i, i))) * 17) % 256
			end
			res = res + x
		end
	end

	return res
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local function hash(s)
		local x = 0
		for i = 1, #s do
			x = ((x + string.byte(s:sub(i, i))) * 17) % 256
		end
		return x
	end
	local res = 0
	local boxes = {}
	local i = 0
	local lines = util.read_lines(input)
	for _, line in ipairs(lines) do
		line = line .. ","
		for pattern in line:gmatch("([^,]+),") do
			for code, lens in pattern:gmatch("([^=-]+)=(%d+)") do
				local box = hash(code)
				boxes[box] = boxes[box] or {}
				boxes[box][code] = boxes[box][code] and { lens, boxes[box][code][2] } or { lens, i }
			end
			for code in pattern:gmatch("([^=-]+)-") do
				local box = hash(code)
				boxes[box] = boxes[box] or {}
				boxes[box][code] = nil
			end
			i = i + 1
		end
	end
	for box = 0, 255 do
		if boxes[box] then
			local lenses = {}
			for _, v in pairs(boxes[box]) do
				table.insert(lenses, v)
			end
			table.sort(lenses, function(a, b)
				return a[2] < b[2]
			end)
			for i, v in ipairs(lenses) do
				res = res + (box + 1) * i * v[1]
			end
		end
	end
	return res
end

return M
