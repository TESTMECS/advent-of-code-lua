--- @title: Day 4: Security Through Obscurity ---
local M = {}

--- @description Validates room names by checking if the computed checksum (5 most common letters, sorted by frequency then alphabetically) matches the given checksum. Sums the sector IDs of valid rooms
--- @param input string
--- @return number|nil sector id
function M.part1(input)
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local name, sector, checksum = line:match("(.+)-(%d+)%[(%w+)%]")
		if name and sector and checksum then
			sector = tonumber(sector)
			local letters = {}
			for c in name:gmatch("[a-z]") do
				letters[c] = (letters[c] or 0) + 1
			end
			local sorted = {}
			for c, count in pairs(letters) do
				table.insert(sorted, { c, count })
			end
			table.sort(sorted, function(a, b)
				if a[2] == b[2] then
					return a[1] < b[1]
				end
				return a[2] > b[2]
			end)
			local computed = ""
			for i = 1, 5 do
				if sorted[i] then
					computed = computed .. sorted[i][1]
				end
			end
			if computed == checksum then
				sum = sum + sector
			end
		end
	end
	return sum
end

--- @description Among valid rooms, decrypts the room name by shifting each letter by the sector ID, and finds the sector ID of the room containing "northpole"
--- @param input string
--- @return number|nil sector id
function M.part2(input)
	for line in input:gmatch("[^\n]+") do
		local name, sector, checksum = line:match("(.+)-(%d+)%[(%w+)%]")
		if name and sector and checksum then
			sector = tonumber(sector)
			local letters = {}
			for c in name:gmatch("[a-z]") do
				letters[c] = (letters[c] or 0) + 1
			end
			local sorted = {}
			for c, count in pairs(letters) do
				table.insert(sorted, { c, count })
			end
			table.sort(sorted, function(a, b)
				if a[2] == b[2] then
					return a[1] < b[1]
				end
				return a[2] > b[2]
			end)
			local computed = ""
			for i = 1, 5 do
				if sorted[i] then
					computed = computed .. sorted[i][1]
				end
			end
			if computed == checksum then
				-- decrypt
				local decrypted = ""
				for c in name:gmatch(".") do
					if c == "-" then
						decrypted = decrypted .. " "
					else
						local code = c:byte() - 97
						code = (code + sector) % 26
						decrypted = decrypted .. string.char(code + 97)
					end
				end
				if decrypted:find("northpole") then
					return sector
				end
			end
		end
	end
	return 0
end

return M
