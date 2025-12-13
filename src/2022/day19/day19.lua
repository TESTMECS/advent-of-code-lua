--- @title: Day 19: Not Enough Minerals ---
local M = {}

local function parse_blueprints(input)
	local blueprints = {}
	for line in input:gmatch("[^\n]+") do
		local id, ore_ore, clay_ore, obs_ore, obs_clay, geo_ore, geo_obs = line:match(
			"Blueprint (%d+): Each ore robot costs (%d+) ore%. Each clay robot costs (%d+) ore%. Each obsidian robot costs (%d+) ore and (%d+) clay%. Each geode robot costs (%d+) ore and (%d+) obsidian%."
		)
		id = tonumber(id)
		blueprints[id] = {
			ore = { ore = tonumber(ore_ore) },
			clay = { ore = tonumber(clay_ore) },
			obs = { ore = tonumber(obs_ore), clay = tonumber(obs_clay) },
			geo = { ore = tonumber(geo_ore), obs = tonumber(geo_obs) },
		}
	end
	return blueprints
end

local function dfs(bp, time, ore, clay, obs, geo, ore_r, clay_r, obs_r, geo_r, memo)
	if time == 0 then
		return geo
	end

	local max_ore = math.max(bp.ore.ore, bp.clay.ore, bp.obs.ore, bp.geo.ore)
	local max_clay = bp.obs.clay
	local max_obs = bp.geo.obs

	ore = math.min(ore, max_ore * time)
	clay = math.min(clay, max_clay * time)
	obs = math.min(obs, max_obs * time)

	local key = string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d", time, ore, clay, obs, geo, ore_r, clay_r, obs_r, geo_r)
	if memo[key] then
		return memo[key]
	end

	local max_geo = geo

	local new_ore = ore + ore_r
	local new_clay = clay + clay_r
	local new_obs = obs + obs_r
	local new_geo = geo + geo_r

	-- try to build geode robot first
	if ore >= bp.geo.ore and obs >= bp.geo.obs then
		local n_ore = new_ore - bp.geo.ore
		local n_obs = new_obs - bp.geo.obs
		max_geo =
			math.max(max_geo, dfs(bp, time - 1, n_ore, new_clay, n_obs, new_geo, ore_r, clay_r, obs_r, geo_r + 1, memo))
	else
		-- other robots, only if we need more
		if ore_r < max_ore and ore >= bp.ore.ore then
			max_geo = math.max(
				max_geo,
				dfs(
					bp,
					time - 1,
					new_ore - bp.ore.ore,
					new_clay,
					new_obs,
					new_geo,
					ore_r + 1,
					clay_r,
					obs_r,
					geo_r,
					memo
				)
			)
		end
		if clay_r < max_clay and ore >= bp.clay.ore then
			max_geo = math.max(
				max_geo,
				dfs(
					bp,
					time - 1,
					new_ore - bp.clay.ore,
					new_clay,
					new_obs,
					new_geo,
					ore_r,
					clay_r + 1,
					obs_r,
					geo_r,
					memo
				)
			)
		end
		if obs_r < max_obs and ore >= bp.obs.ore and clay >= bp.obs.clay then
			max_geo = math.max(
				max_geo,
				dfs(
					bp,
					time - 1,
					new_ore - bp.obs.ore,
					new_clay - bp.obs.clay,
					new_obs,
					new_geo,
					ore_r,
					clay_r,
					obs_r + 1,
					geo_r,
					memo
				)
			)
		end
		-- wait/do nothing
		max_geo =
			math.max(max_geo, dfs(bp, time - 1, new_ore, new_clay, new_obs, new_geo, ore_r, clay_r, obs_r, geo_r, memo))
	end

	memo[key] = max_geo
	return max_geo
end

--- @description Sum quality levels for 24 minutes
--- @param input string the puzzle input
--- @return number the sum
function M.part1(input)
	local blueprints = parse_blueprints(input)
	local sum = 0
	for id, bp in pairs(blueprints) do
		local memo = {}
		local max_geo = dfs(bp, 24, 0, 0, 0, 0, 1, 0, 0, 0, memo)
		sum = sum + id * max_geo
	end
	return sum
end

--- @description Product of geodes for first 3 blueprints in 32 minutes
--- @param input string the puzzle input
--- @return number the product
function M.part2(input)
	local blueprints = parse_blueprints(input)
	local prod = 1
	for i = 1, 3 do
		local bp = blueprints[i]
		local memo = {}
		local max_geo = dfs(bp, 32, 0, 0, 0, 0, 1, 0, 0, 0, memo)
		prod = prod * max_geo
	end
	return prod
end

return M
