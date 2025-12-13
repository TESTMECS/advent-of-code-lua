--- @title: Day 20: Trench Map ---
local M = {}

--- @description Parses the input into an algorithm string and an image grid.
--- @param input string The puzzle input.
--- @return string, table The algorithm and the image (grid of booleans).
local function parse_input(input)
	local algorithm_str, image_str = input:match("([^\r\n]+)\n\n(.+)")

	local image = {}
	for line in image_str:gmatch("[^\r\n]+") do
		local row = {}
		for char in line:gmatch(".") do
			table.insert(row, char == "#")
		end
		table.insert(image, row)
	end

	return algorithm_str, image
end

--- @description Enhances an image one time.
--- @param image table The current image grid.
--- @param algorithm string The enhancement algorithm.
--- @param current_default boolean The state of the infinite pixels around the image.
--- @return table, boolean The new, larger image grid and the new default pixel state.
local function enhance(image, algorithm, current_default)
	local height = #image
	local width = #image[1]
	local new_image = {}

	-- The new image has a 1-pixel border, so it's 2 pixels taller and wider.
	for r_new = 1, height + 2 do
		new_image[r_new] = {}
		for c_new = 1, width + 2 do
			local binary_string = ""
			-- Look at the 3x3 grid in the old image space.
			-- A pixel at (r_new, c_new) in the new grid is centered on
			-- the coordinate (r_new - 1, c_new - 1) in the old grid's space.
			for dr = -1, 1 do
				for dc = -1, 1 do
					local r_old = (r_new - 1) + dr
					local c_old = (c_new - 1) + dc

					local is_lit
					if r_old >= 1 and r_old <= height and c_old >= 1 and c_old <= width then
						is_lit = image[r_old][c_old]
					else
						is_lit = current_default
					end
					binary_string = binary_string .. (is_lit and "1" or "0")
				end
			end

			local index = tonumber(binary_string, 2)
			new_image[r_new][c_new] = (algorithm:sub(index + 1, index + 1) == "#")
		end
	end

	-- Determine the new default for the infinite void.
	local new_default
	if not current_default then -- If the void was dark...
		new_default = (algorithm:sub(1, 1) == "#") -- ...it becomes the value at index 0.
	else -- If the void was lit...
		new_default = (algorithm:sub(512, 512) == "#") -- ...it becomes the value at index 511.
	end

	return new_image, new_default
end

--- @description Solves the puzzle for a given number of steps.
--- @param input string The puzzle input.
--- @param steps number The number of enhancement steps to perform.
--- @return number The number of lit pixels.
local function solve(input, steps)
	local algorithm, image = parse_input(input)
	local default_pixel = false -- The infinite grid starts dark.

	for _ = 1, steps do
		image, default_pixel = enhance(image, algorithm, default_pixel)
	end

	-- After all steps, the infinite grid might be lit. If so, that's infinite pixels.
	-- The puzzle is designed so this doesn't happen, but it's good practice to note.
	-- The question only asks to count lit pixels in the final bounded image.
	local count = 0
	for _, row in ipairs(image) do
		for _, is_lit in ipairs(row) do
			if is_lit then
				count = count + 1
			end
		end
	end

	return count
end

--- @description Enhance the image twice and count lit pixels.
--- @param input string The puzzle input.
--- @return number The number of lit pixels.
function M.part1(input)
	return solve(input, 2)
end

--- @description Enhance the image 50 times and count lit pixels.
--- @param input string The puzzle input.
--- @return number The number of lit pixels.
function M.part2(input)
	return solve(input, 50)
end

return M
