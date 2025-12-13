--- @title: --- Day 12: Hot Springs ---
local M = {}

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part1(input)
	local function count_ways(pattern, groups)
		local memo = {}
		local function dp(i, j, curr)
			local key = i .. "," .. j .. "," .. curr
			if memo[key] then
				return memo[key]
			end
			if i == #pattern + 1 then
				if j == #groups + 1 and curr == 0 then
					return 1
				elseif j == #groups and curr == groups[j] then
					return 1
				else
					return 0
				end
			end
			local res = 0
			local c = pattern:sub(i, i)
			if c == "?" or c == "." then
				if curr == 0 then
					res = res + dp(i + 1, j, 0)
				else
					if j <= #groups and curr == groups[j] then
						res = res + dp(i + 1, j + 1, 0)
					end
				end
			end
			if c == "?" or c == "#" then
				res = res + dp(i + 1, j, curr + 1)
			end
			memo[key] = res
			return res
		end
		return dp(1, 1, 0)
	end
	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local pattern, groups_str = line:match("([^%s]+)%s+(.+)")
		local groups = {}
		for num in groups_str:gmatch("%d+") do
			table.insert(groups, tonumber(num))
		end
		sum = sum + count_ways(pattern, groups)
	end
	return sum
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local function count_ways(pattern, groups)
		local memo = {}
		local function dp(i, j, curr)
			local key = i .. "," .. j .. "," .. curr
			if memo[key] then
				return memo[key]
			end
			if i == #pattern + 1 then
				if j == #groups + 1 and curr == 0 then
					return 1
				elseif j == #groups and curr == groups[j] then
					return 1
				else
					return 0
				end
			end
			local res = 0
			local c = pattern:sub(i, i)
			if c == "?" or c == "." then
				if curr == 0 then
					res = res + dp(i + 1, j, 0)
				else
					if j <= #groups and curr == groups[j] then
						res = res + dp(i + 1, j + 1, 0)
					end
				end
			end
			if c == "?" or c == "#" then
				res = res + dp(i + 1, j, curr + 1)
			end
			memo[key] = res
			return res
		end
		return dp(1, 1, 0)
	end

	local sum = 0
	for line in input:gmatch("[^\n]+") do
		local pattern, groups_str = line:match("([^%s]+)%s+(.+)")
		local groups = {}
		for num in groups_str:gmatch("%d+") do
			table.insert(groups, tonumber(num))
		end

		-- build unfolded pattern (5 copies total)
		local new_pattern = pattern
		for _ = 2, 5 do
			new_pattern = new_pattern .. "?" .. pattern
		end

		-- build unfolded groups (5 copies total)
		local new_groups = {}
		for _ = 1, 5 do
			for _, g in ipairs(groups) do
				table.insert(new_groups, g)
			end
		end

		sum = sum + count_ways(new_pattern, new_groups)
	end
	return sum
end
return M
