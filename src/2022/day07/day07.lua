--- @title: --- Day 7: No Space Left On Device ---
local M = {}

local function parse_input(input)
	local lines = {}
	for line in input:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	local dirs = {}
	local current = ""
	for _, line in ipairs(lines) do
		if line:sub(1, 4) == "$ cd" then
			local dir = line:sub(6)
			if dir == "/" then
				current = "/"
			elseif dir == ".." then
				current = current:match("(.+)/") or "/"
			else
				current = current .. "/" .. dir
			end
			if not dirs[current] then
				dirs[current] = {files = {}, subdirs = {}}
			end
		elseif line:sub(1, 4) == "$ ls" then
			-- do nothing
		elseif line:sub(1, 3) == "dir" then
			local name = line:sub(5)
			dirs[current].subdirs[name] = true
		else
			local size, name = line:match("(%d+) (.+)")
			if size then
				dirs[current].files[name] = tonumber(size)
			end
		end
	end
	return dirs
end

local function calc_size(dirs, path)
	local dir = dirs[path]
	if not dir then return 0 end
	local size = 0
	for _, fsize in pairs(dir.files) do
		size = size + fsize
	end
	for sub in pairs(dir.subdirs) do
		size = size + calc_size(dirs, path .. "/" .. sub)
	end
	dir.size = size
	return size
end

local all_sizes = {}
local function traverse(dirs, path)
	local dir = dirs[path]
	if not dir then return end
	table.insert(all_sizes, dir.size)
	for sub in pairs(dir.subdirs) do
		traverse(dirs, path .. "/" .. sub)
	end
end

--- @description: Sum sizes of directories with size <= 100000
--- @param input string the puzzle input
--- @return number: the sum
function M.part1(input)
	local dirs = parse_input(input)
	calc_size(dirs, "/")
	all_sizes = {}
	traverse(dirs, "/")
	local sum = 0
	for _, size in ipairs(all_sizes) do
		if size <= 100000 then
			sum = sum + size
		end
	end
	return sum
end

--- @description: Find smallest directory to delete to free up space
--- @param input string the puzzle input
--- @return number: the size
function M.part2(input)
	local dirs = parse_input(input)
	calc_size(dirs, "/")
	all_sizes = {}
	traverse(dirs, "/")
	if not dirs["/"] then return 0 end
	local used = dirs["/"].size
	local free = 70000000 - used
	local need = 30000000 - free
	local min_size = math.huge
	for _, size in ipairs(all_sizes) do
		if size >= need and size < min_size then
			min_size = size
		end
	end
	return min_size == math.huge and 0 or min_size
end

return M
