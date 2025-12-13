--- @title: --- Day 19: Beacon Scanner ---
local M = {}

--- @description Count the number of unique beacons
--- @param input string the puzzle input
--- @return number the count of beacons
function M.part1(input)
	local scanners = {}
	local current = nil
	for line in input:gmatch("[^\n]+") do
		if line:match("--- scanner %d+ ---") then
			current = {}
			table.insert(scanners, current)
		elseif line ~= "" then
			local x, y, z = line:match("(%-?%d+),(%-?%d+),(%-?%d+)")
			table.insert(current, { tonumber(x), tonumber(y), tonumber(z) })
		end
	end
	local function rotate(point, rot)
		local x, y, z = point[1], point[2], point[3]
		if rot == 1 then
			return { x, y, z }
		elseif rot == 2 then
			return { x, -z, y }
		elseif rot == 3 then
			return { x, -y, -z }
		elseif rot == 4 then
			return { x, z, -y }
		elseif rot == 5 then
			return { -x, -y, z }
		elseif rot == 6 then
			return { -x, -z, -y }
		elseif rot == 7 then
			return { -x, y, -z }
		elseif rot == 8 then
			return { -x, z, y }
		elseif rot == 9 then
			return { y, z, x }
		elseif rot == 10 then
			return { y, -x, z }
		elseif rot == 11 then
			return { y, -z, -x }
		elseif rot == 12 then
			return { y, x, -z }
		elseif rot == 13 then
			return { -y, -z, x }
		elseif rot == 14 then
			return { -y, -x, -z }
		elseif rot == 15 then
			return { -y, x, z }
		elseif rot == 16 then
			return { -y, z, -x }
		elseif rot == 17 then
			return { z, x, y }
		elseif rot == 18 then
			return { z, -y, x }
		elseif rot == 19 then
			return { z, -x, -y }
		elseif rot == 20 then
			return { z, y, -x }
		elseif rot == 21 then
			return { -z, -x, y }
		elseif rot == 22 then
			return { -z, -y, -x }
		elseif rot == 23 then
			return { -z, x, -y }
		elseif rot == 24 then
			return { -z, y, x }
		end
	end
	local function find_overlap(s1, s2)
		for rot = 1, 24 do
			local rotated = {}
			for _, p in ipairs(s2) do
				table.insert(rotated, rotate(p, rot))
			end
			local counts = {}
			for _, p1 in ipairs(s1) do
				for _, p2 in ipairs(rotated) do
					local dx = p1[1] - p2[1]
					local dy = p1[2] - p2[2]
					local dz = p1[3] - p2[3]
					local key = dx .. "," .. dy .. "," .. dz
					counts[key] = (counts[key] or 0) + 1
				end
			end
			for key, count in pairs(counts) do
				if count >= 12 then
					local dx, dy, dz = key:match("(%-?%d+),(%-?%d+),(%-?%d+)")
					dx, dy, dz = tonumber(dx), tonumber(dy), tonumber(dz)
					local translated = {}
					for _, p in ipairs(rotated) do
						table.insert(translated, { p[1] + dx, p[2] + dy, p[3] + dz })
					end
					return translated, { dx, dy, dz }
				end
			end
		end
		return nil
	end
	local merged = { scanners[1] }
	local positions = { { 0, 0, 0 } }
	local remaining = {}
	for i = 2, #scanners do
		table.insert(remaining, i)
	end
	while #remaining > 0 do
		local found = false
		for i, idx in ipairs(remaining) do
			for _, m in ipairs(merged) do
				local overlap, pos = find_overlap(m, scanners[idx])
				if overlap then
					table.insert(merged, overlap)
					table.insert(positions, pos)
					table.remove(remaining, i)
					found = true
					break
				end
			end
			if found then
				break
			end
		end
		if not found then
			break
		end
	end
	local beacons = {}
	for _, m in ipairs(merged) do
		for _, p in ipairs(m) do
			local key = p[1] .. "," .. p[2] .. "," .. p[3]
			beacons[key] = true
		end
	end
	local count = 0
	for _ in pairs(beacons) do
		count = count + 1
	end
	return count
end

