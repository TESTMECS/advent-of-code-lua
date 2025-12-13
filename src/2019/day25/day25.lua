--- @title: Day 25: Cryostasis (fixed VM + ASCII IO)
local M = {}

local function parse_input(input)
	local memory = {}
	local i = 0
	for num_str in input:gmatch("([^,]+)") do
		memory[i] = tonumber(num_str)
		i = i + 1
	end
	return memory
end

local function create_intcode(initial_memory)
	local memory = {}
	for k, v in pairs(initial_memory) do
		memory[k] = v
	end

	local pc = 0
	local rb = 0
	local halted = false
	local inputs = {}

	local function get_mode(instr, p)
		return math.floor(instr / (10 ^ (p + 1))) % 10
	end

	local function read_raw(addr)
		return memory[addr] or 0
	end

	local function run(input_val)
		if halted then
			return nil
		end
		if input_val ~= nil then
			table.insert(inputs, input_val)
		end

		while true do
			local instr = read_raw(pc)
			local opcode = instr % 100

			if opcode == 99 then
				halted = true
				return nil
			end

			local function param(p)
				local mode = get_mode(instr, p)
				local raw = read_raw(pc + p)
				if mode == 0 then
					return read_raw(raw)
				elseif mode == 1 then
					return raw
				elseif mode == 2 then
					return read_raw(raw + rb)
				end
			end

			local function write_addr(p)
				local mode = get_mode(instr, p)
				local raw = read_raw(pc + p)
				if mode == 0 then
					return raw
				elseif mode == 2 then
					return raw + rb
				else
					error("invalid write mode " .. tostring(mode))
				end
			end

			if opcode == 1 then
				memory[write_addr(3)] = param(1) + param(2)
				pc = pc + 4
			elseif opcode == 2 then
				memory[write_addr(3)] = param(1) * param(2)
				pc = pc + 4
			elseif opcode == 3 then
				if #inputs == 0 then
					return "needs_input"
				end
				memory[write_addr(1)] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then
				local out = param(1)
				pc = pc + 2
				return out
			elseif opcode == 5 then
				pc = (param(1) ~= 0) and param(2) or pc + 3
			elseif opcode == 6 then
				pc = (param(1) == 0) and param(2) or pc + 3
			elseif opcode == 7 then
				memory[write_addr(3)] = (param(1) < param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 8 then
				memory[write_addr(3)] = (param(1) == param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 9 then
				rb = rb + param(1)
				pc = pc + 2
			else
				error("Unknown opcode " .. tostring(opcode))
			end
		end
	end

	return run
end

function M.part1(input)
	local memory = parse_input(input)
	local computer = create_intcode(memory)

	local map = {}
	local inventory = {}
	local current_room = nil
	local last_doors, last_items = {}, {}
	local path = {}
	local exploring = true
	local checkpoint_found = false

	local reverse_dir = { north = "south", south = "north", east = "west", west = "east" }

	-- Dangerous items to avoid
	local dangerous = {
		["infinite loop"] = true,
		["photons"] = true,
		["escape pod"] = true,
		["molten lava"] = true,
		["giant electromagnet"] = true,
	}

	local input_stream = {}
	local output_str, current_line, lines = "", "", {}

	local function send_command(cmd)
		for i = 1, #cmd do
			table.insert(input_stream, string.byte(cmd, i))
		end
		table.insert(input_stream, 10)
	end

	local function parse_room()
		local room_name, doors, items = "", {}, {}
		for i = #lines, 1, -1 do
			local line = lines[i]
			if line:find("==") then
				room_name = line:gsub("==", ""):gsub("^%s*(.-)%s*$", "%1")
				break
			end
		end
		local in_doors, in_items = false, false
		for _, line in ipairs(lines) do
			if line:find("Doors here lead:") then
				in_doors = true
			elseif in_doors then
				if line:find("- ") then
					doors[line:gsub("- ", ""):gsub("^%s*(.-)%s*$", "%1")] = true
				else
					in_doors = false
				end
			end
			if line:find("Items here:") then
				in_items = true
			elseif in_items then
				if line:find("- ") then
					local item = line:gsub("- ", ""):gsub("^%s*(.-)%s*$", "%1")
					items[item] = true
				else
					in_items = false
				end
			end
		end
		return room_name, doors, items
	end

	local function decide_action(room_name, doors, items)
		for item, _ in pairs(items) do
			if not dangerous[item] and not inventory[item] then
				inventory[item] = true
				items[item] = nil
				return "take " .. item
			end
		end
		if not map[room_name] then
			map[room_name] = { doors = doors, items = items, explored_dirs = {} }
		end
		local dirs_order = { "north", "south", "east", "west" }
		for _, dir in ipairs(dirs_order) do
			if doors[dir] and not map[room_name].explored_dirs[dir] then
				map[room_name].explored_dirs[dir] = true
				table.insert(path, { room = room_name, dir = dir })
				return dir
			end
		end
		if #path > 0 then
			local last = table.remove(path)
			return reverse_dir[last.dir]
		end
		return nil
	end

	-- Main exploration loop
	while #input_stream > 0 or exploring do
		local val = computer()
		if val == "needs_input" then
			if #input_stream > 0 then
				computer(table.remove(input_stream, 1))
			else
				break
			end
		elseif val == nil then
			break
		else
			if val <= 255 then
				local char = string.char(val)
				output_str = output_str .. char
				if char == "\n" then
					table.insert(lines, current_line)
					current_line = ""
				else
					current_line = current_line .. char
				end
				if current_line:match("^Command%?") then
					local room_name, doors, items = parse_room()
					if room_name ~= "" then
						print("Current room: " .. room_name)
						if room_name:find("Security") or room_name:find("Pressure") or room_name:find("Floor") then
							checkpoint_found = true
							print("Checkpoint found: " .. room_name)
						end
						current_room = room_name
						last_doors, last_items = doors, items
					end
					lines = {}
					current_line = ""
					if exploring and current_room then
						local action = decide_action(current_room, last_doors, last_items)
						if action then
							print("Action: " .. action)
							send_command(action)
						else
							exploring = false
							print("Exploration complete")
						end
					end
				end
			else
				return val -- password already found
			end
		end
	end

	-- Brute-force at checkpoint
	if checkpoint_found then
		local safe_items = {}
		for item, _ in pairs(inventory) do
			table.insert(safe_items, item)
		end
		print("Collected safe items: " .. table.concat(safe_items, ", "))
		local n = #safe_items
		local checkpoint_door = "east" -- <- set the correct door from your map

		for mask = 0, (1 << n) - 1 do
			print("Trying combination mask: " .. mask)
			-- drop all items first
			for _, item in ipairs(safe_items) do
				send_command("drop " .. item)
			end
			-- pick items according to mask
			for j = 1, n do
				if ((mask >> (j - 1)) & 1) ~= 0 then
					send_command("take " .. safe_items[j])
				end
			end
			-- move through checkpoint
			send_command(checkpoint_door)

			local output_buffer = {}
			while true do
				local out = computer(#input_stream > 0 and table.remove(input_stream, 1) or nil)
				if out == nil then
					break
				end
				if type(out) == "number" and out > 255 then
					print("Password found: " .. out)
					return out
				elseif type(out) == "number" and out <= 255 then
					table.insert(output_buffer, string.char(out))
				elseif out == "needs_input" then
					break
				end
			end
			local output_str = table.concat(output_buffer, "")
			if
				mask == 0
				or output_str:find("Alert")
				or output_str:find("heavier")
				or output_str:find("lighter")
				or output_str:find("password")
			then
				print("Output for mask " .. mask .. ": " .. output_str)
			end
			if output_str:find("password") then
				local num = output_str:match("(%d+)")
				if num then
					print("Password found: " .. num)
					return tonumber(num)
				end
			end
		end
	end

	return "Password not found"
end

function M.part2(input)
	return 0
end

return M
