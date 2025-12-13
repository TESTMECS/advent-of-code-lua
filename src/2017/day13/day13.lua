---@title: Day 13: Packet Scanners ---
local M = {}
local util = require("util")

--- @description: Calculate the severity of the trip through the firewall
--- @param input string: the input file content
--- @return number: the total severity
function M.part1(input)
	local lines = {}
	for _, line in ipairs(util.read_lines(input)) do
		table.insert(lines, line)
	end
	local layers = {}
	for _, line in ipairs(lines) do
		local d, r = line:match("(%d+): (%d+)")
		if d and r then
			layers[tonumber(d)] = tonumber(r)
		end
	end
	local severity = 0
	for d, r in pairs(layers) do
		local period = 2 * (r - 1)
		local pos = d % period
		if pos >= r then
			pos = period - pos
		end
		if pos == 0 then
			severity = severity + d * r
		end
	end
	return severity
end

--- @description: Find the minimum delay to pass without being caught
--- @param input string: the input file content
--- @return number: the minimum delay
function M.part2(input)
	local lines = {}
	for _, line in ipairs(util.read_lines(input)) do
		table.insert(lines, line)
	end
	local layers = {}
	for _, line in ipairs(lines) do
		local d, r = line:match("(%d+): (%d+)")
		if d and r then
			layers[tonumber(d)] = tonumber(r)
		end
	end
	local delay = 0
	while true do
		local caught = false
		for d, r in pairs(layers) do
			local t = delay + d
			local period = 2 * (r - 1)
			local pos = t % period
			if pos >= r then
				pos = period - pos
			end
			if pos == 0 then
				caught = true
				break
			end
		end
		if not caught then
			return delay
		end
		delay = delay + 1
	end
end

return M
