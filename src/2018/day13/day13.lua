--- @title: Day 13: Mine Cart Madness ---
local M = {}
local util = require("util")

local U = "U"
local R = "R"
local D = "D"
local L = "L"
local SY = { U = { U }, D = { D } } -- straight y
local SX = { L = { L }, R = { R } }
-- corrected track turns
local TL = { U = { L }, D = { R }, L = { U }, R = { D } } -- '\'
local TR = { U = { R }, D = { L }, L = { D }, R = { U } } -- '/'

-- corrected intersection
local IS = {
	U = { L, U, R },
	R = { U, R, D },
	D = { R, D, L },
	L = { D, L, U },
}

-- ASCII bytes:
local CART_UP = 94
local CART_DOWN = 118
local CART_LEFT = 60
local CART_RIGHT = 62
local TRACK_HORIZONTAL = 45
local TRACK_VERTICAL = 124
local TRACK_TURN_LEFT = 92 -- '\'
local TRACK_TURN_RIGHT = 47
local TRACK_INTERSECTION = 43

--- @function address
--- @param x number
--- @param y number
--- @return string
local function address(x, y)
	return x .. "/" .. y
end

--- @function parse
--- @param lines string[]
--- @return table
--- @return table
local function parse(lines)
	local carts = {}
	local tracks = {}

	for i = 1, #lines do
		local line = lines[i]
		local y = i - 1
		for j = 1, line:len() do
			local c = line:byte(j)
			local x = j - 1
			local xy = address(x, y)
			if c == CART_LEFT then
				carts[#carts + 1] = { id = #carts, x = x, y = y, dir = L, next_turn = 1 } -- next_turn: index in the possible directions at an intersection, in {1,2,3}
				tracks[xy] = SX
			elseif c == CART_RIGHT then
				carts[#carts + 1] = { id = #carts, x = x, y = y, dir = R, next_turn = 1 }
				tracks[xy] = SX
			elseif c == CART_UP then
				carts[#carts + 1] = { id = #carts, x = x, y = y, dir = U, next_turn = 1 }
				tracks[xy] = SY
			elseif c == CART_DOWN then
				carts[#carts + 1] = { id = #carts, x = x, y = y, dir = D, next_turn = 1 }
				tracks[xy] = SY
			elseif c == TRACK_HORIZONTAL then
				tracks[xy] = SX
			elseif c == TRACK_VERTICAL then
				tracks[xy] = SY
			elseif c == TRACK_TURN_LEFT then
				tracks[xy] = TL
			elseif c == TRACK_TURN_RIGHT then
				tracks[xy] = TR
			elseif c == TRACK_INTERSECTION then
				tracks[xy] = IS
			elseif c ~= 32 then
				print("found unknown character " .. string.char(c))
			end
		end
	end

	return carts, tracks
end

--- @function: dx
--- @param dir string
--- @return number
local function dx(dir)
	if dir == R then
		return 1
	end
	if dir == L then
		return -1
	end
	return 0
end

--- @function: dy
--- @param dir string
--- @return number
local function dy(dir)
	if dir == U then
		return -1
	end
	if dir == D then
		return 1
	end
	return 0
end

--- @function: move_cart
--- @param cart table
--- @param tracks table
local function move_cart(cart, tracks, carts_by_pos)
	-- remove old pos
	carts_by_pos[address(cart.x, cart.y)] = nil

	-- move
	cart.x = cart.x + dx(cart.dir)
	cart.y = cart.y + dy(cart.dir)

	local xy = address(cart.x, cart.y)
	local directions = tracks[xy][cart.dir]
	if #directions == 1 then
		cart.dir = directions[1]
	else
		cart.dir = directions[cart.next_turn]
		cart.next_turn = (cart.next_turn % 3) + 1
	end

	-- check collision
	if carts_by_pos[xy] then
		return xy
	end

	carts_by_pos[xy] = cart
	return nil
end

--- @function: sort_carts
--- @param a table
--- @param b table
--- @return boolean
local function sort_carts(a, b)
	-- Sorts by increasing y and then by increasing x
	if a.y < b.y then
		return true
	end
	if a.y == b.y then
		return a.x < b.x
	end
	return false
end

local temp = {}

--- @function: get_collisions
--- @param carts table
--- @return table
local function get_collisions(carts)
	for _, cart in ipairs(carts) do
		local xy = address(cart.x, cart.y)
		temp[xy] = (temp[xy] or 0) + 1
	end

	local collisions = {}
	for k, v in pairs(temp) do
		if v > 1 then
			table.insert(collisions, k)
		end
		temp[k] = nil -- The table must be cleared after use
	end

	return collisions
end

--- @function: remove_crashed
--- @param carts table
--- @param collisions table
--- @return table
local function remove_crashed(carts, collisions)
	local new_carts = {}
	local crashed = {}
	for _, pos in ipairs(collisions) do
		crashed[pos] = true
	end
	for _, cart in ipairs(carts) do
		local xy = address(cart.x, cart.y)
		if not crashed[xy] then
			table.insert(new_carts, cart)
		end
	end
	return new_carts
end

--- @function: tick
--- @param carts table
--- @param tracks table
--- @return table
local function tick(carts, tracks, stop_at_first)
	table.sort(carts, sort_carts)
	local carts_by_pos = {}
	local seen = {}
	for _, c in ipairs(carts) do
		carts_by_pos[address(c.x, c.y)] = c
		local xy = address(c.x, c.y)
		if seen[xy] then
			return { xy }
		end
		seen[xy] = true
	end

	local crashes = {}
	for _, cart in ipairs(carts) do
		if not cart.crashed then
			local crash = move_cart(cart, tracks, carts_by_pos)
			if crash then
				if stop_at_first then
					return { crash }
				end
				-- mark crashed carts
				for _, c in ipairs(carts) do
					if address(c.x, c.y) == crash then
						c.crashed = true
					end
				end
				carts_by_pos[crash] = nil
				table.insert(crashes, crash)
			end
		end
	end
	return crashes
end

--- @description: Finds the location of the first collision
--- @param input string: the puzzle input
--- @return string: the collision position as "x,y"
function M.part1(input)
	local lines = util.read_lines(input)
	local carts, tracks = parse(lines)

	while #carts > 1 do
		local collision = tick(carts, tracks)
		if collision and #collision > 0 then
			local x, y = collision[1]:match("(%d+)/(%d+)")
			return x .. "," .. y
		end
	end
	return "not found"
end

--- @description: Finds the position of the last remaining cart
--- @param input string: the puzzle input
--- @return string: the position as "x,y"
function M.part2(input)
	local lines = util.read_lines(input)
	local carts, tracks = parse(lines)

	while #carts > 1 do
		local collisions = tick(carts, tracks)
		if collisions and #collisions > 0 then
			carts = remove_crashed(carts, collisions)
		end
	end

	if #carts == 1 then
		return carts[1].x .. "," .. carts[1].y
	end
	return "not found"
end

return M
