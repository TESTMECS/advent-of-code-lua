--- @title: Day 5: How About a Nice Game of Chess? ---
local util = require("util")
local md5 = require("md5")
local M = {}

--- @description: Generates the 8-character password for the door by finding MD5 hashes of the door ID + index that start with five zeroes, taking the 6th character of each such hash.
--- @param input string: The door ID (puzzle input)
--- @return string: The 8-character password
function M.part1(input)
	local door_id = input:match("%S+")
	local password = ""
	local index = 0
	while #password < 8 do
		local hash = md5.sumhexa(door_id .. index)
		if hash:sub(1, 5) == "00000" then
			password = password .. hash:sub(6, 6) -- 6th place
		end
		index = index + 1
		if index % 1000000 == 0 then
			print("Part 1: checking index = " .. index .. ", password so far: " .. password)
		end
	end
	return password
end

--- @description: Generates the 8-character password for the door by finding MD5 hashes that start with five zeroes, where the 6th character indicates the position (0-7) and the 7th character is the password character for that position.
--- @param input string: The door ID (puzzle input)
--- @return string: The 8-character password
function M.part2(input)
	local door_id = util.trim(input)
	local password = { "", "", "", "", "", "", "", "" }
	local found = 0
	local index = 0
	while found < 8 do
		local hash = md5.sumhexa(door_id .. index)
		if hash:sub(1, 5) == "00000" then
			local pos = tonumber(hash:sub(6, 6), 16) -- 6th is position
			if pos and pos >= 0 and pos <= 7 and password[pos + 1] == "" then
				password[pos + 1] = hash:sub(7, 7)
				found = found + 1
			end
		end
		index = index + 1
		if index % 1000000 == 0 then
			print(
				"Part 2: checking index = "
					.. index
					.. ", found = "
					.. found
					.. ", password so far: "
					.. table.concat(password)
			)
		end
	end
	return table.concat(password)
end

return M
