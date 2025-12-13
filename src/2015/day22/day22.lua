--- @title: Day 22: Wizard Simulator 20XX ---
local M = {}
local util = require("util")

--- @function: simple depth-first search with memoization
--- @param state_str string
--- @param boss_dmg number|nil
--- @param hard_mode boolean
--- @param memo table
--- @return number
local function dfs(state_str, boss_dmg, hard_mode, memo)
	if memo[state_str] then
		return memo[state_str]
	end
	memo[state_str] = math.huge

	local parts = util.split(state_str, ",")
	local hp = tonumber(parts[1])
	local mana = tonumber(parts[2])
	local bhp = tonumber(parts[3])
	local sh = tonumber(parts[4])
	local po = tonumber(parts[5])
	local re = tonumber(parts[6])
	local turn = parts[7] == "1"

	local min_cost = math.huge

	local spells = {
		{
			name = "missile",
			cost = 53,
			instant = true,
			action = function(hp, mana, bhp, sh, po, re)
				return hp, mana, bhp - 4, sh, po, re
			end,
		},
		{
			name = "drain",
			cost = 73,
			instant = true,
			action = function(hp, mana, bhp, sh, po, re)
				return hp + 2, mana, bhp - 2, sh, po, re
			end,
		},
		{
			name = "shield",
			cost = 113,
			instant = false,
			action = function(hp, mana, bhp, sh, po, re)
				if sh == 0 then
					return hp, mana, bhp, 6, po, re
				else
					return nil
				end
			end,
		},
		{
			name = "poison",
			cost = 173,
			instant = false,
			action = function(hp, mana, bhp, sh, po, re)
				if po == 0 then
					return hp, mana, bhp, sh, 6, re
				else
					return nil
				end
			end,
		},
		{
			name = "recharge",
			cost = 229,
			instant = false,
			action = function(hp, mana, bhp, sh, po, re)
				if re == 0 then
					return hp, mana, bhp, sh, po, 5
				else
					return nil
				end
			end,
		},
	}

	if turn then -- player turn
		if hard_mode then
			hp = hp - 1
			if hp <= 0 then
				memo[state_str] = math.huge
				return math.huge
			end
		end
		-- apply effects
		local armor = 0
		if sh > 0 then
			armor = 7
		end
		if po > 0 then
			bhp = bhp - 3
		end
		if re > 0 then
			mana = mana + 101
		end
		sh = math.max(0, sh - 1)
		po = math.max(0, po - 1)
		re = math.max(0, re - 1)
		if bhp <= 0 then
			memo[state_str] = 0
			return 0
		end
		-- cast spell
		for _, spell in ipairs(spells) do
			if mana >= spell.cost then
				local new_hp, new_mana, new_bhp, new_sh, new_po, new_re =
					spell.action(hp, mana - spell.cost, bhp, sh, po, re)
				if new_hp then
					if new_bhp <= 0 then
						min_cost = math.min(min_cost, spell.cost)
					else
						local new_state = new_hp
							.. ","
							.. new_mana
							.. ","
							.. new_bhp
							.. ","
							.. new_sh
							.. ","
							.. new_po
							.. ","
							.. new_re
							.. ",0"
						local sub = dfs(new_state, boss_dmg, hard_mode, memo)
						if sub < math.huge then
							min_cost = math.min(min_cost, spell.cost + sub)
						end
					end
				end
			end
		end
	else -- boss turn
		-- apply effects
		local armor = 0
		if sh > 0 then
			armor = 7
		end
		if po > 0 then
			bhp = bhp - 3
		end
		if re > 0 then
			mana = mana + 101
		end
		sh = math.max(0, sh - 1)
		po = math.max(0, po - 1)
		re = math.max(0, re - 1)
		if bhp <= 0 then
			memo[state_str] = 0
			return 0
		end
		-- boss attack
		local damage = math.max(1, boss_dmg - armor)
		hp = hp - damage
		if hp > 0 then
			local new_state = hp .. "," .. mana .. "," .. bhp .. "," .. sh .. "," .. po .. "," .. re .. ",1"
			local sub = dfs(new_state, boss_dmg, hard_mode, memo)
			min_cost = math.min(min_cost, sub)
		end
	end

	memo[state_str] = min_cost
	return min_cost
end

--- @description part 1 of the problem, find the minimum cost to kill the boss
--- @param input string
--- @return number
function M.part1(input)
	local lines = util.read_lines(input)
	local boss_hp = tonumber(lines[1]:match("Hit Points: (%d+)"))
	local boss_dmg = tonumber(lines[2]:match("Damage: (%d+)"))
	local memo = {}
	local start_state = "50,500," .. boss_hp .. ",0,0,0,1"
	local result = dfs(start_state, boss_dmg, false, memo)
	return result < math.huge and result or -1
end

--- @description part 2 of the problem, find the minimum cost to kill the boss
--- @param input string
--- @return number
function M.part2(input)
	local lines = util.read_lines(input)
	local boss_hp = tonumber(lines[1]:match("Hit Points: (%d+)"))
	local boss_dmg = tonumber(lines[2]:match("Damage: (%d+)"))
	local memo = {}
	local start_state = "50,500," .. boss_hp .. ",0,0,0,1"
	local result = dfs(start_state, boss_dmg, true, memo)
	return result < math.huge and result or -1
end

return M
