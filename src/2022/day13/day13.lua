--- @title: Day 13: Distress Signal ---
local M = {}

local function parse_packet(str)
	local stack = { {} }
	local i = 1
	while i <= #str do
		local c = str:sub(i, i)
		if c == "[" then
			local new = {}
			table.insert(stack[#stack], new)
			table.insert(stack, new)
		elseif c == "]" then
			table.remove(stack)
		elseif c == "," then
			-- skip
		elseif c >= "0" and c <= "9" then
			local num = 0
			while i <= #str and str:sub(i, i) >= "0" and str:sub(i, i) <= "9" do
				num = num * 10 + tonumber(str:sub(i, i))
				i = i + 1
			end
			i = i - 1
			table.insert(stack[#stack], num)
		end
		i = i + 1
	end
	return stack[1][1]
end

local function compare(left, right)
	if type(left) == "number" and type(right) == "number" then
		if left < right then
			return -1
		elseif left > right then
			return 1
		else
			return 0
		end
	elseif type(left) == "table" and type(right) == "table" then
		for i = 1, math.max(#left, #right) do
			if i > #left then
				return -1
			elseif i > #right then
				return 1
			else
				local res = compare(left[i], right[i])
				if res ~= 0 then
					return res
				end
			end
		end
		return 0
	elseif type(left) == "number" then
		return compare({ left }, right)
	else
		return compare(left, { right })
	end
end

--- @description Sum indices of correctly ordered pairs
--- @param input string the puzzle input
--- @return number the sum of indices
function M.part1(input)
	local pairs = {}
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	for i = 1, #lines, 2 do
		local left = parse_packet(lines[i])
		local right = parse_packet(lines[i + 1])
		table.insert(pairs, { left, right })
	end
	local sum = 0
	for i, pair in ipairs(pairs) do
		if compare(pair[1], pair[2]) == -1 then
			sum = sum + i
		end
	end
	return sum
end

--- @description Find decoder key
--- @param input string the puzzle input
--- @return number the decoder key
function M.part2(input)
	local packets = {}
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	for _, line in ipairs(lines) do
		table.insert(packets, parse_packet(line))
	end
	local div1 = { { 2 } }
	local div2 = { { 6 } }
	table.insert(packets, div1)
	table.insert(packets, div2)
	table.sort(packets, function(a, b)
		return compare(a, b) == -1
	end)
	local idx1, idx2
	for i, p in ipairs(packets) do
		if type(p) == "table" and #p == 1 and type(p[1]) == "table" and #p[1] == 1 then
			if p[1][1] == 2 then
				idx1 = i
			elseif p[1][1] == 6 then
				idx2 = i
			end
		end
	end
	return idx1 * idx2
end

return M
