--- @title: --- Day 22: Sand Slabs ---
local M = {}

--- @description Counts bricks that can be safely disintegrated without causing others to fall
--- @param input string: the puzzle input
--- @return number: count of safe bricks
function M.part1(input)
	local blocks, forward, backward, map = {}, {}, {}, {}
	local maxX, maxY = 0, 0
	for line in input:gmatch("[^\r\n]+") do
		for x1, y1, z1, x2, y2, z2 in line:gmatch("(%d+),(%d+),(%d+)~(%d+),(%d+),(%d+)") do
			x1, x2, y1, y2, z1, z2 = tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2), tonumber(z1), tonumber(z2)
			table.insert(blocks, { { x1, y1, z1 }, { x2, y2, z2 } })
			maxX, maxY = math.max(maxX, x1, x2), math.max(maxY, y1, y2)
		end
	end
	local function key(x)
		return tostring(x[1]) .. "|" .. tostring(x[2])
	end
	local function insertIntoMap(x, y, z, name)
		if map[key({ x, y })] and map[key({ x, y })][2] ~= name then
			local prev = map[key({ x, y })]
			if prev[1] + 1 == z then
				forward[prev[2]] = forward[prev[2]] or {}
				forward[prev[2]][name] = true
				backward[name] = backward[name] or {}
				backward[name][prev[2]] = true
			end
		end
		map[key({ x, y })] = { z, name }
	end
	local function applyBlock(block, name)
		local pos1, pos2 = table.unpack(block)
		local x1, y1, z1 = table.unpack(pos1)
		local x2, y2, z2 = table.unpack(pos2)
		if x1 == x2 and y1 == y2 then
			-- Vertical brick
			local top = (map[key({ x1, y1 })] or { 0, "" })[1]
			local height = z2 - z1 + 1
			for i = 1, height do
				insertIntoMap(x1, y1, top + i, name)
			end
		elseif x1 == x2 then
			-- Horizontal in y direction
			local top = 0
			for i = y1, y2 do
				top = math.max(top, (map[key({ x1, i })] or { 0, "" })[1])
			end
			for i = y1, y2 do
				insertIntoMap(x1, i, top + 1, name)
			end
		elseif y1 == y2 then
			-- Horizontal in x direction
			local top = 0
			for i = x1, x2 do
				top = math.max(top, (map[key({ i, y1 })] or { 0, "" })[1])
			end
			for i = x1, x2 do
				insertIntoMap(i, y1, top + 1, name)
			end
		end
	end
	table.sort(blocks, function(a, b)
		return a[1][3] < b[1][3]
	end)
	for i, block in ipairs(blocks) do
		applyBlock(block, i)
	end
	local function len(x)
		local c = 0
		for n in pairs(x) do
			c = c + 1
		end
		return c
	end

	local result = 0
	for block, _ in ipairs(blocks) do
		if not forward[block] then
			result = result + 1
		else
			local willRemove = true
			for dependant, _ in pairs(forward[block]) do
				if len(backward[dependant]) <= 1 then
					willRemove = false
					break
				end
			end
			if willRemove then
				result = result + 1
			end
		end
	end
	return result
end

--- @description Sums the number of bricks that would fall if each brick is disintegrated
--- @param input string: the puzzle input
--- @return number: total falling bricks
function M.part2(input)
	local blocks, forward, backward, map = {}, {}, {}, {}
	local maxX, maxY = 0, 0
	for line in input:gmatch("[^\r\n]+") do
		for x1, y1, z1, x2, y2, z2 in line:gmatch("(%d+),(%d+),(%d+)~(%d+),(%d+),(%d+)") do
			x1, x2, y1, y2, z1, z2 = tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2), tonumber(z1), tonumber(z2)
			table.insert(blocks, { { x1, y1, z1 }, { x2, y2, z2 } })
			maxX, maxY = math.max(maxX, x1, x2), math.max(maxY, y1, y2)
		end
	end
	local function key(x)
		return tostring(x[1]) .. "|" .. tostring(x[2])
	end
	local function insertIntoMap(x, y, z, name)
		if map[key({ x, y })] and map[key({ x, y })][2] ~= name then
			local prev = map[key({ x, y })]
			if prev[1] + 1 == z then
				forward[prev[2]] = forward[prev[2]] or {}
				forward[prev[2]][name] = true
				backward[name] = backward[name] or {}
				backward[name][prev[2]] = true
			end
		end
		map[key({ x, y })] = { z, name }
	end
	local function applyBlock(block, name)
		local pos1, pos2 = table.unpack(block)
		local x1, y1, z1 = table.unpack(pos1)
		local x2, y2, z2 = table.unpack(pos2)
		if x1 == x2 and y1 == y2 then
			local top = (map[key({ x1, y1 })] or { 0, "" })[1]
			local height = z2 - z1 + 1
			for i = 1, height do
				insertIntoMap(x1, y1, top + i, name)
			end
		elseif x1 == x2 then
			local top = 0
			for i = y1, y2 do
				top = math.max(top, (map[key({ x1, i })] or { 0, "" })[1])
			end
			for i = y1, y2 do
				insertIntoMap(x1, i, top + 1, name)
			end
		elseif y1 == y2 then
			local top = 0
			for i = x1, x2 do
				top = math.max(top, (map[key({ i, y1 })] or { 0, "" })[1])
			end
			for i = x1, x2 do
				insertIntoMap(i, y1, top + 1, name)
			end
		end
	end
	table.sort(blocks, function(a, b)
		return a[1][3] < b[1][3]
	end)
	for i, block in ipairs(blocks) do
		applyBlock(block, i)
	end
	local function len(x)
		local c = 0
		for n in pairs(x) do
			c = c + 1
		end
		return c
	end
	local total = 0
	for i = 1, #blocks do
		local falling = { [i] = true }
		local queue = { i }
		while #queue > 0 do
			local curr = table.remove(queue, 1)
			if forward[curr] then
				for dep in pairs(forward[curr]) do
					if not falling[dep] then
						local supported = true
						for sup in pairs(backward[dep]) do
							if not falling[sup] then
								supported = false
								break
							end
						end
						if supported then
							falling[dep] = true
							table.insert(queue, dep)
						end
					end
				end
			end
		end
		total = total + len(falling) - 1
	end
	return total
end

return M
