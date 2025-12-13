--- @title: Day 24: Lobby Layout ---
local M = {}
local util = require("util")

local directions = {
	e = { 1, 0 },
	se = { 0, 1 },
	sw = { -1, 1 },
	w = { -1, 0 },
	nw = { 0, -1 },
	ne = { 1, -1 },
}

--- @description: Count black tiles after flips
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local lines = util.read_lines(input)
	local black = {}
	for _, line in ipairs(lines) do
		local q, r = 0, 0
		local i = 1
		while i <= #line do
			local dir
			if line:sub(i, i) == "e" or line:sub(i, i) == "w" then
				dir = line:sub(i, i)
				i = i + 1
			else
				dir = line:sub(i, i + 1)
				i = i + 2
			end
			local dq, dr = table.unpack(directions[dir])
			q = q + dq
			r = r + dr
		end
		local key = q .. "," .. r
		if black[key] then
			black[key] = nil
		else
			black[key] = true
		end
	end
	local count = 0
	for _ in pairs(black) do
		count = count + 1
	end
	return count
end

--- @description: Simulate 100 days
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local lines = util.read_lines(input)
	local black = {}
	for _, line in ipairs(lines) do
		local q, r = 0, 0
		local i = 1
		while i <= #line do
			local dir
			if line:sub(i, i) == "e" or line:sub(i, i) == "w" then
				dir = line:sub(i, i)
				i = i + 1
			else
				dir = line:sub(i, i + 1)
				i = i + 2
			end
			local dq, dr = table.unpack(directions[dir])
			q = q + dq
			r = r + dr
		end
		local key = q .. "," .. r
		if black[key] then
			black[key] = nil
		else
			black[key] = true
		end
	end
	for _ = 1, 100 do
		local to_check = {}
		for key in pairs(black) do
			local q, r = key:match("([^,]+),(.+)")
			q, r = tonumber(q), tonumber(r)
			to_check[key] = true
			for _, d in pairs(directions) do
				local nq, nr = q + d[1], r + d[2]
				to_check[nq .. "," .. nr] = true
			end
		end
		local new_black = {}
		for key in pairs(to_check) do
			local q, r = key:match("([^,]+),(.+)")
			q, r = tonumber(q), tonumber(r)
			local count = 0
			for _, d in pairs(directions) do
				local nq, nr = q + d[1], r + d[2]
				if black[nq .. "," .. nr] then
					count = count + 1
				end
			end
			local is_black = black[key]
			if is_black and (count == 1 or count == 2) or not is_black and count == 2 then
				new_black[key] = true
			end
		end
		black = new_black
	end
	local count = 0
	for _ in pairs(black) do
		count = count + 1
	end
	return count
end

return M
