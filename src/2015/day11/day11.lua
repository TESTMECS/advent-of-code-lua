--- @title: Day 11: Corporate Policy ---
local M = {}

--- @function: Increment the password by one character, handling the end of the alphabet
--- @param pw string: input string with no newlines
--- @return string: incremented password
local function increment(pw)
	local out = {}

	local carry = true
	for i = #pw, 1, -1 do
		local char = pw:sub(i, i)
		if carry then
			if char == "z" then
				table.insert(out, "a")
				carry = true
			else
				local code = string.byte(char)
				table.insert(out, string.char(code + 1))
				carry = false
			end
		else
			table.insert(out, char)
		end
	end

	if carry then
		table.insert(out, "a")
	end

	local res = ""
	res = table.concat(out)
	res = string.reverse(res)

	return res
end

--- @function: Check if the password is valid
--- @param pw string: input string with no newlines
--- @return boolean: true if valid
local function is_valid(pw)
	local alphabet = "abcdefghijklmnopqrstuvwxyz"

	local rule_1_ok = false
	for i = 1, #alphabet - 2 do
		local slice = alphabet:sub(i, i + 2)
		if pw:find(slice) then
			rule_1_ok = true
			break
		end
	end
	if rule_1_ok == false then
		return false
	end

	local rule_2_ok = true
	for i = 1, #pw do
		local char = pw:sub(i, i)
		if char == "i" or char == "o" or char == "l" then
			rule_2_ok = false
			break
		end
	end
	if rule_2_ok == false then
		-- print("Failed rule 2")
		return false
	end

	local rule_3_ok = false
	local pair_char = nil
	for i = 1, #pw - 1 do
		local first = pw:sub(i, i)
		local second = pw:sub(i + 1, i + 1)

		if first == second and first ~= pair_char then
			if pair_char then
				rule_3_ok = true
				break
			else
				pair_char = first
			end
		end
	end
	if rule_3_ok == false then
		return false
	end

	return true
end

--- @description Run the solution
--- @param input string
--- @return string
function M.part1(input)
	local pw = input:gsub("\n", "")
	repeat
		pw = increment(pw)
	until is_valid(pw)
	return pw
end

--- @description Run the solution
--- @param input string
--- @return string
function M.part2(input)
	local pw = input:gsub("\n", "")
	repeat
		pw = increment(pw)
	until is_valid(pw)
	repeat
		pw = increment(pw)
	until is_valid(pw)
	return pw
end

return M
