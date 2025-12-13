--- @title: Day 16: Permutation Promenade ---
local M = {}

--- @description: Apply a move to a program
--- @param prog string: the program
--- @param move string: the move
--- @return string|nil: the program
local function apply_move(prog, move)
	if move:sub(1, 1) == "s" then
		local x = tonumber(move:sub(2))
		return prog:sub(-x) .. prog:sub(1, -x - 1)
	elseif move:sub(1, 1) == "x" then
		local a, b = move:match("x(%d+)/(%d+)")
		a = tonumber(a) + 1
		b = tonumber(b) + 1
		local temp = prog:sub(a, a)
		prog = prog:sub(1, a - 1) .. prog:sub(b, b) .. prog:sub(a + 1)
		prog = prog:sub(1, b - 1) .. temp .. prog:sub(b + 1)
		return prog
	elseif move:sub(1, 1) == "p" then
		local a, b = move:match("p(%a)/(%a)")
		local pos_a = prog:find(a)
		local pos_b = prog:find(b)
		return apply_move(prog, "x" .. (pos_a - 1) .. "/" .. (pos_b - 1))
	end
end

--- @description: Apply the dance once
--- @param input string: the moves
--- @return string|nil: the order
function M.part1(input)
	local moves = {}
	for move in input:gmatch("[^,]+") do
		table.insert(moves, move)
	end
	local programs = "abcdefghijklmnop"
	for _, move in ipairs(moves) do
		programs = apply_move(programs, move)
	end
	return programs
end

--- @description: Apply the dance 1 billion times
--- @param input string: the moves
--- @return string|nil: the order
function M.part2(input)
	local moves = {}
	for move in input:gmatch("[^,]+") do
		table.insert(moves, move)
	end
	local programs = "abcdefghijklmnop"
	local seen = {}
	local count = 0
	local start = programs
	while not seen[programs] do
		seen[programs] = count
		for _, move in ipairs(moves) do
			programs = apply_move(programs, move)
		end
		count = count + 1
		if count > 1000000 then
			break
		end
	end
	local cycle = count - seen[programs]
	local offset = seen[start]
	local remaining = (1000000000 - offset) % cycle
	programs = start
	for _ = 1, offset + remaining do
		for _, move in ipairs(moves) do
			programs = apply_move(programs, move)
		end
	end
	return programs
end

return M
