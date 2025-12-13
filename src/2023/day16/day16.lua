--- @title: Day 16: The Floor Will Be Lava ---
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local grid = {}
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	for i, line in ipairs(lines) do
		if #line > 0 then
			grid[i] = {}
			for x = 1, #line do
				grid[i][x] = line:sub(x, x)
			end
		end
	end
	local rows = #grid
	local cols = #grid[1]
	local energized = {}
	local visited = {}
	local queue = { { 1, 1, 1, 0 } } -- x, y, dx, dy
	while #queue > 0 do
		local x, y, dx, dy = table.unpack(table.remove(queue, 1))
		if x < 1 or x > cols or y < 1 or y > rows then
			goto continue
		end
		local key = y .. "," .. x .. "," .. dx .. "," .. dy
		if visited[key] then
			goto continue
		end
		visited[key] = true
		energized[y .. "," .. x] = true
		local c = grid[y][x]
		if c == "." then
			table.insert(queue, { x + dx, y + dy, dx, dy })
		elseif c == "/" then
			local ndx, ndy = -dy, -dx
			table.insert(queue, { x + ndx, y + ndy, ndx, ndy })
		elseif c == "\\" then
			local ndx, ndy = dy, dx
			table.insert(queue, { x + ndx, y + ndy, ndx, ndy })
		elseif c == "|" then
			if dx ~= 0 then
				table.insert(queue, { x, y - 1, 0, -1 })
				table.insert(queue, { x, y + 1, 0, 1 })
				goto continue
			else
				table.insert(queue, { x + dx, y + dy, dx, dy })
			end
		elseif c == "-" then
			if dy ~= 0 then
				table.insert(queue, { x - 1, y, -1, 0 })
				table.insert(queue, { x + 1, y, 1, 0 })
				goto continue
			else
				table.insert(queue, { x + dx, y + dy, dx, dy })
			end
		end
		::continue::
	end
	local count = 0
	for _ in pairs(energized) do
		count = count + 1
	end
	return count
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local grid = {}
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	for i, line in ipairs(lines) do
		if #line > 0 then
			grid[i] = {}
			for x = 1, #line do
				grid[i][x] = line:sub(x, x)
			end
		end
	end
	local rows = #grid
	local cols = #grid[1]
	local function simulate(start_x, start_y, start_dx, start_dy)
		local energized = {}
		local visited = {}
		local queue = { { start_x, start_y, start_dx, start_dy } }
		while #queue > 0 do
			local x, y, dx, dy = table.unpack(table.remove(queue, 1))
			if x < 1 or x > cols or y < 1 or y > rows then
				goto continue
			end
			local key = y .. "," .. x .. "," .. dx .. "," .. dy
			if visited[key] then
				goto continue
			end
			visited[key] = true
			energized[y .. "," .. x] = true
			local c = grid[y][x]
			if c == "." then
				table.insert(queue, { x + dx, y + dy, dx, dy })
			elseif c == "/" then
				local ndx, ndy = -dy, -dx
				table.insert(queue, { x + ndx, y + ndy, ndx, ndy })
			elseif c == "\\" then
				local ndx, ndy = dy, dx
				table.insert(queue, { x + ndx, y + ndy, ndx, ndy })
			elseif c == "|" then
				if dx ~= 0 then
					table.insert(queue, { x, y - 1, 0, -1 })
					table.insert(queue, { x, y + 1, 0, 1 })
					goto continue
				else
					table.insert(queue, { x + dx, y + dy, dx, dy })
				end
			elseif c == "-" then
				if dy ~= 0 then
					table.insert(queue, { x - 1, y, -1, 0 })
					table.insert(queue, { x + 1, y, 1, 0 })
					goto continue
				else
					table.insert(queue, { x + dx, y + dy, dx, dy })
				end
			end
			::continue::
		end
		local count = 0
		for _ in pairs(energized) do
			count = count + 1
		end
		return count
	end
	local max_count = 0
	-- Top
	for x = 1, cols do
		max_count = math.max(max_count, simulate(x, 1, 0, 1))
	end
	-- Bottom
	for x = 1, cols do
		max_count = math.max(max_count, simulate(x, rows, 0, -1))
	end
	-- Left
	for y = 1, rows do
		max_count = math.max(max_count, simulate(1, y, 1, 0))
	end
	-- Right
	for y = 1, rows do
		max_count = math.max(max_count, simulate(cols, y, -1, 0))
	end
	return max_count
end

return M
