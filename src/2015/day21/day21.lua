--- @title: Day 21: RPG Simulator 20XX ---
local M = {}
local util = require("util")

local weapons = {
	{ cost = 8, dmg = 4, arm = 0 },
	{ cost = 10, dmg = 5, arm = 0 },
	{ cost = 25, dmg = 6, arm = 0 },
	{ cost = 40, dmg = 7, arm = 0 },
	{ cost = 74, dmg = 8, arm = 0 },
}

local armor = {
	{ cost = 0, dmg = 0, arm = 0 },
	{ cost = 13, dmg = 0, arm = 1 },
	{ cost = 31, dmg = 0, arm = 2 },
	{ cost = 53, dmg = 0, arm = 3 },
	{ cost = 75, dmg = 0, arm = 4 },
	{ cost = 102, dmg = 0, arm = 5 },
}

local rings = {
	{ cost = 25, dmg = 1, arm = 0 },
	{ cost = 50, dmg = 2, arm = 0 },
	{ cost = 100, dmg = 3, arm = 0 },
	{ cost = 20, dmg = 0, arm = 1 },
	{ cost = 40, dmg = 0, arm = 2 },
	{ cost = 80, dmg = 0, arm = 3 },
}

--- @function: siumulate the game
--- @param player_hp number|nil
--- @param player_dmg number|nil
--- @param player_arm number|nil
--- @param boss_hp number|nil
--- @param boss_dmg number|nil
--- @param boss_arm number|nil
--- @return boolean
local function simulate(player_hp, player_dmg, player_arm, boss_hp, boss_dmg, boss_arm)
	local p_hp = player_hp
	local b_hp = boss_hp
	local turn = true -- player first
	while p_hp > 0 and b_hp > 0 do
		if turn then
			b_hp = b_hp - math.max(1, player_dmg - boss_arm)
		else
			p_hp = p_hp - math.max(1, boss_dmg - player_arm)
		end
		turn = not turn
	end
	return b_hp <= 0
end

--- @description initialize the game and then return the minimum cost
--- @param input string
--- @return number
function M.part1(input)
	local lines = util.read_lines(input)
	local boss_hp = tonumber(lines[1]:match("Hit Points: (%d+)"))
	local boss_dmg = tonumber(lines[2]:match("Damage: (%d+)"))
	local boss_arm = tonumber(lines[3]:match("Armor: (%d+)"))

	local ring_combs = {}
	table.insert(ring_combs, {})
	for i = 1, #rings do
		table.insert(ring_combs, { rings[i] })
	end
	for i = 1, #rings do
		for j = i + 1, #rings do
			table.insert(ring_combs, { rings[i], rings[j] })
		end
	end

	local min_cost = math.huge
	for _, w in ipairs(weapons) do
		for _, a in ipairs(armor) do
			for _, rcomb in ipairs(ring_combs) do
				local cost = w.cost + a.cost
				local dmg = w.dmg + a.dmg
				local arm = w.arm + a.arm
				for _, r in ipairs(rcomb) do
					cost = cost + r.cost
					dmg = dmg + r.dmg
					arm = arm + r.arm
				end
				if simulate(100, dmg, arm, boss_hp, boss_dmg, boss_arm) then
					min_cost = math.min(min_cost, cost)
				end
			end
		end
	end
	return min_cost
end

--- @description initialize the game and then return the maximum cost
--- @param input string
--- @return number
function M.part2(input)
	local lines = util.read_lines(input)
	local boss_hp = tonumber(lines[1]:match("Hit Points: (%d+)"))
	local boss_dmg = tonumber(lines[2]:match("Damage: (%d+)"))
	local boss_arm = tonumber(lines[3]:match("Armor: (%d+)"))

	local ring_combs = {}
	table.insert(ring_combs, {})
	for i = 1, #rings do
		table.insert(ring_combs, { rings[i] })
	end
	for i = 1, #rings do
		for j = i + 1, #rings do
			table.insert(ring_combs, { rings[i], rings[j] })
		end
	end

	local max_cost = 0
	for _, w in ipairs(weapons) do
		for _, a in ipairs(armor) do
			for _, rcomb in ipairs(ring_combs) do
				local cost = w.cost + a.cost
				local dmg = w.dmg + a.dmg
				local arm = w.arm + a.arm
				for _, r in ipairs(rcomb) do
					cost = cost + r.cost
					dmg = dmg + r.dmg
					arm = arm + r.arm
				end
				if not simulate(100, dmg, arm, boss_hp, boss_dmg, boss_arm) then
					max_cost = math.max(max_cost, cost)
				end
			end
		end
	end
	return max_cost
end

return M
