--- @title: --- Day 8: Seven Segment Search ---
local M = {}

--- @description: Count the number of times digits 1, 4, 7, or 8 appear in the output values
--- @param input string: the puzzle input
--- @return number: the count of easy digits
function M.part1(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local output = line:match("| (.+)")
		for word in output:gmatch("%w+") do
			local len = #word
			if len == 2 or len == 3 or len == 4 or len == 7 then
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Decode the output values and sum them up
--- @param s string
--- @return string|nil
local function sort_str(s)
	local t = {}
	for c in s:gmatch(".") do
		table.insert(t, c)
	end
	table.sort(t)
	return table.concat(t)
end
function M.part2(input)
	local total = 0
	for line in input:gmatch("[^\n]+") do
		local patterns = {}
		local output = {}
		for word in line:match("(.+) |"):gmatch("%w+") do
			table.insert(patterns, sort_str(word))
		end
		for word in line:match("| (.+)"):gmatch("%w+") do
			table.insert(output, sort_str(word))
		end
		local digit_to_pattern = {}
		for _, p in ipairs(patterns) do
			local len = #p
			if len == 2 then
				digit_to_pattern[1] = p
			elseif len == 3 then
				digit_to_pattern[7] = p
			elseif len == 4 then
				digit_to_pattern[4] = p
			elseif len == 7 then
				digit_to_pattern[8] = p
			end
		end
		local six_seg = {}
		for _, p in ipairs(patterns) do
			if #p == 6 then
				table.insert(six_seg, p)
			end
		end
		for _, p in ipairs(six_seg) do
			local contains_1 = true
			for c in digit_to_pattern[1]:gmatch(".") do
				if not p:find(c) then
					contains_1 = false
					break
				end
			end
			if not contains_1 then
				digit_to_pattern[6] = p
				break
			end
		end
		for _, p in ipairs(six_seg) do
			if p ~= digit_to_pattern[6] then
				local contains_4 = true
				for c in digit_to_pattern[4]:gmatch(".") do
					if not p:find(c) then
						contains_4 = false
						break
					end
				end
				if contains_4 then
					digit_to_pattern[9] = p
					break
				end
			end
		end
		for _, p in ipairs(six_seg) do
			if p ~= digit_to_pattern[6] and p ~= digit_to_pattern[9] then
				digit_to_pattern[0] = p
				break
			end
		end
		local five_seg = {}
		for _, p in ipairs(patterns) do
			if #p == 5 then
				table.insert(five_seg, p)
			end
		end
		for _, p in ipairs(five_seg) do
			local contains_1 = true
			for c in digit_to_pattern[1]:gmatch(".") do
				if not p:find(c) then
					contains_1 = false
					break
				end
			end
			if contains_1 then
				digit_to_pattern[3] = p
				break
			end
		end
		for _, p in ipairs(five_seg) do
			if p ~= digit_to_pattern[3] then
				local contained_in_6 = true
				for c in p:gmatch(".") do
					if not digit_to_pattern[6]:find(c) then
						contained_in_6 = false
						break
					end
				end
				if contained_in_6 then
					digit_to_pattern[5] = p
					break
				end
			end
		end
		for _, p in ipairs(five_seg) do
			if p ~= digit_to_pattern[3] and p ~= digit_to_pattern[5] then
				digit_to_pattern[2] = p
				break
			end
		end
		local pattern_to_digit = {}
		for d, p in pairs(digit_to_pattern) do
			pattern_to_digit[p] = d
		end
		local num = 0
		for i, word in ipairs(output) do
			local d = pattern_to_digit[word]
			num = num + d * 10 ^ (4 - i)
		end
		total = total + num
	end
	return total
end

return M
