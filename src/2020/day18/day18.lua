--- @title: Day 18: Operation Order ---
local M = {}
local util = require("util")

--- @function: Tokenizes an expression
--- @param expr string
--- @return table
local function tokenize(expr)
	local tokens = {}
	local i = 1
	while i <= #expr do
		local c = expr:sub(i, i)
		if c == " " then
			i = i + 1
		elseif c:match("%d") then
			local num = ""
			while i <= #expr and expr:sub(i, i):match("%d") do
				num = num .. expr:sub(i, i)
				i = i + 1
			end
			table.insert(tokens, tonumber(num))
		elseif c == "+" or c == "*" then
			table.insert(tokens, c)
			i = i + 1
		elseif c == "(" then
			local count = 1
			local start = i
			i = i + 1
			while i <= #expr and count > 0 do
				if expr:sub(i, i) == "(" then
					count = count + 1
				elseif expr:sub(i, i) == ")" then
					count = count - 1
				end
				i = i + 1
			end
			table.insert(tokens, tokenize(expr:sub(start + 1, i - 2)))
		end
	end
	return tokens
end

--- @function: Evaluates an expression
--- @param tokens table
--- @return number
local function evaluate1(tokens)
	if type(tokens) == "number" then
		return tokens
	end
	if type(tokens) == "table" then
		local result = evaluate1(tokens[1])
		for i = 2, #tokens, 2 do
			local op = tokens[i]
			local num = evaluate1(tokens[i + 1])
			if op == "+" then
				result = result + num
			elseif op == "*" then
				result = result * num
			end
		end
		return result
	end
end

--- @description Sum evaluations with left-to-right precedence
--- @param input string the puzzle input
--- @return number the sum
function M.part1(input)
	local lines = util.read_lines(input)
	local sum = 0
	for _, line in ipairs(lines) do
		local tokens = tokenize(line)
		sum = sum + evaluate1(tokens)
	end
	return sum
end

--- @function: Evaluates an expression
--- @param tokens table
--- @return number
local function evaluate2(tokens)
	if type(tokens) == "number" then
		return tokens
	end
	if type(tokens) == "table" then
		local new_tokens = {}
		for _, t in ipairs(tokens) do
			table.insert(new_tokens, type(t) == "table" and evaluate2(t) or t)
		end
		while true do
			local found = false
			for i = 2, #new_tokens - 1 do
				if new_tokens[i] == "+" then
					local left = new_tokens[i - 1]
					local right = new_tokens[i + 1]
					local res = left + right
					new_tokens[i - 1] = res
					table.remove(new_tokens, i)
					table.remove(new_tokens, i)
					found = true
					break
				end
			end
			if not found then
				break
			end
		end
		local result = new_tokens[1]
		for i = 2, #new_tokens, 2 do
			local op = new_tokens[i]
			local num = new_tokens[i + 1]
			if op == "*" then
				result = result * num
			end
		end
		return result
	end
	return 0
end

--- @description Sum evaluations with + higher precedence
--- @param input string the puzzle input
--- @return number the sum
function M.part2(input)
	local lines = util.read_lines(input)
	local sum = 0
	for _, line in ipairs(lines) do
		local tokens = tokenize(line)
		sum = sum + evaluate2(tokens)
	end
	return sum
end

return M
