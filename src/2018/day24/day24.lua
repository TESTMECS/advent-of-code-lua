--- @title: Day 24: Immune System Simulator 20XX ---
local M = {}

--- @function: A helper to parse the "weak to ..., immune to ..." part of a line, Returns two tables acting as sets for O(1) lookups.
--- @param s string: the specials string
--- @return table, table: the weaknesses and immunities tables
local function parse_specials(s)
	local weaknesses, immunities = {}, {}
	if not s then
		return weaknesses, immunities
	end

	for part in s:gmatch("%S[^;]+") do -- Splits by semicolon
		local list_str
		local type
		if part:match("weak to") then
			list_str = part:match("weak to (.*)")
			type = weaknesses
		elseif part:match("immune to") then
			list_str = part:match("immune to (.*)")
			type = immunities
		end

		if list_str and type then
			for word in list_str:gmatch("%w+") do
				type[word] = true
			end
		end
	end
	return weaknesses, immunities
end

--- @function: Parses the entire input into two lists of group templates. More robust than a single regex.
--- @param input string: the puzzle input
--- @return table, table: the immune and infection group templates
local function parse_input(input)
	local immune, infection = {}, {}
	local current_army = nil

	for line in input:gmatch("[^\n]+") do
		if line:find("Immune System:") then
			current_army = immune
		elseif line:find("Infection:") then
			current_army = infection
		elseif line:match("^%d+") then
			local units, hp = line:match("(%d+) units each with (%d+) hit points")
			local attack, attack_type, init = line:match("that does (%d+) (%w+) damage at initiative (%d+)")
			local specials_str = line:match("%((.*)%)")

			local weaknesses, immunities = parse_specials(specials_str)

			table.insert(current_army, {
				units = tonumber(units),
				hp = tonumber(hp),
				attack = tonumber(attack),
				attack_type = attack_type,
				initiative = tonumber(init),
				weaknesses = weaknesses,
				immunities = immunities,
			})
		end
	end
	return immune, infection
end

--- @function: The main simulation function. Takes templates and creates a fresh state to run.
--- @param immune_templates table: the immune group templates
--- @param infection_templates table: the infection group templates
--- @param boost number: the boost amount
--- @return string, number: the winner and the remaining units
local function simulate(immune_templates, infection_templates, boost)
	-- Create a fresh set of groups for this simulation run
	local groups = {}
	local next_id = 1
	for _, g in ipairs(immune_templates) do
		local new_group = { side = "immune", id = next_id }
		for k, v in pairs(g) do
			new_group[k] = v
		end
		new_group.attack = new_group.attack + boost
		table.insert(groups, new_group)
		next_id = next_id + 1
	end
	for _, g in ipairs(infection_templates) do
		local new_group = { side = "infection", id = next_id }
		for k, v in pairs(g) do
			new_group[k] = v
		end
		table.insert(groups, new_group)
		next_id = next_id + 1
	end

	-- Helper to get a group by its ID
	local function get_group_by_id(id)
		for _, g in ipairs(groups) do
			if g.id == id then
				return g
			end
		end
		return nil
	end

	while true do
		-- Check for win/loss conditions
		local immune_count, infection_count = 0, 0
		for _, g in ipairs(groups) do
			if g.side == "immune" then
				immune_count = immune_count + 1
			else
				infection_count = infection_count + 1
			end
		end
		if immune_count == 0 or infection_count == 0 then
			break
		end

		-- 1. Target Selection Phase
		table.sort(groups, function(a, b)
			local ep_a = a.units * a.attack
			local ep_b = b.units * b.attack
			if ep_a == ep_b then
				return a.initiative > b.initiative
			end
			return ep_a > ep_b
		end)

		local targets = {} -- { attacker_id = target_id }
		local is_targeted = {} -- { target_id = true }

		for _, attacker in ipairs(groups) do
			local best_target = nil
			local max_damage = -1

			for _, potential_target in ipairs(groups) do
				if attacker.side ~= potential_target.side and not is_targeted[potential_target.id] then
					local damage = attacker.units * attacker.attack
					if potential_target.immunities[attacker.attack_type] then
						damage = 0
					elseif potential_target.weaknesses[attacker.attack_type] then
						damage = damage * 2
					end

					if damage > 0 then
						if damage > max_damage then
							max_damage = damage
							best_target = potential_target
						elseif damage == max_damage then
							local best_ep = best_target.units * best_target.attack
							local pot_ep = potential_target.units * potential_target.attack
							if pot_ep > best_ep then
								best_target = potential_target
							elseif pot_ep == best_ep and potential_target.initiative > best_target.initiative then
								best_target = potential_target
							end
						end
					end
				end
			end

			if best_target then
				targets[attacker.id] = best_target.id
				is_targeted[best_target.id] = true
			end
		end

		-- 2. Attacking Phase
		table.sort(groups, function(a, b)
			return a.initiative > b.initiative
		end)

		local total_units_killed = 0
		for _, attacker in ipairs(groups) do
			if attacker.units > 0 and targets[attacker.id] then
				local target = get_group_by_id(targets[attacker.id])
				if target then
					local damage = attacker.units * attacker.attack
					if target.immunities[attacker.attack_type] then
						damage = 0
					elseif target.weaknesses[attacker.attack_type] then
						damage = damage * 2
					end

					local units_killed = math.min(target.units, math.floor(damage / target.hp))
					target.units = target.units - units_killed
					total_units_killed = total_units_killed + units_killed
				end
			end
		end

		-- Stalemate condition
		if total_units_killed == 0 then
			return "tie", 0
		end

		-- Remove dead groups
		local living_groups = {}
		for _, g in ipairs(groups) do
			if g.units > 0 then
				table.insert(living_groups, g)
			end
		end
		groups = living_groups
	end

	-- Determine winner and total remaining units
	local remaining_units = 0
	local winner = ""
	for _, g in ipairs(groups) do
		remaining_units = remaining_units + g.units
		winner = g.side -- The last side with units is the winner
	end

	return winner, remaining_units
end

--- @description: Find the number of units remaining after the first boost.
--- @param input string: the puzzle input
--- @return number: the number of units remaining
function M.part1(input)
	local immune_templates, infection_templates = parse_input(input)
	local _, units = simulate(immune_templates, infection_templates, 0)
	return units
end

--- @description: Find the number of units remaining after the second boost.
--- @param input string: the puzzle input
--- @return number: the number of units remaining
function M.part2(input)
	local immune_templates, infection_templates = parse_input(input)
	local boost = 0
	while true do
		local winner, units = simulate(immune_templates, infection_templates, boost)
		if winner == "immune" then
			return units
		end
		boost = boost + 1
	end
end

return M
