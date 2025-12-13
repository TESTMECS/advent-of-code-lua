--[[
Copyright(c) 2025 TESTMEE
--]]
local util = {}
--- @description: Reads a string into an table of lines
--- @param str string: the string to read in
--- @return table: Table of lines in the file
function util.read_lines(str)
	local t = {}
	for line in str:gmatch("[^\r\n]+") do
		table.insert(t, line)
	end
	return t
end

--- @description: Splits a string by a delimiter
--- @param str string: The string to split
--- @param delim string: The delimiter
--- @return table: Table of split parts
function util.split(str, delim)
	local t = {}
	local pattern = string.format("([^%s]+)", delim)
	for part in str:gmatch(pattern) do
		table.insert(t, part)
	end
	return t
end

--- @description: Parses all numbers from a string
--- @param str string: The string containing numbers
--- @return table: Table of numbers
function util.parse_nums(str)
	local t = {}
	for num in str:gmatch("%d+") do
		table.insert(t, tonumber(num))
	end
	return t
end

--- @description: Sums all numbers in a table
--- @param t table: Table of numbers
--- @return number: The sum
function util.sum(t)
	local s = 0
	for _, v in ipairs(t) do
		s = s + v
	end
	return s
end

--- @description: Finds the maximum value in a table
--- @param t table: Table of numbers
--- @return number: The maximum value
function util.max(t)
	local m = -math.huge
	for _, v in ipairs(t) do
		if v > m then
			m = v
		end
	end
	return m
end

--- @description: Finds the minimum value in a table
--- @param t table: Table of numbers
--- @return number: The minimum value
function util.min(t)
	local m = math.huge
	for _, v in ipairs(t) do
		if v < m then
			m = v
		end
	end
	return m
end

--- @description: Trims whitespace from both ends of a string
--- @param str string: The string to trim
--- @return string: The trimmed string
function util.trim(str)
	return str:match("^%s*(.-)%s*$")
end

--- @description: Reads the entire content of a file
--- @param path string: The file path
--- @return string|nil: The file content or nil if file not found
function util.read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

--- @description Pretty prints a table
--- @param t table: The table to print
--- @return string: The pretty printed table
function util.print_table(t)
	if type(t) == "table" then
		local s = "{ " .. "\n"
		for k, v in pairs(t) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. util.print_table(v) .. "," .. "\n"
		end
		return s .. "}"
	else
		return tostring(t)
	end
end

--- @description Gets the keys of a table
--- @param t table: The table
--- @return table: List of keys
function util.keyset(t)
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

--- @description Gets the number of elements in a table
--- @param t table: The table
--- @return number: Number of elements
function util.numel(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

--- @description Reads input file into lines
--- @param path string: The file path
--- @return table: Table of lines
function util.read_input(path)
	local content = util.read_file(path)
	if not content then
		return {}
	end
	return util.read_lines(content)
end

--- @description Reverses a table
--- @param t table: The table to reverse
--- @return table: The reversed table
function util.t_reverse(t)
	local rev = {}
	for k, v in ipairs(t) do
		rev[#t + 1 - k] = v
	end
	return rev
end

--- @description Returns the size of a table
--- @param t table: The table to get the size of
--- @return number: The size of the table
function util.tablesize(t)
	local size = 0
	for _, _ in pairs(t) do
		size = size + 1
	end
	return size
end

--- @description returns a table of the the number of occurrences of a character in a string
--- @param str string The string to count
--- @return table Table of character frequencies
function util.count_char_freq(str)
	local freq = {}
	for i = 1, #str do
		local c = string.sub(str, i, i)
		freq[c] = (freq[c] or 0) + 1
	end
	return freq
end

return util
