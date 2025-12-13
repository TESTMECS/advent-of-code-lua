--- @title: Day 16: Title ---
local M = {}

--- @description: Sum the version numbers of all packets
--- @param input string: the puzzle input
--- @return number: the sum of version numbers
function M.part1(input)
	input = input:gsub("[^0-9A-F]", "")
	local hex_to_bin = {
		["0"] = "0000",
		["1"] = "0001",
		["2"] = "0010",
		["3"] = "0011",
		["4"] = "0100",
		["5"] = "0101",
		["6"] = "0110",
		["7"] = "0111",
		["8"] = "1000",
		["9"] = "1001",
		["A"] = "1010",
		["B"] = "1011",
		["C"] = "1100",
		["D"] = "1101",
		["E"] = "1110",
		["F"] = "1111",
	}
	local bin = ""
	for c in input:gmatch(".") do
		bin = bin .. hex_to_bin[c]
	end
	local pos = 1
	local function read_bits(n)
		local bits = bin:sub(pos, pos + n - 1)
		pos = pos + n
		return bits
	end
	local function read_int(bits)
		return tonumber(bits, 2)
	end
	local version_sum = 0
	local function parse_packet()
		local version = read_int(read_bits(3))
		version_sum = version_sum + version
		local type_id = read_int(read_bits(3))
		if type_id == 4 then
			-- literal
			while true do
				local group = read_bits(5)
				if group:sub(1, 1) == "0" then
					break
				end
			end
		else
			-- operator
			local length_type = read_bits(1)
			if length_type == "0" then
				local total_length = read_int(read_bits(15))
				local end_pos = pos + total_length
				while pos < end_pos do
					parse_packet()
				end
			else
				local num_packets = read_int(read_bits(11))
				for i = 1, num_packets do
					parse_packet()
				end
			end
		end
	end
	parse_packet()
	return version_sum
end

--- @description: Evaluate the expression represented by the packet
--- @param input string: the puzzle input
--- @return number: the value of the expression
function M.part2(input)
	input = input:gsub("[^0-9A-F]", "")
	local hex_to_bin = {
		["0"] = "0000",
		["1"] = "0001",
		["2"] = "0010",
		["3"] = "0011",
		["4"] = "0100",
		["5"] = "0101",
		["6"] = "0110",
		["7"] = "0111",
		["8"] = "1000",
		["9"] = "1001",
		["A"] = "1010",
		["B"] = "1011",
		["C"] = "1100",
		["D"] = "1101",
		["E"] = "1110",
		["F"] = "1111",
	}
	local bin = ""
	for c in input:gmatch(".") do
		bin = bin .. hex_to_bin[c]
	end
	local pos = 1
	local function read_bits(n)
		local bits = bin:sub(pos, pos + n - 1)
		pos = pos + n
		return bits
	end
	local function read_int(bits)
		return tonumber(bits, 2)
	end
	local function parse_packet()
		local version = read_int(read_bits(3))
		local type_id = read_int(read_bits(3))
		if type_id == 4 then
			-- literal
			local value = 0
			while true do
				local group = read_bits(5)
				local val = read_int(group:sub(2, 5))
				value = value * 16 + val
				if group:sub(1, 1) == "0" then
					break
				end
			end
			return value
		else
			-- operator
			local length_type = read_bits(1)
			local values = {}
			if length_type == "0" then
				local total_length = read_int(read_bits(15))
				local end_pos = pos + total_length
				while pos < end_pos do
					table.insert(values, parse_packet())
				end
			else
				local num_packets = read_int(read_bits(11))
				for i = 1, num_packets do
					table.insert(values, parse_packet())
				end
			end
			-- compute
			if type_id == 0 then
				local sum = 0
				for _, v in ipairs(values) do
					sum = sum + v
				end
				return sum
			elseif type_id == 1 then
				local prod = 1
				for _, v in ipairs(values) do
					prod = prod * v
				end
				return prod
			elseif type_id == 2 then
				local min = math.huge
				for _, v in ipairs(values) do
					min = math.min(min, v)
				end
				return min
			elseif type_id == 3 then
				local max = -math.huge
				for _, v in ipairs(values) do
					max = math.max(max, v)
				end
				return max
			elseif type_id == 5 then
				return values[1] > values[2] and 1 or 0
			elseif type_id == 6 then
				return values[1] < values[2] and 1 or 0
			elseif type_id == 7 then
				return values[1] == values[2] and 1 or 0
			end
		end
	end
	return parse_packet()
end

return M
