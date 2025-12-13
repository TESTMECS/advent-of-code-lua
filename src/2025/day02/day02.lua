local M = {}
---@param num number
---@return boolean
local function isRepeatPattern(num)
	local str_num = tostring(num)
	local length = #str_num
	for pattern_len = 1, math.floor(length / 2) do
		if length % pattern_len == 0 then
			local pattern = str_num:sub(1, pattern_len)
			local is_valid = true
			for i = pattern_len + 1, length, pattern_len do
				local segment = str_num:sub(i, i + pattern_len - 1)
				if segment ~= pattern then
					is_valid = false
					break
				end
			end
			if is_valid and (length / pattern_len >= 2) then
				return true
			end
		end
	end
	return false
end
local function isRepeatPatternOne(num)
	local str_num = tostring(num)
	local length = #str_num
	if length % 2 ~= 0 then
		return false
	end
	local half = length / 2
	local firstHalf = str_num:sub(1, half)
	local secondHalf = str_num:sub(half + 1)
	return firstHalf == secondHalf
end
--- @description:
--- @param input string:
--- @return number:
function M.part1(input)
	local invalidSum = 0
	for line in input:gmatch("[^,]+") do
		line = line:gsub("%s+", "")
		local rStart, rEnd = line:gmatch("(%d+)-(%d+)")()
		rStart = tonumber(rStart)
		rEnd = tonumber(rEnd)
		for i = rStart, rEnd do
			if isRepeatPatternOne(i) then
				invalidSum = invalidSum + i
			end
		end
	end
	return invalidSum
end
--- @description:
--- @param input string:
--- @return number:
function M.part2(input)
	local invalidSum = 0
	for line in input:gmatch("[^,]+") do
		line = line:gsub("%s+", "")
		local rStart, rEnd = line:gmatch("(%d+)-(%d+)")()
		rStart = tonumber(rStart)
		rEnd = tonumber(rEnd)
		for i = rStart, rEnd do
			if isRepeatPattern(i) then
				invalidSum = invalidSum + i
			end
		end
	end
	return invalidSum
end
return M
