--- @title: Day 19: A Series of Tubes ---
local M = {}

--- @description: Collect the letters along the path
--- @param input string: the grid
--- @return string: the letters
function M.part1(input)
	local grid = {}
	for line in input:gmatch("[^\r\n]+") do
		local row = {}
		for i = 1, #line do
			row[i] = line:sub(i, i)
		end
		table.insert(grid, row)
	end
	local start_r = 1
	local start_c
	for c = 1, #grid[1] do
		if grid[1][c] ~= " " then
			start_c = c
			break
		end
	end
	local pos_r = start_r
	local pos_c = start_c
	local dir = "down"
	local s = ""
	local steps = 0
	while true do
		if dir == "down" then
			pos_r = pos_r + 1
		elseif dir == "up" then
			pos_r = pos_r - 1
		elseif dir == "left" then
			pos_c = pos_c - 1
		elseif dir == "right" then
			pos_c = pos_c + 1
		end
		if pos_r < 1 or pos_r > #grid or pos_c < 1 or pos_c > #grid[1] then
			break
		end
		steps = steps + 1
		local ch
		if pos_c > #grid[pos_r] then
			ch = " "
		else
			ch = grid[pos_r][pos_c]
		end
		if ch == " " then
			break
		elseif ch:match("%a") then
			s = s .. ch
		elseif ch == "+" then
			local dirs
			if dir == "down" then
				dirs = { "down", "left", "right", "up" }
			elseif dir == "up" then
				dirs = { "up", "right", "left", "down" }
			elseif dir == "left" then
				dirs = { "left", "up", "down", "right" }
			elseif dir == "right" then
				dirs = { "right", "down", "up", "left" }
			end
			for _, d in ipairs(dirs) do
				local nr, nc = pos_r, pos_c
				if d == "up" then
					nr = nr - 1
				elseif d == "down" then
					nr = nr + 1
				elseif d == "left" then
					nc = nc - 1
				elseif d == "right" then
					nc = nc + 1
				end
				if
					nr >= 1
					and nr <= #grid
					and nc >= 1
					and nc <= #grid[1]
					and nc <= #grid[nr]
					and grid[nr][nc] ~= " "
					and (nr ~= pos_r or nc ~= pos_c)
				then
					dir = d
					break
				end
			end
		end
	end
	return s
end

--- @description: Count the steps along the path
--- @param input string: the grid
--- @return number: the steps
function M.part2(input)
	local grid = {}
	for line in input:gmatch("[^\r\n]+") do
		local row = {}
		for i = 1, #line do
			row[i] = line:sub(i, i)
		end
		table.insert(grid, row)
	end
	local start_r = 1
	local start_c
	for c = 1, #grid[1] do
		if grid[1][c] ~= " " then
			start_c = c
			break
		end
	end
	local pos_r = start_r
	local pos_c = start_c
	local dir = "down"
	local steps = 0
	while true do
		if dir == "down" then
			pos_r = pos_r + 1
		elseif dir == "up" then
			pos_r = pos_r - 1
		elseif dir == "left" then
			pos_c = pos_c - 1
		elseif dir == "right" then
			pos_c = pos_c + 1
		end
		if pos_r < 1 or pos_r > #grid or pos_c < 1 or pos_c > #grid[1] then
			break
		end
		steps = steps + 1
		local ch
		if pos_c > #grid[pos_r] then
			ch = " "
		else
			ch = grid[pos_r][pos_c]
		end
		if ch == " " then
			break
		elseif ch == "+" then
			local dirs
			if dir == "down" then
				dirs = { "down", "left", "right", "up" }
			elseif dir == "up" then
				dirs = { "up", "right", "left", "down" }
			elseif dir == "left" then
				dirs = { "left", "up", "down", "right" }
			elseif dir == "right" then
				dirs = { "right", "down", "up", "left" }
			end
			for _, d in ipairs(dirs) do
				local nr, nc = pos_r, pos_c
				if d == "up" then
					nr = nr - 1
				elseif d == "down" then
					nr = nr + 1
				elseif d == "left" then
					nc = nc - 1
				elseif d == "right" then
					nc = nc + 1
				end
				if
					nr >= 1
					and nr <= #grid
					and nc >= 1
					and nc <= #grid[1]
					and nc <= #grid[nr]
					and grid[nr][nc] ~= " "
					and (nr ~= pos_r or nc ~= pos_c)
				then
					dir = d
					break
				end
			end
		end
	end
	return steps
end

return M
