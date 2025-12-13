local util = require("src.util")
local M = {}
local ex <const> = [[
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
]]
---@description ecludian distance for d^3
-- sqrt[ (px - qx)^2 + (py - qy)^2 + (pz - qz)^2 ]
local function distance(p, q)
	return math.sqrt((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2 + (p.z - q.z) ^ 2)
end
---@return dists, table<number, number>, Box
local function parse_input(input)
	---@class Box
	---@field x number
	---@field y number
	---@field z number
	---@field i number
	---@field c number
	local boxes = {}
	---@type string[]
	local lines = util.read_lines(input)
	-- Parse input into boxes
	for i, line in ipairs(lines) do
		local x, y, z = line:match("(%d+),(%d+),(%d+)")
		table.insert(boxes, { x = x, y = y, z = z, i = i, c = i })
	end
	---@class dists distances between two points.
	---@field i number index first point
	---@field j number second point
	---@field dist number distance between them
	local dists = {}
	---@type table<number, number> tracks the idx and number of boxes in the circuit
	local circ = {}
	-- Find all distances btw boxes/points.
	for i, p in ipairs(boxes) do
		circ[i] = i
		for j = i + 1, #boxes do
			local q = boxes[j]
			table.insert(dists, {
				i = i,
				j = j,
				dist = distance(p, q),
			})
		end
	end
	-- Sort distances
	table.sort(dists, function(a, b)
		return a.dist < b.dist
	end)
	return dists, circ, boxes
end

function M.part1(input)
	local dists, circ, boxes = parse_input(input)
	local N = 1000 ---@type number
	if #boxes < 100 then -- guard for part1 example
		N = 10
	end
	for i, d in ipairs(dists) do
		if i > N then
			break
		end
		local circ1 = circ[d.i]
		local circ2 = circ[d.j]
		for k, v in pairs(circ) do
			if v == circ2 then
				circ[k] = circ1
			end
		end
	end
	local circSizes = {}
	for _, c in pairs(circ) do
		circSizes[c] = (circSizes[c] or 0) + 1
	end
	local sizes = {}
	for _, s in pairs(circSizes) do
		table.insert(sizes, s)
	end
	table.sort(sizes)
	local n = #sizes
	return sizes[n] * sizes[n - 1] * sizes[n - 2]
end

function M.part2(input)
	local dists, circ, boxes = parse_input(input)
	for _, d in ipairs(dists) do
		local circ1 = circ[d.i]
		local circ2 = circ[d.j]
		local con = true
		for k, v in pairs(circ) do
			if v == circ2 then
				circ[k] = circ1
			elseif v ~= circ1 then
				con = false
			end
		end
		if con then
			return boxes[d.i].x * boxes[d.j].x
		end
	end
end

return M
