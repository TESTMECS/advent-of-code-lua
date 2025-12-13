 --- @title: Day 15: Beacon Exclusion Zone ---
local M = {}

local function parse_sensors(input)
	local sensors = {}
	for line in input:gmatch("[^\n]+") do
		local sx, sy, bx, by = line:match("Sensor at x=(%-?%d+), y=(%-?%d+): closest beacon is at x=(%-?%d+), y=(%-?%d+)")
		sx, sy, bx, by = tonumber(sx), tonumber(sy), tonumber(bx), tonumber(by)
		local dist = math.abs(sx - bx) + math.abs(sy - by)
		table.insert(sensors, { sx = sx, sy = sy, bx = bx, by = by, dist = dist })
	end
	return sensors
end

local function merge_intervals(intervals)
	if #intervals == 0 then return {} end
	table.sort(intervals, function(a, b) return a[1] < b[1] end)
	local merged = {}
	local current = intervals[1]
	for i = 2, #intervals do
		if current[2] >= intervals[i][1] then
			current[2] = math.max(current[2], intervals[i][2])
		else
			table.insert(merged, current)
			current = intervals[i]
		end
	end
	table.insert(merged, current)
	return merged
end

--- @description Count positions where beacon cannot be at y=2000000
--- @param input string the puzzle input
--- @return number the count
function M.part1(input)
	local sensors = parse_sensors(input)
	local y = 2000000
	local intervals = {}
	for _, s in ipairs(sensors) do
		local dy = math.abs(s.sy - y)
		if dy <= s.dist then
			local dx = s.dist - dy
			local left = s.sx - dx
			local right = s.sx + dx
			table.insert(intervals, { left, right })
		end
	end
	local merged = merge_intervals(intervals)
	local total = 0
	for _, int in ipairs(merged) do
		total = total + int[2] - int[1] + 1
	end
	-- subtract beacons
	local beacons = {}
	for _, s in ipairs(sensors) do
		if s.by == y then beacons[s.bx] = true end
	end
	for bx in pairs(beacons) do
		for _, int in ipairs(merged) do
			if bx >= int[1] and bx <= int[2] then
				total = total - 1
				break
			end
		end
	end
	return total
end

--- @description Find the distress beacon position
--- @param input string the puzzle input
--- @return number the tuning frequency
function M.part2(input)
	local sensors = parse_sensors(input)
	local max_coord = 4000000
	for y = 0, max_coord do
		local intervals = {}
		for _, s in ipairs(sensors) do
			local dy = math.abs(s.sy - y)
			if dy <= s.dist then
				local dx = s.dist - dy
				local left = math.max(0, s.sx - dx)
				local right = math.min(max_coord, s.sx + dx)
				table.insert(intervals, { left, right })
			end
		end
		local merged = merge_intervals(intervals)
		local covered = true
		if #merged == 0 or merged[1][1] > 0 or merged[#merged][2] < max_coord then
			covered = false
		else
			for i = 1, #merged - 1 do
				if merged[i][2] + 1 < merged[i + 1][1] then
					covered = false
					break
				end
			end
		end
		if not covered then
			local x
			if #merged == 0 then
				x = 0
			elseif merged[1][1] > 0 then
				x = 0
			else
				for i = 1, #merged - 1 do
					if merged[i][2] + 1 < merged[i + 1][1] then
						x = merged[i][2] + 1
						break
					end
				end
				if not x and merged[#merged][2] < max_coord then
					x = max_coord
				end
			end
			return x * 4000000 + y
		end
	end
	return 0
end

return M
