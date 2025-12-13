--- @title Day 12: JSAbacusFramework.io
local M = {}

--- @description sum all numbers in a string with simple regex match
--- @param input string: super nested json
--- @return number: sum of all numbers
function M.part1(input)
	input = input:gsub("\n", "")
	local sum = 0
	for num in input:gmatch("-?%d+") do
		sum = sum + tonumber(num)
	end
	return sum
end

--- @function: parse a json into a lua table
--- @param s string
--- @param skip_red boolean
local function parse_json(s, skip_red)
	local pos = 1
	local parse_object, parse_array, parse_value
	--- @function: skip whitespace by incrementing pos
	--- @return nil
	local function skip_ws()
		while pos <= #s and s:sub(pos, pos):match("%s") do
			pos = pos + 1
		end
	end
	--- @function: parse a number and increment pos
	--- @return number|nil
	local function parse_number()
		local start = pos
		while pos <= #s and s:sub(pos, pos):match("[%d%.%-]") do
			pos = pos + 1
		end
		return tonumber(s:sub(start, pos - 1))
	end
	--- @function: parse a string and increment pos
	--- @return string|nil
	local function parse_string()
		pos = pos + 1
		local start = pos
		while pos <= #s and s:sub(pos, pos) ~= '"' do
			if s:sub(pos, pos) == "\\" then
				pos = pos + 2
			else
				pos = pos + 1
			end
		end
		local str = s:sub(start, pos - 1)
		pos = pos + 1
		return str
	end
	--- @function: Parse object, array, string, number
	parse_value = function()
		skip_ws()
		local c = s:sub(pos, pos)
		if c == "{" then
			return parse_object()
		elseif c == "[" then
			return parse_array()
		elseif c == '"' then
			return parse_string()
		elseif c:match("%d") or c == "-" then
			return parse_number()
		elseif c == "t" then
			if s:sub(pos, pos + 3) == "true" then
				pos = pos + 4
				return true
			end
		elseif c == "f" then
			if s:sub(pos, pos + 4) == "false" then
				pos = pos + 5
				return false
			end
		elseif c == "n" then
			if s:sub(pos, pos + 3) == "null" then
				pos = pos + 4
				return nil
			end
		end
	end
	--- @function: parse an object and increment pos
	--- @return table|nil
	parse_object = function()
		pos = pos + 1
		local obj = {}
		local has_red = false
		while true do
			skip_ws()
			if s:sub(pos, pos) == "}" then
				pos = pos + 1
				break
			end
			local key = parse_string()
			skip_ws()
			if s:sub(pos, pos) ~= ":" then
				error("expected :")
			end
			pos = pos + 1
			local value = parse_value()
			if key == nil then
				error("key is nil")
			end
			obj[key] = value
			if skip_red and value == "red" then
				has_red = true
			end
			skip_ws()
			if s:sub(pos, pos) == "}" then
				pos = pos + 1
				break
			end
			if s:sub(pos, pos) ~= "," then
				error("expected ,")
			end
			pos = pos + 1
		end
		if skip_red and has_red then
			return nil
		end
		return obj
	end
	--- @function: parse an array
	parse_array = function()
		pos = pos + 1
		local arr = {}
		while true do
			skip_ws()
			if s:sub(pos, pos) == "]" then
				pos = pos + 1
				break
			end
			local value = parse_value()
			table.insert(arr, value)
			skip_ws()
			if s:sub(pos, pos) == "]" then
				pos = pos + 1
				break
			end
			if s:sub(pos, pos) ~= "," then
				error("expected ,")
			end
			pos = pos + 1
		end
		return arr
	end
	--- parse the whole json
	return parse_value()
end

--- @function: sum all numbers in a lua table
local function sum_value(v)
	if v == nil then
		return 0
	end
	if type(v) == "number" then
		return v
	end
	if type(v) == "table" then
		local s = 0
		for _, val in pairs(v) do
			s = s + sum_value(val)
		end
		return s
	end
	return 0
end

--- @description sum all numbers in a json string ignoring red objects
--- @param input string
--- @return number|nil
function M.part2(input)
	input = input:gsub("\n", "")
	local root = parse_json(input, true)
	return sum_value(root)
end

return M
