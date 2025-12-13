--- @title: --- Day 5: Print Queue ---
local M = {}

--- @description Sum the middle pages of correctly ordered updates
--- @param input string the puzzle input
--- @return number the sum of middle pages
function M.part1(input)
	local rules = {}
	local updates = {}
	local parsing_rules = true
	for line in input:gmatch("[^\n]+") do
		if line:find(",") then
			parsing_rules = false
		end
		if parsing_rules then
			local a, b = line:match("(%d+)%s*|%s*(%d+)")
			if a and b then
				local na, nb = tonumber(a), tonumber(b)
				rules[na] = rules[na] or {}
				table.insert(rules[na], nb)
			end
		else
			local update = {}
			for num in line:gmatch("%d+") do
				table.insert(update, tonumber(num))
			end
			table.insert(updates, update)
		end
	end

	local function is_correct(update)
		local pos = {}
		for i, page in ipairs(update) do
			pos[page] = i
		end
		for before, afters in pairs(rules) do
			if pos[before] then
				for _, after in ipairs(afters) do
					if pos[after] and pos[before] > pos[after] then
						return false
					end
				end
			end
		end
		return true
	end

	local sum = 0
	for _, update in ipairs(updates) do
		if is_correct(update) then
			sum = sum + update[math.ceil(#update / 2)]
		end
	end
	return sum
end

--- @description Sum the middle pages of corrected updates
--- @param input string the puzzle input
--- @return number the sum of middle pages after correction
function M.part2(input)
	local rules = {}
	local updates = {}
	local parsing_rules = true
	for line in input:gmatch("[^\n]+") do
		if line:find(",") then
			parsing_rules = false
		end
		if parsing_rules then
			local a, b = line:match("(%d+)%s*|%s*(%d+)")
			if a and b then
				local na, nb = tonumber(a), tonumber(b)
				rules[na] = rules[na] or {}
				table.insert(rules[na], nb)
			end
		else
			local update = {}
			for num in line:gmatch("%d+") do
				table.insert(update, tonumber(num))
			end
			table.insert(updates, update)
		end
	end

	local function is_correct(update)
		local pos = {}
		for i, page in ipairs(update) do
			pos[page] = i
		end
		for before, afters in pairs(rules) do
			if pos[before] then
				for _, after in ipairs(afters) do
					if pos[after] and pos[before] > pos[after] then
						return false
					end
				end
			end
		end
		return true
	end

	local function compare(a, b)
		if rules[a] then
			for _, after in ipairs(rules[a]) do
				if after == b then
					return true
				end
			end
		end
		if rules[b] then
			for _, after in ipairs(rules[b]) do
				if after == a then
					return false
				end
			end
		end
		return false
	end

	local sum = 0
	for _, update in ipairs(updates) do
		if not is_correct(update) then
			table.sort(update, compare)
			sum = sum + update[math.ceil(#update / 2)]
		end
	end
	return sum
end

return M
