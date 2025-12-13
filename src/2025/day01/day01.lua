local M = {}
local ex = [[
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
]]
--- @description: How many times the dial points to 0 after each instruction.
--- @param input string: instructions
--- @return number: number of times the dial points to 0
function M.part1(input)
	local dialPos, passCount = 50, 0
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("%s+", "")
		local distance = tonumber(line:gmatch("%d+")())
		if distance == nil then
			break
		end
		if line:sub(1, 1) == "L" then
			-- math.floor is for LSP "expected number, got integer"
			dialPos = math.floor((dialPos - distance) % 100 + 100) % 100
		else
			dialPos = math.floor((dialPos + distance) % 100)
		end
		if dialPos == 0 then
			passCount = passCount + 1
		end
	end
	return passCount
end

--- @description: Enhance the image 50 times and count lit pixels.
--- @param input string: The puzzle input.
--- @return number: The number of lit pixels.
function M.part2(input)
	local dialPos, passCount = 50, 0
	for line in input:gmatch("[^\n]+") do
		line = line:gsub("%s+", "")
		local distance = tonumber(line:gmatch("%d+")())
		if distance == nil then
			break
		end
		if line:sub(1, 1) == "L" then
			for _ = 1, distance do
				dialPos = dialPos - 1
				if dialPos < 0 then
					dialPos = 99
				end
				if dialPos == 0 then
					passCount = passCount + 1
				end
			end
		else
			for _ = 1, distance do
				dialPos = dialPos + 1
				if dialPos > 99 then
					dialPos = 0
				end
				if dialPos == 0 then
					passCount = passCount + 1
				end
			end
		end
	end
	return passCount
end

return M
