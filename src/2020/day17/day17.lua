--- @title: Day 17: Conway Cubes ---
local M = {}
local util = require("util")

--- @description: Simulate 6 cycles in 3D, count active cubes
--- @param input string: the puzzle input
--- @return number: the count
function M.part1(input)
	local lines = util.read_lines(input)
	local active = {}
	for y = 1, #lines do
		local line = lines[y]
		for x = 1, #line do
			if line:sub(x, x) == "#" then
				active[x - 1] = active[x - 1] or {}
				active[x - 1][y - 1] = active[x - 1][y - 1] or {}
				active[x - 1][y - 1][0] = true
			end
		end
	end
	for _ = 1, 6 do
		local new_active = {}
		local to_check = {}
		for x, yz in pairs(active) do
			for y, zt in pairs(yz) do
				for z, _ in pairs(zt) do
					for dx = -1, 1 do
						for dy = -1, 1 do
							for dz = -1, 1 do
								local nx, ny, nz = x + dx, y + dy, z + dz
								to_check[nx .. "," .. ny .. "," .. nz] = { nx, ny, nz }
							end
						end
					end
				end
			end
		end
		for _, pos in pairs(to_check) do
			local x, y, z = pos[1], pos[2], pos[3]
			local count = 0
			for dx = -1, 1 do
				for dy = -1, 1 do
					for dz = -1, 1 do
						if dx ~= 0 or dy ~= 0 or dz ~= 0 then
							if active[x + dx] and active[x + dx][y + dy] and active[x + dx][y + dy][z + dz] then
								count = count + 1
							end
						end
					end
				end
			end
			local is_active = active[x] and active[x][y] and active[x][y][z]
			if (is_active and (count == 2 or count == 3)) or (not is_active and count == 3) then
				new_active[x] = new_active[x] or {}
				new_active[x][y] = new_active[x][y] or {}
				new_active[x][y][z] = true
			end
		end
		active = new_active
	end
	local count = 0
	for _, yz in pairs(active) do
		for _, zt in pairs(yz) do
			for _ in pairs(zt) do
				count = count + 1
			end
		end
	end
	return count
end

--- @description: Simulate 6 cycles in 4D, count active cubes
--- @param input string: the puzzle input
--- @return number: the count
function M.part2(input)
	local lines = util.read_lines(input)
	local active = {}
	for y = 1, #lines do
		local line = lines[y]
		for x = 1, #line do
			if line:sub(x, x) == "#" then
				active[x - 1] = active[x - 1] or {}
				active[x - 1][y - 1] = active[x - 1][y - 1] or {}
				active[x - 1][y - 1][0] = active[x - 1][y - 1][0] or {}
				active[x - 1][y - 1][0][0] = true
			end
		end
	end
	for cycle = 1, 6 do
		local new_active = {}
		local to_check = {}
		for x, yz in pairs(active) do
			for y, zt in pairs(yz) do
				for z, wt in pairs(zt) do
					for w, _ in pairs(wt) do
						for dx = -1, 1 do
							for dy = -1, 1 do
								for dz = -1, 1 do
									for dw = -1, 1 do
										local nx, ny, nz, nw = x + dx, y + dy, z + dz, w + dw
										to_check[nx .. "," .. ny .. "," .. nz .. "," .. nw] = { nx, ny, nz, nw }
									end
								end
							end
						end
					end
				end
			end
		end
		for _, pos in pairs(to_check) do
			local x, y, z, w = pos[1], pos[2], pos[3], pos[4]
			local count = 0
			for dx = -1, 1 do
				for dy = -1, 1 do
					for dz = -1, 1 do
						for dw = -1, 1 do
							if dx ~= 0 or dy ~= 0 or dz ~= 0 or dw ~= 0 then
								if
									active[x + dx]
									and active[x + dx][y + dy]
									and active[x + dx][y + dy][z + dz]
									and active[x + dx][y + dy][z + dz][w + dw]
								then
									count = count + 1
								end
							end
						end
					end
				end
			end
			local is_active = active[x] and active[x][y] and active[x][y][z] and active[x][y][z][w]
			if (is_active and (count == 2 or count == 3)) or (not is_active and count == 3) then
				new_active[x] = new_active[x] or {}
				new_active[x][y] = new_active[x][y] or {}
				new_active[x][y][z] = new_active[x][y][z] or {}
				new_active[x][y][z][w] = true
			end
		end
		active = new_active
	end
	local count = 0
	for _, yz in pairs(active) do
		for _, zt in pairs(yz) do
			for _, wt in pairs(zt) do
				for _ in pairs(wt) do
					count = count + 1
				end
			end
		end
	end
	return count
end

return M
