--- @title: Day 14: Disk Defragmentation ---
local M = {}

--- @description: Calculate the knot hash checksum for part 1
--- @param input string: the comma-separated lengths
--- @return number: the product of first two elements
local function knot_hash(input)
	local lengths = {}
	for i = 1, #input do
		table.insert(lengths, input:byte(i))
	end
	table.insert(lengths, 17)
	table.insert(lengths, 31)
	table.insert(lengths, 73)
	table.insert(lengths, 47)
	table.insert(lengths, 23)

	local list = {}
	for i = 0, 255 do
		list[i + 1] = i
	end

	local position = 1
	local skip = 0

	for _ = 1, 64 do
		for _, len in ipairs(lengths) do
			-- Reverse the sublist
			local sub = {}
			for i = 0, len - 1 do
				sub[i + 1] = list[(position + i - 1) % 256 + 1]
			end
			for i = 0, len - 1 do
				list[(position + i - 1) % 256 + 1] = sub[len - i]
			end
			-- Move position
			position = (position + len + skip - 1) % 256 + 1
			skip = skip + 1
		end
	end

	-- Dense hash
	local dense = {}
	for i = 0, 15 do
		local xor_val = 0
		for j = 0, 15 do
			xor_val = xor_val ~ list[i * 16 + j + 1]
		end
		table.insert(dense, xor_val)
	end

	-- To hex
	local hex = ""
	for _, v in ipairs(dense) do
		hex = hex .. string.format("%02x", v)
	end

	return hex
end

--- @description: Count the number of used squares
--- @param input string: the key string
--- @return number: the count
function M.part1(input)
	local key = input:match("%S+")
	local count = 0
	for row = 0, 127 do
		local hash_input = key .. "-" .. row
		local hash = knot_hash(hash_input)
		for i = 1, #hash do
			local hex = hash:sub(i, i)
			local num = tonumber(hex, 16)
			for j = 0, 3 do
				if num & (1 << 3 - j) ~= 0 then
					count = count + 1
				end
			end
		end
	end
	return count
end

--- @description: Count the number of regions
--- @param input string: the key string
--- @return number: the count
function M.part2(input)
	local key = input:match("%S+")
	local grid = {}
	for row = 0, 127 do
		grid[row] = {}
		local hash_input = key .. "-" .. row
		local hash = knot_hash(hash_input)
		local bits = ""
		for i = 1, #hash do
			local hex = hash:sub(i, i)
			local num = tonumber(hex, 16)
			for j = 0, 3 do
				local bit = (num & (1 << (3 - j))) ~= 0 and "1" or "0"
				bits = bits .. bit
			end
		end
		for col = 0, 127 do
			grid[row][col] = bits:sub(col + 1, col + 1) == "1"
		end
	end

	local visited = {}
	for i = 0, 127 do
		visited[i] = {}
		for j = 0, 127 do
			visited[i][j] = false
		end
	end

	local function dfs(r, c)
		if r < 0 or r > 127 or c < 0 or c > 127 or not grid[r][c] or visited[r][c] then
			return
		end
		visited[r][c] = true
		dfs(r - 1, c)
		dfs(r + 1, c)
		dfs(r, c - 1)
		dfs(r, c + 1)
	end

	local regions = 0
	for r = 0, 127 do
		for c = 0, 127 do
			if grid[r][c] and not visited[r][c] then
				regions = regions + 1
				dfs(r, c)
			end
		end
	end
	return regions
end

return M
