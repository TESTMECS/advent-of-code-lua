--- @title: Day 08: Space Image Format ---
local M = {}

--- @function: The input is just one long string, so we just need to trim any whitespace.
--- @param input string
--- @return string
local function parse_input(input)
	return input:match("^%s*(.-)%s*$")
end

--- @description Find a checksum based on the layer with the fewest zeros.
--- @param input string the puzzle input
--- @return number the number of 1s multiplied by the number of 2s on the target layer.
function M.part1(input)
	local data = parse_input(input)
	local width = 25
	local height = 6
	local layer_size = width * height

	local min_zeros = math.huge
	local result = 0

	-- Iterate through the data string in layer-sized chunks
	for i = 1, #data, layer_size do
		local layer_str = data:sub(i, i + layer_size - 1)

		local zero_count = 0
		local one_count = 0
		local two_count = 0

		-- Count the digits in the current layer
		for j = 1, #layer_str do
			local digit = layer_str:sub(j, j)
			if digit == "0" then
				zero_count = zero_count + 1
			elseif digit == "1" then
				one_count = one_count + 1
			elseif digit == "2" then
				two_count = two_count + 1
			end
		end

		-- If this layer has fewer zeros, it's our new candidate
		if zero_count < min_zeros then
			min_zeros = zero_count
			result = one_count * two_count
		end
	end

	return result
end

--- @description Decode the layered image and print the result.
--- @param input string the puzzle input
--- @return number Returns 0, as the real answer is the printed image.
function M.part2(input)
	local data = parse_input(input)
	local width = 25
	local height = 6
	local layer_size = width * height

	-- Initialize the final image with transparent pixels (2)
	local final_image = {}
	for i = 1, layer_size do
		final_image[i] = 2
	end

	-- Process each layer
	for i = 1, #data, layer_size do
		local layer_str = data:sub(i, i + layer_size - 1)

		for p = 1, layer_size do
			-- If the pixel on the final image is still transparent,
			-- set it to the color of the pixel on the current layer.
			if final_image[p] == 2 then
				final_image[p] = tonumber(layer_str:sub(p, p))
			end
		end
	end

	-- Build the output string for printing
	local output_string = "\n"
	for y = 0, height - 1 do
		local row_str = ""
		for x = 0, width - 1 do
			local index = y * width + x + 1
			if final_image[index] == 1 then
				row_str = row_str .. "█" -- White pixel
			else
				row_str = row_str .. " " -- Black pixel (or transparent, which doesn't happen in the final image)
			end
		end
		output_string = output_string .. row_str .. "\n"
	end

	print(output_string)

	-- The problem asks to decode the image, not return a number.
	-- We print the image and return 0 as a placeholder.
	return 0
end

return M
