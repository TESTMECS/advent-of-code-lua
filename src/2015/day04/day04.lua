--- @title: --- Day 4: The Ideal Stocking Stuffer ---
local util = require("util")
local md5 = require("md5")
local M = {}

--- @description: Use md5 hash and then hash:sub(1, 5) to check if the first 5 characters are "00000"
--- @param input string: secret key
--- @return integer: Lowest number for n which produces a hash starting with "00000"
function M.part1(input)
	local key = util.trim(input)
	local n = 0
	while true do
		n = n + 1
		if n % 100000 == 0 then
			print("Part 1: checking n = " .. n)
		end
		local hash = md5.sumhexa(key .. n)
		if hash:sub(1, 5) == "00000" then
			return n
		end
	end
end

--- @description: Use md5 hash and then hash:sub(1, 6) to check if the first 6 characters are "000000"
--- @param input string: secret key
--- @return integer: Highest number for n which produces a hash starting with "000000"
function M.part2(input)
	local key = util.trim(input)
	local n = 0
	while true do
		n = n + 1
		if n % 100000 == 0 then
			print("Part 2: checking n = " .. n)
		end
		local hash = md5.sumhexa(key .. n)
		if hash:sub(1, 6) == "000000" then
			return n
		end
	end
end

return M
