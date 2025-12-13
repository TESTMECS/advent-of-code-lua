--- @title: Day 20: Firewall Rules ---
local M = {}

--- @function: Parses the input string into a table of ranges.
--- @param input string: The list of blocked IP ranges.
--- @return table: The ranges.
local function parse_input(input)
	local ranges = {}
	for line in input:gmatch("[^\r\n]+") do
		local start_ip, end_ip = line:match("(%d+)-(%d+)")
		if start_ip and end_ip then
			table.insert(ranges, { start = tonumber(start_ip), finish = tonumber(end_ip) })
		end
	end
	return ranges
end

--- @function: Merges overlapping and adjacent ranges.
--- @param ranges table: The ranges.
--- @return table: The merged ranges.
local function merge_ranges(ranges)
	if #ranges == 0 then
		return {}
	end

	-- Sort ranges by their start IP.
	table.sort(ranges, function(a, b)
		return a.start < b.start
	end)

	local merged = { ranges[1] }
	for i = 2, #ranges do
		local last = merged[#merged]
		local current = ranges[i]

		if current.start <= last.finish + 1 then
			-- Merge overlapping or adjacent ranges.
			last.finish = math.max(last.finish, current.finish)
		else
			-- Add a new non-overlapping range.
			table.insert(merged, current)
		end
	end

	return merged
end

--- @description: Finds the lowest-valued IP that is not blocked.
--- @param input string: The list of blocked IP ranges.
--- @return number: The lowest allowed IP.
function M.part1(input)
	local ranges = parse_input(input)
	local merged = merge_ranges(ranges)
	-- The first allowed IP is one greater than the end of the first blocked range.
	return merged[1].finish + 1
end

--- @description: Counts the total number of allowed IPs.
--- @param input string: The list of blocked IP ranges.
--- @return number: The total count of allowed IPs.
function M.part2(input)
	local ranges = parse_input(input)
	local merged = merge_ranges(ranges)

	local max_ip = 4294967295
	local blocked_count = 0
	for _, r in ipairs(merged) do
		blocked_count = blocked_count + (r.finish - r.start + 1)
	end

	return max_ip + 1 - blocked_count
end

return M
