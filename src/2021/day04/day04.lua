---@title: --- Day 4: Giant Squid ---
local M = {}

local function trim(s)
	if not s then
		return s
	end
	return s:match("^%s*(.-)%s*$")
end

--- @function: parse_input
--- @param input string: the puzzle input
--- @return table: the parsed draws
--- @return table: the boards
local function parse_input(input)
	-- normalize CRLF and ensure trailing newline to capture final blank lines
	local processed = input:gsub("\r", "") .. "\n"
	local lines = {}
	for line in processed:gmatch("(.-)\n") do
		table.insert(lines, line) -- includes empty "" for blank lines
	end

	-- first non-empty line should be draws (but many inputs have draws at lines[1])
	local draws_line_index = 1
	-- skip initial blank lines just in case
	while draws_line_index <= #lines and trim(lines[draws_line_index]) == "" do
		draws_line_index = draws_line_index + 1
	end
	if draws_line_index > #lines then
		error("No draws line found in input")
	end

	local draws = {}
	for num in lines[draws_line_index]:gmatch("%d+") do
		table.insert(draws, tonumber(num))
	end

	-- Now parse boards: start after draws_line_index
	local boards = {}
	local i = draws_line_index + 1
	while i <= #lines do
		-- skip blank lines until a board row is found
		while i <= #lines and trim(lines[i]) == "" do
			i = i + 1
		end
		if i > #lines then
			break
		end

		-- attempt to read 5 consecutive non-empty lines as a board
		local board = {}
		local ok = true
		for row = 0, 4 do
			local idx = i + row
			if not lines[idx] or trim(lines[idx]) == "" then
				ok = false
				break
			end
			local row_t = {}
			for num in lines[idx]:gmatch("%d+") do
				table.insert(row_t, { num = tonumber(num), marked = false })
			end
			table.insert(board, row_t)
		end

		if ok and #board == 5 then
			table.insert(boards, board)
			i = i + 5 -- advance past the 5 board rows
		else
			-- if we couldn't read a full board, bail out of the loop to avoid infinite loop
			break
		end
	end

	return draws, boards
end

--- @function: mark_board
--- @param board table: the board to mark
--- @param drawn_num number: the number to draw
local function mark_board(board, drawn_num)
	for _, row in ipairs(board) do
		for _, cell in ipairs(row) do
			if cell.num == drawn_num then
				cell.marked = true
			end
		end
	end
end

--- @function: check_win
--- @param board table: the board to check
--- @return boolean
local function check_win(board)
	-- Check rows
	for r = 1, 5 do
		local row_win = true
		for c = 1, 5 do
			if not board[r][c].marked then
				row_win = false
				break
			end
		end
		if row_win then
			return true
		end
	end
	-- Check columns
	for c = 1, 5 do
		local col_win = true
		for r = 1, 5 do
			if not board[r][c].marked then
				col_win = false
				break
			end
		end
		if col_win then
			return true
		end
	end
	return false
end

--- @function: calculate_score
--- @param board table: the board to calculate the score for
--- @param winning_num number: the winning number
local function calculate_score(board, winning_num)
	local sum_unmarked = 0
	for _, row in ipairs(board) do
		for _, cell in ipairs(row) do
			if not cell.marked then
				sum_unmarked = sum_unmarked + cell.num
			end
		end
	end
	return sum_unmarked * winning_num
end

--- @description: Find the first winning bingo board and calculate its score.
--- @param input string: the puzzle input
--- @return number: the score of the first winning board
function M.part1(input)
	local draws, boards = parse_input(input)

	for _, draw in ipairs(draws) do
		for _, board in ipairs(boards) do
			mark_board(board, draw)
			if check_win(board) then
				return calculate_score(board, draw)
			end
		end
	end
	return 0
end

--- @description Find the last winning bingo board and calculate its score.
--- @param input string: the puzzle input
--- @return number: the score of the last winning board
function M.part2(input)
	local draws, boards = parse_input(input)
	local won_boards = {} -- track indices of boards that have won
	local last_winning_score = 0

	for _, draw in ipairs(draws) do
		for i, board in ipairs(boards) do
			if not won_boards[i] then
				mark_board(board, draw)
				if check_win(board) then
					won_boards[i] = true
					last_winning_score = calculate_score(board, draw)
				end
			end
		end
	end

	return last_winning_score
end

return M
