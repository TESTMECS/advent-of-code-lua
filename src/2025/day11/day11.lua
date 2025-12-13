local utils = require("src.util")
local M = {}
---@diagnostic disable
local example_part1 = [[
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
]]
---@diagnostic disable
local example_part2 = [[
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
]]
---@description Parses the input file into graph table
---@param input string: The input string.
---@return table<string, string[]>: The graph table
local function parse(input)
	local g = {}
	local lines = utils.read_lines(input)
	for _, line in ipairs(lines) do
		local source, outputs_str = line:match("([^:]+):%s*(.*)")
		if source and outputs_str then
			source = source:match("^%s*(.-)%s*$")
			local outputs = {}
			for output in outputs_str:gmatch("%S+") do
				table.insert(outputs, output)
			end
			g[source] = outputs
		end
	end
	return g
end
---@description Find the number of paths from 'you' to 'out'
---@param input string: The input string.
---@return number: The number of paths
function M.part1(input)
	local memo = {} ---@type table<string, number>
	local graph = parse(input) ---@type table<string, string[]>
	---@description Counts the number of paths from 'device' to 'out'
	---@param device string: The device to start from
	---@return number
	local function count_paths_dfs(device)
		if memo[device] then
			return memo[device]
		end
		if device == "out" then
			memo[device] = 1
			return 1
		end
		local outputs = graph[device]
		if not outputs or #outputs == 0 then
			memo[device] = 0
			return 0
		end
		local total_paths = 0
		for _, next_device in ipairs(outputs) do
			total_paths = total_paths + count_paths_dfs(next_device)
		end
		memo[device] = total_paths
		return total_paths
	end
	local start_device = "you" ---@type string
	local result = count_paths_dfs(start_device) ---@type number
	print("------")
	return result
end
---@description Find the number of paths from 'svr' to 'out'
---@param input string: The input string.
---@return number: The number of paths
function M.part2(input)
	local graph = parse(input) ---@type table<string, string[]>
	---@description Counts the number of paths from 'start_node' to 'target_node'
	---@param start_node string: The start node
	---@param target_node string: The target node
	---@return number
	local function count_segment(start_node, target_node)
		local memo = {}
		local function dfs(current)
			if current == target_node then
				return 1
			end
			if memo[current] then
				return memo[current]
			end
			local outputs = graph[current]
			if not outputs then
				return 0
			end
			local total = 0
			for _, next_node in ipairs(outputs) do
				total = total + dfs(next_node)
			end
			memo[current] = total
			return total
		end
		return dfs(start_node)
	end
	local s1_a = count_segment("svr", "dac")
	local s1_b = count_segment("dac", "fft")
	local s1_c = count_segment("fft", "out")
	local total_scene1 = s1_a * s1_b * s1_c
	local s2_a = count_segment("svr", "fft")
	local s2_b = count_segment("fft", "dac")
	local s2_c = count_segment("dac", "out")
	local total_scene2 = s2_a * s2_b * s2_c
	local total = total_scene1 + total_scene2
	print("------")
	return total
end
return M
