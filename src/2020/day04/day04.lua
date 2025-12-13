--- @title: --- Day 4: Passport Processing ---
local M = {}
--- @function: Checks if a string is a valid year.
--- @param s string
--- @param min number
--- @param max number
--- @return boolean
local function is_year_valid(s, min, max)
	if not s then
		return false
	end
	if not s:match("^%d%d%d%d$") then
		return false
	end
	local year = tonumber(s)
	return year >= min and year <= max
end

--- @function: Checks if a string is a valid height.
--- @param s string
--- @return boolean
local function is_height_valid(s)
	if not s then
		return false
	end
	s = s:match("^%s*(.-)%s*$") -- trim whitespace
	local num, unit = s:match("^(%d+)(cm)$")
	if not num then
		num, unit = s:match("^(%d+)(in)$")
	end
	if not num then
		return false
	end
	num = tonumber(num)
	if unit == "cm" then
		return num >= 150 and num <= 193
	elseif unit == "in" then
		return num >= 59 and num <= 76
	end
	return false
end

--- @function: Checks if a string is a valid hair color.
--- @param s string
--- @return boolean
local function is_hair_color_valid(s)
	if not s then
		return false
	end
	return s:match("^#%x%x%x%x%x%x$") ~= nil
end

local valid_eye_colors = { amb = true, blu = true, brn = true, gry = true, grn = true, hzl = true, oth = true }
--- @function: Checks if a string is a valid eye color.
--- @param s string
--- @return boolean
local function is_eye_color_valid(s)
	if not s then
		return false
	end

	return valid_eye_colors[s] or false
end

--- @function: Checks if a string is a valid passport ID.
--- @param s string
--- @return boolean
local function is_passport_id_valid(s)
	if not s then
		return false
	end
	s = s:match("^%s*(.-)%s*$") -- trim whitespace
	return #s == 9 and s:match("^%d+$") ~= nil
end

--- @function: Checks if a passport has all required fields.
--- @param passport table
--- @return boolean
local function has_required_fields(passport)
	return passport.byr
		and passport.iyr
		and passport.eyr
		and passport.hgt
		and passport.hcl
		and passport.ecl
		and passport.pid
end

--- @function: Checks if a passport has all valid fields.
--- @param passport table
--- @return boolean
local function has_valid_fields(passport)
	return is_year_valid(passport.byr, 1920, 2002)
		and is_year_valid(passport.iyr, 2010, 2020)
		and is_year_valid(passport.eyr, 2020, 2030)
		and is_height_valid(passport.hgt)
		and is_hair_color_valid(passport.hcl)
		and is_eye_color_valid(passport.ecl)
		and is_passport_id_valid(passport.pid)
end
--- @function: Solves the puzzle.
--- @param input string
--- @return number
--- @return number
local function solve(input)
	local count1, count2 = 0, 0
	local current_passport = {}

	-- Normalize newlines and ensure last passport is processed
	local processed_input = input:gsub("\r", "") .. "\n\n"

	for line in processed_input:gmatch("(.-)\n") do
		if line:match("^%s*$") then
			-- Blank line = end of current passport
			if has_required_fields(current_passport) then
				count1 = count1 + 1
				if has_valid_fields(current_passport) then
					count2 = count2 + 1
				end
			end
			current_passport = {}
		else
			-- Parse all key:value pairs
			for key, value in line:gmatch("(%w+):([^%s]+)") do
				-- Trim any accidental whitespace
				value = value:match("^%s*(.-)%s*$")
				current_passport[key] = value:lower()
			end
		end
	end

	return count1, count2
end
--- @description: Count the number of passports that are valid
--- @param input string: The puzzle input.
--- @return number: The answer.
function M.part1(input)
	local count1, _ = solve(input)
	return count1
end

--- @description: Count the number of passports that are valid and have all required fields
--- @param input string: The puzzle input.
--- @return number: The answer.
function M.part2(input)
	local _, count2 = solve(input)
	return count2
end

return M
