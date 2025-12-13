--- @title: Day 9: Disk Fragmenter
local M = {}

--- @description Calculate checksum after compacting files
--- @param input string the puzzle input
--- @return number the checksum
function M.part1(input)
	input = input:gsub("\n", "")
	local disk = {}
	local id = 0
	local is_file = true
	for i = 1, #input do
		local size = tonumber(input:sub(i, i))
		for _ = 1, size do
			if is_file then
				table.insert(disk, id)
			else
				table.insert(disk, -1)
			end
		end
		if is_file then
			id = id + 1
		end
		is_file = not is_file
	end
	local left, right = 1, #disk
	while left < right do
		while left < right and disk[left] ~= -1 do
			left = left + 1
		end
		while left < right and disk[right] == -1 do
			right = right - 1
		end
		if left < right then
			disk[left], disk[right] = disk[right], disk[left]
			left, right = left + 1, right - 1
		end
	end
	local checksum = 0
	for i = 1, #disk do
		if disk[i] ~= -1 then
			checksum = checksum + (i - 1) * disk[i]
		end
	end
	return checksum
end

--- @description Calculate checksum after moving whole files
--- @param input string the puzzle input
--- @return number the checksum
function M.part2(input)
	input = input:gsub("\n", "")
	local files = {}
	local free = {}
	local pos = 0
	local id = 0
	local is_file = true
	for i = 1, #input do
		local size = tonumber(input:sub(i, i))
		if is_file then
			table.insert(files, { id = id, pos = pos, size = size })
			id = id + 1
		else
			table.insert(free, { pos = pos, size = size })
		end
		pos = pos + size
		is_file = not is_file
	end
	for i = #files, 1, -1 do
		local file = files[i]
		for j = 1, #free do
			local f = free[j]
			if f.pos < file.pos and f.size >= file.size then
				file.pos = f.pos
				f.pos = f.pos + file.size
				f.size = f.size - file.size
				break
			end
		end
	end
	local checksum = 0
	for _, file in ipairs(files) do
		for k = 0, file.size - 1 do
			checksum = checksum + (file.pos + k) * file.id
		end
	end
	return checksum
end

return M
