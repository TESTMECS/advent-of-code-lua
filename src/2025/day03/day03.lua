local util = require("src.util")
local M = {}
local ex = [[ 
987654321111111
811111111111119
234234234234278
818181911112111
]]
---@description: voltage? == sum of largest two-digit number in each row.
---@param input string
---@return number
function M.part1(input)
	---@type number
	local joltage = 0
	for _, line in ipairs(util.read_lines(input)) do
		line = line:match("^%s*(.-)%s*$") -- trim whitespace
		-- Parse digits from row.
		if line ~= "" then
			---@type number[] Array of digits
			local nums = {}
			for i = 1, #line do
				local n = tonumber(line:sub(i, i))
				if n then
					nums[#nums + 1] = n
				end
			end
			---@type number length of nums
			local n = #nums
			if n >= 2 then
				-- Build rightMax array: rightMax[i] = maximum digit to the right of index i
				---@type table<number, number> Maps index to max digit on right.
				local rightMax = {}
				---@type number current maximum seen while scanning right to left.
				local curMax = nums[n]--[[@as number]]
				rightMax[n] = -1 -- no elements to the right of last.
				-- Scan backwards to populate rightMax for each position.
				for i = n - 1, 1, -1 do
					if nums[i + 1] >= curMax then
						curMax = nums[i + 1] --[[@as number]]
					end
					rightMax[i] = curMax
				end
				-- Find the best two digit number (nums[i]*10+rightMax[i])
				---@type number best value found so far
				local bestVal = -1
				for i = 1, n - 1 do
					---@type number Two digit number formed by nums[i] and rightMax[i]
					local candidate = (
						nums[i]--[[@as number]]
							* 10
						+ rightMax[i]
					)
					if candidate > bestVal then
						bestVal = candidate
					end
				end
				-- Add best value to joltage.
				if bestVal ~= -1 then
					joltage = joltage + bestVal
				end
			end
		end
	end
	return joltage
end

local function maxSubPickK(nums, k)
	local n = #nums
	local drop = n - k
	---@type number[] Stack to build result.
	local stack = {}
	for _, d in ipairs(nums) do
		-- Remove smaller elements from the stack while we can still drop.
		while drop > 0 and #stack > 0 and stack[#stack] < d do
			table.remove(stack) -- Remove the last element.
			drop = drop - 1
		end
		stack[#stack + 1] = d
	end
	while drop > 0 do
		table.remove(stack)
		drop = drop - 1
	end

	for i = 1, k do -- Fixed: was #k, should be k
		result[i] = stack[i]
	end
	return result
end

-- Converts array of digits to a number.
-- Warning: May lose precision for large numbers.
---@param digits number[] Array of single digits.
---@return number Integer value
local function seqToInt(digits)
	local v = 0
	for _, x in ipairs(digits) do
		v = v * 10 + x
	end
	return v
end

--- Converts array of digits to a string representation
--- @param digits number[] Array of single digits
--- @return string String representation of the number
local function seqToString(digits)
	local parts = {}
	for i, d in ipairs(digits) do
		parts[i] = tostring(d)
	end
	return table.concat(parts)
end

--- Converts array of digits to a big integer string
--- @param digits number[] Array of single digits
--- @return string String representation for big integer arithmetic
local function seqToBigInt(digits)
	return seqToString(digits)
end

--- Adds two big integers represented as strings
--- @param a string First number as string
--- @param b string Second number as string
--- @return string Sum as string
local function addBigInt(a, b)
	-- Reverse strings for easier digit-by-digit addition
	a = string.reverse(a)
	b = string.reverse(b)
	local maxLen = math.max(#a, #b)
	local result = {}
	local carry = 0
	for i = 1, maxLen do
		local digitA = tonumber(a:sub(i, i)) or 0
		local digitB = tonumber(b:sub(i, i)) or 0
		local sum = digitA + digitB + carry
		carry = math.floor(sum / 10)
		result[i] = tostring(sum % 10)
	end
	if carry > 0 then
		result[#result + 1] = tostring(carry)
	end
	return string.reverse(table.concat(result))
end

function M.part2(input)
	local k = 12
	local joltage = "0" -- Use string for big integer arithmetic

	for line in input:gmatch("[^\n]+") do
		line = line:match("^%s*(.-)%s*$") -- Trim whitespace

		if line ~= "" then
			-- Parse digits into nums array
			---@type number[] Array of single digits
			local nums = {}
			for i = 1, #line do
				local char = line:sub(i, i)
				local n = tonumber(char)
				if n then
					nums[#nums + 1] = n
				end
			end

			-- Get best k-digit subsequence
			local best = maxSubPickK(nums, k)
			local valueBig = seqToBigInt(best)

			-- Add to running total
			joltage = addBigInt(joltage, valueBig)
		end
	end

	print("Joltage:: " .. joltage)
end
return M
