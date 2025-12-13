--- @title: Day 17: Two Steps Forward ---
local md5 = require("md5")
local M = {}

--- @description: Finds the shortest and longest paths to the vault.
--- @param passcode string: The passcode.
--- @return string|nil: The shortest path.
--- @return number: The length of the longest path.
local function find_paths(passcode)
	local shortest_path = nil
	local longest_path_length = 0

	local queue = { { x = 0, y = 0, path = "" } }

	local moves = {
		U = { dx = 0, dy = -1 },
		D = { dx = 0, dy = 1 },
		L = { dx = -1, dy = 0 },
		R = { dx = 1, dy = 0 },
	}
	local move_order = { "U", "D", "L", "R" }

	while #queue > 0 do
		local current = table.remove(queue, 1)

		if current.x == 3 and current.y == 3 then
			if not shortest_path then
				shortest_path = current.path
			end
			if #current.path > longest_path_length then
				longest_path_length = #current.path
			end
			goto continue
		end

		local hash = md5.sumhexa(passcode .. current.path)
		for i = 1, 4 do
			local char = hash:sub(i, i)
			if char >= "b" and char <= "f" then
				local move_key = move_order[i]
				local move = moves[move_key]
				local next_x, next_y = current.x + move.dx, current.y + move.dy

				if next_x >= 0 and next_x <= 3 and next_y >= 0 and next_y <= 3 then
					table.insert(queue, { x = next_x, y = next_y, path = current.path .. move_key })
				end
			end
		end
		::continue::
	end

	return shortest_path, longest_path_length
end

--- @description: Finds the shortest path to the vault.
--- @param input string: The passcode.
--- @return string|nil: The shortest path.
function M.part1(input)
	local passcode = input:match("%S+")
	local shortest, _ = find_paths(passcode)
	return shortest
end

--- @description: Finds the length of the longest path to the vault.
--- @param input string: The passcode.
--- @return number: The length of the longest path.
function M.part2(input)
	local passcode = input:match("%S+")
	local _, longest = find_paths(passcode)
	return longest
end

return M
