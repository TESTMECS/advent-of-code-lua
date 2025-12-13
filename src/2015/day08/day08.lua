--- @title: --- Day 8: Matchsticks ---
local M = {}

--- @param input string: ex: "\xa8br\x8bjr\""
--- @return integer
function M.part1(input)
	local total_code = 0
	local total_memory = 0
	for line in input:gmatch("[^\n]+") do
		total_code = total_code + #line
		local s = line:sub(2, -2)
		s = s:gsub("\\\\", "\\")
		s = s:gsub('\\"', '"')
		s = s:gsub("\\x(%x%x)", function(h)
			return string.char(tonumber(h, 16))
		end)
		total_memory = total_memory + #s
	end
	return total_code - total_memory
end

--- @param input string: ex: "\xa8br\x8bjr\""
--- @return integer
function M.part2(input)
	local total_diff = 0
	for line in input:gmatch("[^\n]+") do
		local original_code = #line
		local encoded = '"' .. line:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
		local encoded_code = #encoded
		total_diff = total_diff + (encoded_code - original_code)
	end
	return total_diff
end

return M
