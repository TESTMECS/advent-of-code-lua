local M = {}

--- Parse a mapping section and return the ranges
--- @param lines table array of lines for this mapping
--- @return table array of {dest_start, source_start, length}
local function parse_mapping(lines)
	local ranges = {}
	for i = 2, #lines do -- Skip the header line
		local dest, source, length = lines[i]:match("(%d+) (%d+) (%d+)")
		if dest then
			table.insert(ranges, {
				dest_start = tonumber(dest),
				source_start = tonumber(source),
				length = tonumber(length),
			})
		end
	end
	return ranges
end

--- Apply a mapping to convert a source number to destination number
--- @param source_num number the input number
--- @param ranges table array of mapping ranges
--- @return number the mapped destination number
local function apply_mapping(source_num, ranges)
	for _, range in ipairs(ranges) do
		local source_end = range.source_start + range.length - 1
		if source_num >= range.source_start and source_num <= source_end then
			local offset = source_num - range.source_start
			return range.dest_start + offset
		end
	end
	-- If no mapping found, return the same number
	return source_num
end

--- Apply mapping to a range, returning multiple ranges
--- @param input_ranges table array of {start, length} ranges
--- @param mapping_ranges table array of mapping rules
--- @return table array of mapped {start, length} ranges
local function apply_mapping_to_ranges(input_ranges, mapping_ranges)
	local result = {}

	for _, input_range in ipairs(input_ranges) do
		local start = input_range.start
		local length = input_range.length
		local end_pos = start + length - 1
		local processed = {}

		-- Check each mapping range for overlaps
		for _, map_range in ipairs(mapping_ranges) do
			local map_start = map_range.source_start
			local map_end = map_range.source_start + map_range.length - 1

			-- Find overlap between input range and mapping range
			local overlap_start = math.max(start, map_start)
			local overlap_end = math.min(end_pos, map_end)

			if overlap_start <= overlap_end then
				-- There's an overlap - map this portion
				local offset = map_range.dest_start - map_range.source_start
				table.insert(result, {
					start = overlap_start + offset,
					length = overlap_end - overlap_start + 1,
				})

				-- Mark this range as processed
				table.insert(processed, { start = overlap_start, end_pos = overlap_end })
			end
		end

		-- Sort processed ranges by start position
		table.sort(processed, function(a, b)
			return a.start < b.start
		end)

		-- Add unmapped portions (gaps between processed ranges)
		local current_pos = start
		for _, proc in ipairs(processed) do
			if current_pos < proc.start then
				-- Gap before this processed range
				table.insert(result, {
					start = current_pos,
					length = proc.start - current_pos,
				})
			end
			current_pos = proc.end_pos + 1
		end

		-- Add remaining unmapped portion at the end
		if current_pos <= end_pos then
			table.insert(result, {
				start = current_pos,
				length = end_pos - current_pos + 1,
			})
		end
	end

	return result
end

--- Parse the input and extract seeds and all mappings
--- @param input string the puzzle input
--- @return table seeds, table mappings
local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		if line:match("%S") then -- Only add non-empty lines
			table.insert(lines, line)
		end
	end

	-- Parse seeds
	local seeds = {}
	local seeds_line = lines[1]:match("seeds: (.+)")
	if seeds_line then
		for seed in seeds_line:gmatch("(%d+)") do
			table.insert(seeds, tonumber(seed))
		end
	end

	-- Parse mappings
	local mappings = {}
	local current_mapping = {}
	local i = 2 -- Start after seeds line

	while i <= #lines do
		local line = lines[i]
		if line:match("map:") then
			-- If we have a previous mapping, save it
			if #current_mapping > 0 then
				table.insert(mappings, parse_mapping(current_mapping))
			end
			-- Start new mapping
			current_mapping = { line }
		elseif line:match("^%d") then
			-- Mapping data line
			table.insert(current_mapping, line)
		end
		i = i + 1
	end

	-- Don't forget the last mapping
	if #current_mapping > 0 then
		table.insert(mappings, parse_mapping(current_mapping))
	end

	return seeds, mappings
end

--- Find the location number for a given seed
--- @param seed number the seed number
--- @param mappings table array of all mappings
--- @return number the final location number
local function seed_to_location(seed, mappings)
	local current = seed
	for _, mapping in ipairs(mappings) do
		current = apply_mapping(current, mapping)
	end
	return current
end

--- @description Find the lowest location number that corresponds to any of the initial seed numbers
--- @param input string the puzzle input
--- @return number the lowest location number
function M.part1(input)
	local seeds, mappings = parse_input(input)

	local min_location = math.huge
	for _, seed in ipairs(seeds) do
		local location = seed_to_location(seed, mappings)
		min_location = math.min(min_location, location)
	end

	return min_location
end

--- @description Part 2 implementation (seeds represent ranges) - optimized
--- @param input string the puzzle input
--- @return number the lowest location number from seed ranges
function M.part2(input)
	local seeds, mappings = parse_input(input)

	-- Convert seed pairs to ranges
	local current_ranges = {}
	for i = 1, #seeds, 2 do
		table.insert(current_ranges, {
			start = seeds[i],
			length = seeds[i + 1],
		})
	end

	-- Apply each mapping to all current ranges
	for _, mapping in ipairs(mappings) do
		current_ranges = apply_mapping_to_ranges(current_ranges, mapping)
	end

	-- Find the minimum start position among all final ranges
	local min_location = math.huge
	for _, range in ipairs(current_ranges) do
		min_location = math.min(min_location, range.start)
	end

	return min_location
end

return M
