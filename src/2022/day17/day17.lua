 --- @title: Day 17: Pyroclastic Flow ---
local M = {}

local rocks = {
	{ {1,1,1,1} },
	{ {0,1,0}, {1,1,1}, {0,1,0} },
	{ {1,1,1}, {0,0,1}, {0,0,1} },
	{ {1}, {1}, {1}, {1} },
	{ {1,1}, {1,1} }
}

local function simulate(input, total_rocks)
	local jets = {}
	for c in input:gmatch("[<>]") do
		table.insert(jets, c == '>' and 1 or -1)
	end
	local jet_len = #jets
	local chamber = {}
	local height = 0
	local jet_i = 1
	local seen = {}
	local extra_height = 0
	local rock_i = 1
	local function can_place(rock, rx, ry)
		for dy = 1, #rock do
			for dx = 1, #rock[dy] do
				if rock[dy][dx] == 1 then
					local x = rx + dx - 1
					local y = ry + dy - 1
					if x < 1 or x > 7 or y < 1 or (chamber[y] and chamber[y][x]) then
						return false
					end
				end
			end
		end
		return true
	end
	local function place(rock, rx, ry)
		for dy = 1, #rock do
			for dx = 1, #rock[dy] do
				if rock[dy][dx] == 1 then
					local x = rx + dx - 1
					local y = ry + dy - 1
					if not chamber[y] then chamber[y] = {} end
					chamber[y][x] = true
					if y > height then height = y end
				end
			end
		end
	end
	local function drop_rock(rock)
		local rx, ry = 3, height + 4
		while true do
			local dx = jets[jet_i]
			jet_i = jet_i % jet_len + 1
			if can_place(rock, rx + dx, ry) then
				rx = rx + dx
			end
			if can_place(rock, rx, ry - 1) then
				ry = ry - 1
			else
				place(rock, rx, ry)
				break
			end
		end
	end
	for i = 1, total_rocks do
		drop_rock(rocks[(rock_i - 1) % 5 + 1])
		rock_i = rock_i + 1
		if total_rocks == 1000000000000 then
			local profile = {}
			for x = 1, 7 do
				local maxy = 0
				for y = height, 1, -1 do
					if chamber[y] and chamber[y][x] then
						maxy = y
						break
					end
				end
				profile[x] = height - maxy
			end
			local state = string.format("%d,%d,%s", (rock_i - 1) % 5, jet_i - 1, table.concat(profile, ','))
			if seen[state] then
				local prev_i, prev_h = seen[state][1], seen[state][2]
				local cycle_len = i - prev_i
				local cycle_height = height - prev_h
				local remaining = total_rocks - i
				local cycles = math.floor(remaining / cycle_len)
				extra_height = cycles * cycle_height
				local remaining_rocks = remaining % cycle_len
				for j = 1, remaining_rocks do
					drop_rock(rocks[(rock_i - 1) % 5 + 1])
					rock_i = rock_i + 1
				end
				break
			else
				seen[state] = { i, height }
			end
		end
	end
	return height + extra_height
end

--- @description Find height after 2022 rocks
--- @param input string the puzzle input
--- @return number the height
function M.part1(input)
	return simulate(input, 2022)
end

--- @description Find height after 1000000000000 rocks
--- @param input string the puzzle input
--- @return number the height
function M.part2(input)
	return simulate(input, 1000000000000)
end

return M
