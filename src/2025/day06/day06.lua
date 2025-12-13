local util = require("src.util")
local M = {}
---@description Solve the problems left-to-right
---@return number
function M.part1(input)
	---@param lines string[]
	---@param start_col integer
	---@param end_col integer
	---@return number
	local function parse_problemA(lines, start_col, end_col)
		--- collect numbers and op
		---@type number[]
		local numbers = {}
		local op = "+" ---@type string
		for _, line in ipairs(lines) do
			local problem_text = "" ---@type string
			if start_col <= #line then
				local actual_end = math.min(end_col - 1, #line)
				-- trim whitespace
				problem_text = string.sub(line, start_col, actual_end):match("^%s*(.-)%s*$")
				if #problem_text > 0 then -- Only process non-empty strings
					if problem_text == "*" or problem_text == "+" then
						op = problem_text
					else
						---@type number?
						local num = tonumber(problem_text)
						if num then -- Check if conversion succeeded
							table.insert(numbers, num)
						end
					end
				end
			end
		end
		if #numbers == 0 then
			return 0
		end
		-- Calculate the result for this col
		-- 'a: Start from 2 to avoid multiplying by itself
		local result = numbers[1]
		if op == "*" then
			for i = 2, #numbers do -- 'a
				result = result * numbers[i]
			end
		else
			for i = 2, #numbers do -- 'a
				result = result + numbers[i]
			end
		end
		return result
	end -- parse_problemA
	-- Read input
	local lines = util.read_lines(input) ---@type string[]
	-- Find len of rows
	local max_width = 0 ---@type number
	for _, line in ipairs(lines) do
		if #line > max_width then
			max_width = #line
		end
	end
	-- Begin solving
	local total = 0 ---@type number
	local col = 1 ---@type number
	while col <= max_width do
		-- trim line
		local has_content = false ---@type boolean
		for _, line in ipairs(lines) do
			if col <= #line and line:sub(col, col) ~= " " then
				has_content = true
				break
			end
		end
		if not has_content then
			col = col + 1
		else
			-- Find the extent of this problem
			local problem_start = col
			local problem_end = col
			while problem_end <= max_width do
				local is_empty_col = true ---@type boolean
				-- skip empty cols as seperators.
				for _, line in ipairs(lines) do
					if problem_end <= #line and line:sub(problem_end, problem_end) ~= " " then
						is_empty_col = false
						break
					end
				end
				if is_empty_col then
					break
				end
				problem_end = problem_end + 1
			end
			-- Parse and solve this problem
			---@type number
			local problemResult = parse_problemA(lines, problem_start, problem_end)
			total = total + problemResult
			col = problem_end + 1
		end
	end
	return total ---@type number
end
---@description Solve the problems right-to-left
---@return number
function M.part2(input)
	---@description Parse problem right-to-left
	---@param lines string[]
	---@param start_col number
	---@param end_col number
	---@return number
	local function parse_problemB(lines, start_col, end_col)
		-- Each column represents ONE number (reading rows top-to-bottom)
		-- Process columns right-to-left
		local numbers = {}
		local operator = "+"
		-- Read columns from right to left
		for col = end_col - 1, start_col, -1 do
			local digit_chars = {}
			-- For this column, read rows top to bottom
			for row = 1, #lines do
				local line = lines[row]
				if col <= #line then
					local ch = line:sub(col, col)
					if ch ~= " " then
						if ch == "*" or ch == "+" then
							operator = ch
						-- Don't break - continue to see if there are digits in this column
						elseif ch:match("%d") then
							table.insert(digit_chars, ch)
						end
					end
				end
			end
			-- Convert to number
			if #digit_chars > 0 then
				local num_str = table.concat(digit_chars)
				local num = tonumber(num_str)
				if num then
					table.insert(numbers, num)
				end
			end
		end
		if #numbers == 0 then
			return 0
		end
		-- Calculate result same as above
		local result = numbers[1]
		if operator == "*" then
			for i = 2, #numbers do
				result = result * numbers[i]
			end
		else
			for i = 2, #numbers do
				result = result + numbers[i]
			end
		end
		return result
	end -- parse_problemB
	-- Read input
	---@type string[]
	local lines = util.read_lines(input)
	if #lines == 0 then
		return 0
	end
	local max_width = 0
	for _, line in ipairs(lines) do
		if #line > max_width then
			max_width = #line
		end
	end
	-- Parse columns to find problems
	local grand_total = 0
	local col = 1
	while col <= max_width do
		local has_content = false
		for _, line in ipairs(lines) do
			if col <= #line and line:sub(col, col) ~= " " then
				has_content = true
				break
			end
		end
		if not has_content then
			col = col + 1
		else
			local problem_start = col
			local problem_end = col
			while problem_end <= max_width do
				local is_empty_col = true
				for _, line in ipairs(lines) do
					if problem_end <= #line and line:sub(problem_end, problem_end) ~= " " then
						is_empty_col = false
						break
					end
				end
				if is_empty_col then
					break
				end
				problem_end = problem_end + 1
			end
			local problem_result = parse_problemB(lines, problem_start, problem_end)
			grand_total = grand_total + problem_result
			col = problem_end + 1
		end
	end
	return grand_total ---@type number
end
return M
