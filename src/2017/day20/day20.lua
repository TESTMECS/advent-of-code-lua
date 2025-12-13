--- @title: Day 20: Particle Swarm ---
local M = {}
local util = require("util")

--- @function: parse a line into a particle
--- @param line string: the line
--- @return table: the particle
local function parse(line)
	local px, py, pz = line:match("p=<([^,]+),([^,]+),([^>]+)>")
	local vx, vy, vz = line:match("v=<([^,]+),([^,]+),([^>]+)>")
	local ax, ay, az = line:match("a=<([^,]+),([^,]+),([^>]+)>")
	return {
		p = { tonumber(px), tonumber(py), tonumber(pz) },
		v = { tonumber(vx), tonumber(vy), tonumber(vz) },
		a = { tonumber(ax), tonumber(ay), tonumber(az) },
	}
end
--- @description: Find the particle that stays closest to <0,0,0> in the long term
--- @param input string: of strings, each particle's p,v,a
--- @return number: the particle id (0-based)
function M.part1(input)
	local lines = {}
	for _, line in ipairs(util.read_lines(input)) do
		if line ~= "" then
			table.insert(lines, line)
		end
	end

	local particles = {}
	for i, line in ipairs(lines) do
		particles[i] = parse(line)
	end

	local min_dist = math.huge
	local min_id = -1
	for i, p in ipairs(particles) do
		local dist = math.abs(p.a[1]) + math.abs(p.a[2]) + math.abs(p.a[3])
		if dist < min_dist or (dist == min_dist and i < min_id) then
			min_dist = dist
			min_id = i - 1
		end
	end

	return min_id
end

--- @description: Simulate particles and count remaining after collisions
--- @param input string: of strings, each particle's p,v,a
--- @return number
function M.part2(input)
	local lines = {}
	for _, line in ipairs(util.read_lines(input)) do
		if line ~= "" then
			table.insert(lines, line)
		end
	end

	local particles = {}
	for i, line in ipairs(lines) do
		particles[i] = parse(line)
	end

	local active = {}
	for i = 1, #particles do
		active[i] = true
	end

	-- Run for enough steps that collisions are guaranteed to be resolved
	local max_steps = 10000
	for step = 1, max_steps do
		-- update
		for i, p in ipairs(particles) do
			if active[i] then
				p.v[1] = p.v[1] + p.a[1]
				p.v[2] = p.v[2] + p.a[2]
				p.v[3] = p.v[3] + p.a[3]
				p.p[1] = p.p[1] + p.v[1]
				p.p[2] = p.p[2] + p.v[2]
				p.p[3] = p.p[3] + p.v[3]
			end
		end

		-- check collisions
		local pos_map = {}
		for i, p in ipairs(particles) do
			if active[i] then
				local key = string.format("%d,%d,%d", p.p[1], p.p[2], p.p[3])
				if not pos_map[key] then
					pos_map[key] = {}
				end
				table.insert(pos_map[key], i)
			end
		end
		for _, ids in pairs(pos_map) do
			if #ids > 1 then
				for _, id in ipairs(ids) do
					active[id] = false
				end
			end
		end
	end

	-- count survivors
	local count = 0
	for _, a in pairs(active) do
		if a then
			count = count + 1
		end
	end
	return count
end

return M
