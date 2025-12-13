--- @title: Day 15: Science for Hungry People ---
local M = {}

--- @function: Parse the ingredients from the input
--- @param input string
--- @return table
local function parse_ingredients(input)
	local ingredients = {}
	for line in input:gmatch("[^\n]+") do
		local name, cap, dur, flav, tex, cal = line:match(
			"(%w+): capacity ([%-]?%d+), durability ([%-]?%d+), flavor ([%-]?%d+), texture ([%-]?%d+), calories ([%-]?%d+)"
		)
		if name then
			table.insert(ingredients, {
				cap = tonumber(cap),
				dur = tonumber(dur),
				flav = tonumber(flav),
				tex = tonumber(tex),
				cal = tonumber(cal),
			})
		end
	end
	return ingredients
end

--- @description: Total score of the highest-scoring cookie you can make
--- @param input string
--- @return integer
function M.part1(input)
	local ingredients = parse_ingredients(input)
	local max_score = 0
	for a = 0, 100 do
		for b = 0, 100 - a do
			for c = 0, 100 - a - b do
				local d = 100 - a - b - c
				local cap = math.max(
					0,
					ingredients[1].cap * a + ingredients[2].cap * b + ingredients[3].cap * c + ingredients[4].cap * d
				)
				local dur = math.max(
					0,
					ingredients[1].dur * a + ingredients[2].dur * b + ingredients[3].dur * c + ingredients[4].dur * d
				)
				local flav = math.max(
					0,
					ingredients[1].flav * a
						+ ingredients[2].flav * b
						+ ingredients[3].flav * c
						+ ingredients[4].flav * d
				)
				local tex = math.max(
					0,
					ingredients[1].tex * a + ingredients[2].tex * b + ingredients[3].tex * c + ingredients[4].tex * d
				)
				local score = cap * dur * flav * tex
				if score > max_score then
					max_score = score
				end
			end
		end
	end
	return max_score
end

--- @description: Total score of the highest-scoring cookie you can make with a calorie total of 500
--- @param input string
--- @return integer
function M.part2(input)
	local ingredients = parse_ingredients(input)
	local max_score = 0
	for a = 0, 100 do
		for b = 0, 100 - a do
			for c = 0, 100 - a - b do
				local d = 100 - a - b - c
				local cal = ingredients[1].cal * a
					+ ingredients[2].cal * b
					+ ingredients[3].cal * c
					+ ingredients[4].cal * d
				if cal == 500 then
					local cap = math.max(
						0,
						ingredients[1].cap * a
							+ ingredients[2].cap * b
							+ ingredients[3].cap * c
							+ ingredients[4].cap * d
					)
					local dur = math.max(
						0,
						ingredients[1].dur * a
							+ ingredients[2].dur * b
							+ ingredients[3].dur * c
							+ ingredients[4].dur * d
					)
					local flav = math.max(
						0,
						ingredients[1].flav * a
							+ ingredients[2].flav * b
							+ ingredients[3].flav * c
							+ ingredients[4].flav * d
					)
					local tex = math.max(
						0,
						ingredients[1].tex * a
							+ ingredients[2].tex * b
							+ ingredients[3].tex * c
							+ ingredients[4].tex * d
					)
					local score = cap * dur * flav * tex
					if score > max_score then
						max_score = score
					end
				end
			end
		end
	end
	return max_score
end

return M
