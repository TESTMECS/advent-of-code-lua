--- @title: Day 21: Dirac Dice ---
local M = {}

--- @description Simulate the game with deterministic die
--- @param input string the puzzle input
--- @return number the product of losing score and die rolls
function M.part1(input)
	local p1 = input:match("Player 1 starting position: (%d+)")
	local p2 = input:match("Player 2 starting position: (%d+)")
	p1 = tonumber(p1)
	p2 = tonumber(p2)
	local score1 = 0
	local score2 = 0
	local die = 1
	local rolls = 0
	local function roll()
		local r = die
		die = die + 1
		if die > 100 then
			die = 1
		end
		rolls = rolls + 1
		return r
	end
	while true do
		local move1 = roll() + roll() + roll()
		p1 = ((p1 - 1 + move1) % 10) + 1
		score1 = score1 + p1
		if score1 >= 1000 then
			break
		end
		local move2 = roll() + roll() + roll()
		p2 = ((p2 - 1 + move2) % 10) + 1
		score2 = score2 + p2
		if score2 >= 1000 then
			break
		end
	end
	local loser = score1 >= 1000 and score2 or score1
	return loser * rolls
end

--- @description Simulate the game with quantum die
--- @param input string the puzzle input
--- @return number the number of universes the winner wins in
function M.part2(input)
	local p1 = input:match("Player 1 starting position: (%d+)")
	local p2 = input:match("Player 2 starting position: (%d+)")
	p1 = tonumber(p1)
	p2 = tonumber(p2)
	local memo = {}
	local function play(pos1, pos2, score1, score2, turn)
		local key = pos1 .. "," .. pos2 .. "," .. score1 .. "," .. score2 .. "," .. turn
		if memo[key] then
			return memo[key][1], memo[key][2]
		end
		if score1 >= 21 then
			return 1, 0
		end
		if score2 >= 21 then
			return 0, 1
		end
		local w1, w2 = 0, 0
		for d1 = 1, 3 do
			for d2 = 1, 3 do
				for d3 = 1, 3 do
					local move = d1 + d2 + d3
					if turn == 1 then
						local new_pos = ((pos1 - 1 + move) % 10) + 1
						local new_score = score1 + new_pos
						local ww1, ww2 = play(new_pos, pos2, new_score, score2, 2)
						w1 = w1 + ww1
						w2 = w2 + ww2
					else
						local new_pos = ((pos2 - 1 + move) % 10) + 1
						local new_score = score2 + new_pos
						local ww1, ww2 = play(pos1, new_pos, score1, new_score, 1)
						w1 = w1 + ww1
						w2 = w2 + ww2
					end
				end
			end
		end
		memo[key] = { w1, w2 }
		return w1, w2
	end
	local w1, w2 = play(p1, p2, 0, 0, 1)
	return math.max(w1, w2)
end

return M