--- @description Find the maximum Manhattan distance between any two scanners
--- @param input string the puzzle input
--- @return number the maximum distance
function M.part2(input)
	local scanners = {}
	local current = nil
	for line in input:gmatch("[^\n]+") do
		if line:match("--- scanner %d+ ---") then
			current = {}
			table.insert(scanners, current)
		elseif line ~= "" then
			local x, y, z = line:match("(%-?%d+),(%-?%d+),(%-?%d+)")
			table.insert(current, { tonumber(x), tonumber(y), tonumber(z) })
		end
	end
	local function rotate(point, rot)
		local x, y, z = point[1], point[2], point[3]
		if rot == 1 then
			return { x, y, z }
		elseif rot == 2 then
			return { x, -z, y }
		elseif rot == 3 then
			return { x, -y, -z }
		elseif rot == 4 then
			return { x, z, -y }
		elseif rot == 5 then
			return { -x, -y, z }
		elseif rot == 6 then
			return { -x, -z, -y }
		elseif rot == 7 then
			return { -x, y, -z }
		elseif rot == 8 then
			return { -x, z, y }
		elseif rot == 9 then
			return { y, z, x }
		elseif rot == 10 then
			return { y, -x, z }
		elseif rot == 11 then
			return { y, -z, -x }
		elseif rot == 12 then
			return { y, x, -z }
		elseif rot == 13 then
			return { -y, -z, x }
		elseif rot == 14 then
			return { -y, -x, -z }
		elseif rot == 15 then
			return { -y, x, z }
		elseif rot == 16 then
			return { -y, z, -x }
		elseif rot == 17 then
			return { z, x, y }
		elseif rot == 18 then
			return { z, -y, x }
		elseif rot == 19 then
			return { z, -x, -y }
		elseif rot == 20 then
			return { z, y, -x }
		elseif rot == 21 then
			return { -z, -x, y }
		elseif rot == 22 then
			return { -z, -y, -x }
		elseif rot == 23 then
			return { -z, x, -y }
		elseif rot == 24 then
			return { -z, y, x }
		end
	end
	local function find_overlap(s1, s2)
		for rot = 1, 24 do
			local rotated = {}
			for _, p in ipairs(s2) do
				table.insert(rotated, rotate(p, rot))
			end
			local counts = {}
			for _, p1 in ipairs(s1) do
				for _, p2 in ipairs(rotated) do
					local dx = p1[1] - p2[1]
					local dy = p1[2] - p2[2]
					local dz = p1[3] - p2[3]
					local key = dx .. "," .. dy .. "," .. dz
					counts[key] = (counts[key] or 0) + 1
				end
			end
			for key, count in pairs(counts) do
				if count >= 12 then
					local dx, dy, dz = key:match("(%-?%d+),(%-?%d+),(%-?%d+)")
					dx, dy, dz = tonumber(dx), tonumber(dy), tonumber(dz)
					local translated = {}
					for _, p in ipairs(rotated) do
						table.insert(translated, { p[1] + dx, p[2] + dy, p[3] + dz })
					end
					return translated, { dx, dy, dz }
				end
			end
		end
		return nil
	end
	local merged = { scanners[1] }
	local positions = { { 0, 0, 0 } }
	local remaining = {}
	for i = 2, #scanners do
		table.insert(remaining, i)
	end
	while #remaining > 0 do
		local found = false
		for i, idx in ipairs(remaining) do
			for _, m in ipairs(merged) do
				local overlap, pos = find_overlap(m, scanners[idx])
				if overlap then
					table.insert(merged, overlap)
					table.insert(positions, pos)
					table.remove(remaining, i)
					found = true
					break
				end
			end
			if found then
				break
			end
		end
		if not found then
			break
		end
	end
	local max_dist = 0
	for i = 1, #positions do
		for j = i + 1, #positions do
			local dx = math.abs(positions[i][1] - positions[j][1])
			local dy = math.abs(positions[i][2] - positions[j][2])
			local dz = math.abs(positions[i][3] - positions[j][3])
			local dist = dx + dy + dz
			max_dist = math.max(max_dist, dist)
		end
	end
	return max_dist
end

return M
