--- @title: --- Day 15: Warehouse Woes ---
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local map = {}
	local row, col = 1, 1
	local state = 1
	local instruction = {}
	local sx, sy = 1, 1

	for line in input:gmatch("[^\n]+") do
		if line == "" then
			state = 2
		elseif state == 1 then
			col = 1
			map[row] = {}
			for c in string.gmatch(line, ".") do
				if c == "@" then
					sx = row
					sy = col
				end
				map[row][col] = c
				col = col + 1
			end
			row = row + 1
		else
			for c in string.gmatch(line, ".") do
				instruction[#instruction + 1] = c
			end
		end
	end
	row = row - 1
	col = col - 1

	local unpack = unpack or table.unpack
	local dir4 = { ["^"] = { -1, 0 }, [">"] = { 0, 1 }, ["v"] = { 1, 0 }, ["<"] = { 0, -1 } }
	local function move(px, py, dx, dy)
		local c = map[px][py]
		if c == "#" then
			return false
		elseif c == "." then
			return true
		end
		local nx = px + dx
		local ny = py + dy
		local ismoved = move(nx, ny, dx, dy)
		if ismoved then
			map[nx][ny] = c
			map[px][py] = "."
		end
		return ismoved
	end

	local function getrock()
		return coroutine.wrap(function()
			for i = 1, row do
				for j = 1, col do
					if map[i][j] == "O" then
						coroutine.yield(i, j)
					end
				end
			end
		end)
	end

	for _, ins in ipairs(instruction) do
		local dx, dy = unpack(dir4[ins])
		if move(sx, sy, dx, dy) then
			sx = sx + dx
			sy = sy + dy
		end
	end

	local sum = 0
	for x, y in getrock() do
		sum = sum + 100 * (x - 1) + (y - 1)
	end
	return sum
end

--- @description Calculate the sum with larger warehouse
--- @param input string the puzzle input
--- @return number the sum
function M.part2(input)
	local map = {}
	local row, col = 1, 1
	local state = 1
	local instruction = {}
	local sx, sy = 1, 1

	for line in input:gmatch("[^\n]+") do
		if line == "" then
			state = 2
		elseif state == 1 then
			col = 1
			map[row] = {}
			for c in string.gmatch(line, ".") do
				if c == "@" then
					sx = row
					sy = col * 2 - 1
					map[row][col * 2 - 1] = "@"
					map[row][col * 2] = "."
				elseif c == "O" then
					map[row][col * 2 - 1] = "["
					map[row][col * 2] = "]"
				elseif c == "#" then
					map[row][col * 2 - 1] = "#"
					map[row][col * 2] = "#"
				else
					map[row][col * 2 - 1] = "."
					map[row][col * 2] = "."
				end
				col = col + 1
			end
			row = row + 1
		else
			for c in string.gmatch(line, ".") do
				instruction[#instruction + 1] = c
			end
		end
	end
	row = row - 1
	col = col * 2 - 1

	local unpack = unpack or table.unpack
	local dir4 = { ["^"] = { -1, 0 }, [">"] = { 0, 1 }, ["v"] = { 1, 0 }, ["<"] = { 0, -1 } }

	local function can_move(px, py, dx, dy)
		local c = map[px][py]
		if c == "#" then
			return false
		end
		if c == "." then
			return true
		end
		local nx = px + dx
		local ny = py + dy
		if dx == 0 then -- left right
			return can_move(nx, ny, dx, dy)
		else -- up down
			if c == "[" then
				return can_move(nx, ny, dx, dy) and can_move(nx, ny + 1, dx, dy)
			elseif c == "]" then
				return can_move(nx, ny, dx, dy) and can_move(nx, ny - 1, dx, dy)
			end
		end
		return false
	end

	local function do_move(px, py, dx, dy)
		local c = map[px][py]
		if c == "." then
			return
		end
		local nx = px + dx
		local ny = py + dy
		if dx == 0 then
			do_move(nx, ny, dx, dy)
		else
			if c == "[" then
				do_move(nx, ny, dx, dy)
				do_move(nx, ny + 1, dx, dy)
			elseif c == "]" then
				do_move(nx, ny, dx, dy)
				do_move(nx, ny - 1, dx, dy)
			end
		end
		map[nx][ny] = c
		map[px][py] = "."
	end

	for _, ins in ipairs(instruction) do
		local dx, dy = unpack(dir4[ins])
		if can_move(sx, sy, dx, dy) then
			do_move(sx, sy, dx, dy)
			sx = sx + dx
			sy = sy + dy
		end
	end

	local sum = 0
	for i = 1, row do
		for j = 1, col do
			if map[i][j] == "[" then
				sum = sum + 100 * (i - 1) + (j - 1)
			end
		end
	end
	return sum
end

return M
