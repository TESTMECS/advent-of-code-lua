--- @title: Day 14: One-Time Pad ---
local md5 = require("md5")
local M = {}

local hash_cache = {}

--- @function: Helper function to get hash
--- @param salt string
--- @param index integer
--- @param stretched boolean
--- @return string
local function get_hash(salt, index, stretched)
	local key = salt .. index .. (stretched and "s" or "")
	if hash_cache[key] then
		return hash_cache[key]
	end

	local hash = md5.sumhexa(salt .. index)
	if stretched then
		for _ = 1, 2016 do
			hash = md5.sumhexa(hash)
		end
	end

	hash_cache[key] = hash
	return hash
end

--- @function: Finds the index that produces the 64th one-time pad key.
--- @param salt string The salt for hashing.
--- @param stretched boolean Whether to use key stretching.
--- @return number The index of the 64th key.
local function find_keys(salt, stretched)
	local keys = {}
	local index = 0
	while #keys < 64 do
		if stretched and index % 100 == 0 then
			print("Part 2: checking index = " .. index .. ", keys found: " .. #keys)
		end
		local hash = get_hash(salt, index, stretched)
		local triplet_char = hash:match("(%w)%1%1")

		if triplet_char then
			local quintuplet = string.rep(triplet_char, 5)
			for i = 1, 1000 do
				local next_hash = get_hash(salt, index + i, stretched)
				if next_hash:find(quintuplet) then
					table.insert(keys, index)
					if stretched then
						print("Part 2: Found key #" .. #keys .. " at index " .. index)
					end
					break
				end
			end
		end
		index = index + 1
	end
	return keys[64]
end

--- @description Finds the index that produces the 64th one-time pad key.
--- @param input string The salt for hashing.
--- @return number The index of the 64th key.
function M.part1(input)
	local salt = input:match("%S+")
	hash_cache = {} -- Clear cache for part 1
	return find_keys(salt, false)
end

--- @description Finds the index for the 64th key using key stretching.
--- @param input string The salt for hashing.
--- @return number The index of the 64th key with stretching.
function M.part2(input)
	local salt = input:match("%S+")
	hash_cache = {} -- Clear cache for part 2
	return find_keys(salt, true)
end

return M
