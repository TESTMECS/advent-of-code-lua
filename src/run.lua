--[[
Copyright(c) 2025 TESTMEE
Uses `argparse.lua` to parse input files and run part 1 and part 2 solution functions
--]]
local argp = require("argparse")
local parser = argp()
	:name("aoc")
	:description("Run Advent of Code tests")
	:epilog("See https://github.com/TESTMECS/advent-of-code-lua")
parser:argument("year", "Year to run")
parser:argument("day", "Day to run, matches with correct input file")
parser:argument("part", "Part to run"):args("?")
parser:argument("custom", "Custom input string"):args("?")

--- @class args
--- @field year string: "2015"
--- @field day string: 1,2, 13, 25
--- @field custom string: Custom input string
--- @field part string: 1 | 2
local args = parser:parse()
local day_str = string.format("%02d", tonumber(args.day))
local day_file = "src/" .. args.year .. "/day" .. day_str .. "/day" .. day_str .. ".lua"
local ok, solver = pcall(dofile, day_file)

if not ok then
	print("Could not load " .. day_file .. ": " .. tostring(solver))
	os.exit(1)
end

local input_file = "src/" .. args.year .. "/day" .. day_str .. "/input"
local f = io.open(input_file, "r")
if not f then
	os.exit(1)
end

local input = f:read("*a")
f:close()

if args.part == "1" then
	print(solver.part1(input))
	os.exit(0)
elseif args.part == "2" then
	print(solver.part2(input))
	os.exit(0)
end

print("Day " .. args.day .. ":")
print(" Answer for Part 1:")
print(solver.part1(input))
print(" Answer for Part 2:")
print(solver.part2(input))
