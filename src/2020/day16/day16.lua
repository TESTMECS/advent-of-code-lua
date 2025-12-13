--- @title: Day 16: Ticket Translation ---
local M = {}

--- @description: Sum invalid values in nearby tickets
--- @param input string: the puzzle input
--- @return number: the sum
function M.part1(input)
	input = input:gsub("\r", "")
	local sections = {}
	for s in input:gmatch("(.-)\n\n") do
		table.insert(sections, s)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(sections, last)
	end
	local rules = {}
	for line in sections[1]:gmatch("[^\n]+") do
		local field, rest = line:match("(.+): (.+)")
		local ranges = {}
		for range in rest:gmatch("(%d+-%d+)") do
			local a, b = range:match("(%d+)-(%d+)")
			table.insert(ranges, { tonumber(a), tonumber(b) })
		end
		rules[field] = ranges
	end
	local nearby = {}
	for line in sections[3]:gmatch("[^\n]+") do
		if line ~= "nearby tickets:" then
			local ticket = {}
			for num in line:gmatch("%d+") do
				table.insert(ticket, tonumber(num))
			end
			table.insert(nearby, ticket)
		end
	end
	--- @local: Checks if a value is valid
	--- @param v number: the value
	--- @return boolean
	local function valid_value(v)
		for _, ranges in pairs(rules) do
			for _, r in ipairs(ranges) do
				if v >= r[1] and v <= r[2] then
					return true
				end
			end
		end
		return false
	end
	local sum = 0
	for _, ticket in ipairs(nearby) do
		for _, v in ipairs(ticket) do
			if not valid_value(v) then
				sum = sum + v
			end
		end
	end
	return sum
end

--- @description Determine field order and multiply departure fields
--- @param input string the puzzle input
--- @return number the product
function M.part2(input)
	input = input:gsub("\r", "")
	local sections = {}
	for s in input:gmatch("(.-)\n\n") do
		table.insert(sections, s)
	end
	local last = input:match(".*\n\n(.*)$")
	if last then
		table.insert(sections, last)
	end
	local rules = {}
	for line in sections[1]:gmatch("[^\n]+") do
		local field, rest = line:match("(.+): (.+)")
		local ranges = {}
		for range in rest:gmatch("(%d+-%d+)") do
			local a, b = range:match("(%d+)-(%d+)")
			table.insert(ranges, { tonumber(a), tonumber(b) })
		end
		rules[field] = ranges
	end
	local your_ticket = {}
	for line in sections[2]:gmatch("[^\n]+") do
		if line ~= "your ticket:" then
			for num in line:gmatch("%d+") do
				table.insert(your_ticket, tonumber(num))
			end
		end
	end
	local nearby = {}
	for line in sections[3]:gmatch("[^\n]+") do
		if line ~= "nearby tickets:" then
			local ticket = {}
			for num in line:gmatch("%d+") do
				table.insert(ticket, tonumber(num))
			end
			table.insert(nearby, ticket)
		end
	end
	--- @local: Checks if a value is valid
	--- @param v number: the value
	--- @return boolean
	local function valid_value(v)
		for _, ranges in pairs(rules) do
			for _, r in ipairs(ranges) do
				if v >= r[1] and v <= r[2] then
					return true
				end
			end
		end
		return false
	end
	local valid_tickets = {}
	for _, ticket in ipairs(nearby) do
		local valid = true
		for _, v in ipairs(ticket) do
			if not valid_value(v) then
				valid = false
				break
			end
		end
		if valid then
			table.insert(valid_tickets, ticket)
		end
	end
	local n = #your_ticket
	local possible = {}
	for i = 1, n do
		possible[i] = {}
		for field, _ in pairs(rules) do
			table.insert(possible[i], field)
		end
	end
	for _, ticket in ipairs(valid_tickets) do
		for i = 1, n do
			local v = ticket[i]
			local new_possible = {}
			for _, field in ipairs(possible[i]) do
				local ranges = rules[field]
				local match = false
				for _, r in ipairs(ranges) do
					if v >= r[1] and v <= r[2] then
						match = true
						break
					end
				end
				if match then
					table.insert(new_possible, field)
				end
			end
			possible[i] = new_possible
		end
	end
	local assigned = {}
	local field_order = {}
	while true do
		local found = false
		for i = 1, n do
			if #possible[i] == 1 and not assigned[possible[i][1]] then
				local field = possible[i][1]
				assigned[field] = true
				field_order[i] = field
				found = true
				for j = 1, n do
					if j ~= i then
						for k = #possible[j], 1, -1 do
							if possible[j][k] == field then
								table.remove(possible[j], k)
							end
						end
					end
				end
			end
		end
		if not found then
			break
		end
	end
	local product = 1
	for i = 1, n do
		if field_order[i] and field_order[i]:find("^departure") then
			product = product * your_ticket[i]
		end
	end
	return product
end

return M
