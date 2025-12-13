--- @title: Day 22: Slam Shuffle ---
local M = {}
local util = require("util")

--- @description Find the final position of card 2019 after one shuffle.
function M.part1(input)
	local deck_size = 10007
	local deck = {}
	for i = 0, deck_size - 1 do
		deck[i + 1] = i
	end

	for line in input:gmatch("[^\r\n]+") do
		if line == "deal into new stack" then
			local new_deck = {}
			for i = deck_size, 1, -1 do
				table.insert(new_deck, deck[i])
			end
			deck = new_deck
		elseif line:match("cut") then
			local n = tonumber(line:match("-?%d+"))
			local new_deck = {}
			if n > 0 then
				for i = n + 1, deck_size do
					table.insert(new_deck, deck[i])
				end
				for i = 1, n do
					table.insert(new_deck, deck[i])
				end
			else
				n = -n
				for i = deck_size - n + 1, deck_size do
					table.insert(new_deck, deck[i])
				end
				for i = 1, deck_size - n do
					table.insert(new_deck, deck[i])
				end
			end
			deck = new_deck
		elseif line:match("deal with increment") then
			local n = tonumber(line:match("%d+"))
			local new_deck = {}
			for i = 1, deck_size do
				local old_pos_0based = i - 1
				local new_pos_0based = (old_pos_0based * n) % deck_size
				new_deck[new_pos_0based + 1] = deck[i]
			end
			deck = new_deck
		end
	end

	for i = 1, deck_size do
		if deck[i] == 2019 then
			return i - 1
		end
	end
	return -1
end

-- @description Find which card lands at position 2020 after many shuffles.
function M.part2(input)
	local L = 119315717514047 -- deck size (prime)
	local reps = 101741582076661 -- repetitions
	local final_pos = 2020

	-- safe modular multiplication (avoids overflow): (a * b) % mod
	local function mul_mod(a, b, mod)
		a = a % mod
		b = b % mod
		local res = 0
		while b > 0 do
			if (b % 2) == 1 then
				res = (res + a) % mod
			end
			a = (a + a) % mod
			b = math.floor(b / 2)
		end
		return res
	end

	-- modular exponentiation using safe multiplication
	local function pow_mod(base, exp, mod)
		local result = 1
		base = base % mod
		while exp > 0 do
			if (exp % 2) == 1 then
				result = mul_mod(result, base, mod)
			end
			base = mul_mod(base, base, mod)
			exp = math.floor(exp / 2)
		end
		return result
	end

	-- modular inverse via Fermat (mod is prime)
	local function inv_mod(x, mod)
		-- assume x and mod are coprime and mod is prime
		return pow_mod(x, mod - 2, mod)
	end

	-- Build forward transform f(x) = a*x + b  (x = initial pos -> new pos)
	local a, b = 1, 0
	for line in input:gmatch("[^\r\n]+") do
		line = line:match("^%s*(.-)%s*$") -- trim whitespace
		if line == "deal into new stack" then
			-- new = -old - 1
			a = -a % L
			b = (-b - 1) % L
		elseif line:match("^cut") then
			local n = tonumber(line:match("(-?%d+)"))
			-- new = old - n
			b = (b - n) % L
		elseif line:match("deal with increment") then
			local n = tonumber(line:match("(%d+)"))
			-- new = old * n
			a = mul_mod(a, n, L)
			b = mul_mod(b, n, L)
		end
	end

	-- Compute f^reps(x) = A*x + B
	local A = pow_mod(a, reps, L)

	local B
	if (a % L) == 1 then
		-- geometric series degenerates: B = b * reps (mod L)
		B = mul_mod(b, reps % L, L)
	else
		local numer = (A - 1) % L
		local denom_inv = inv_mod((a - 1) % L, L)
		B = mul_mod(mul_mod(b, numer, L), denom_inv, L)
	end

	-- We want the card that ends at final_pos.
	-- Solve A * x + B ≡ final_pos  (mod L)  => x ≡ inv(A) * (final_pos - B)
	local invA = inv_mod(A, L)
	local initial_pos = mul_mod((final_pos - B) % L, invA, L)
	return initial_pos
end

return M
