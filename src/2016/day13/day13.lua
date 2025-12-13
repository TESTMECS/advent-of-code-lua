--- @title: Day 13: A Maze of Twisty Little Cubicles ---
local M = {}

--- @function: is_wall
--- @param x integer
--- @param y integer
--- @param favorite_number integer
--- @return boolean
local function is_wall(x, y, favorite_number)
	if x < 0 or y < 0 then
		return true
	end
	local sum = x * x + 3 * x + 2 * x * y + y + y * y + favorite_number
	local bits = 0
	while sum > 0 do
		if sum % 2 == 1 then
			bits = bits + 1
		end
		sum = math.floor(sum / 2)
	end
	return bits % 2 == 1
end

--- @function: bfs
--- @param favorite_number integer
--- @param start_x integer
--- @param start_y integer
--- @param target_x integer
--- @param target_y integer
--- @param max_steps integer
--- @return integer
local function bfs(favorite_number, start_x, start_y, target_x, target_y, max_steps)
	local queue = { { x = start_x, y = start_y, steps = 0 } }
	local visited = { [start_x .. "," .. start_y] = true }
	local locations_in_steps = 1 -- Start location

	while #queue > 0 do
		local current = table.remove(queue, 1)

		if max_steps and current.steps >= max_steps then
			goto continue
		end

		local dx = { 0, 0, 1, -1 }
		local dy = { 1, -1, 0, 0 }

		for i = 1, 4 do
			local next_x, next_y = current.x + dx[i], current.y + dy[i]
			local key = next_x .. "," .. next_y

			if not visited[key] and not is_wall(next_x, next_y, favorite_number) then
				visited[key] = true
				if not max_steps and next_x == target_x and next_y == target_y then
					return current.steps + 1
				end
				table.insert(queue, { x = next_x, y = next_y, steps = current.steps + 1 })
				if max_steps then
					locations_in_steps = locations_in_steps + 1
				end
			end
		end
		::continue::
	end

	if max_steps then
		return locations_in_steps
	end

	return -1 -- Target not reached
end

--- @description Find the fewest number of steps required to reach 31,39.
--- @param input string The office designer's favorite number.
--- @return number The minimum number of steps.
function M.part1(input)
	local favorite_number = tonumber(input)
	return bfs(favorite_number, 1, 1, 31, 39)
end

--- @description Find how many locations can be reached in at most 50 steps.
--- @param input string The office designer's favorite number.
--- @return number The number of reachable locations.
function M.part2(input)
	local favorite_number = tonumber(input)
	return bfs(favorite_number, 1, 1, nil, nil, 50)
end

return M
