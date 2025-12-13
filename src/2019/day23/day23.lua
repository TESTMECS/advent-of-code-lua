--- @title: Day 23: Category Six ---
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

	local pc, relative_base, halted = 0, 0, false
	local inputs = {}

	local function run(input_val)
		if halted then
			return nil
		end
		if input_val ~= nil then
			table.insert(inputs, input_val)
		end

		while not halted do
			local instr = memory[pc] or 0
			local opcode = instr % 100

			if opcode == 99 then
				halted = true
				return nil
			end

			local function get_mode(p)
				return math.floor(instr / (10 ^ (p + 1))) % 10
			end

			local function raw_param(p)
				return memory[pc + p] or 0
			end

			local function get_param(p)
				local mode, raw = get_mode(p), raw_param(p)
				if mode == 0 then
					return memory[raw] or 0
				elseif mode == 1 then
					return raw
				elseif mode == 2 then
					return memory[raw + relative_base] or 0
				end
			end

			local function get_write_addr(p)
				local mode, raw = get_mode(p), raw_param(p)
				if mode == 0 then
					return raw
				elseif mode == 2 then
					return raw + relative_base
				end
			end

			local addr
			if opcode == 1 then
				addr = get_write_addr(3)
				memory[addr] = get_param(1) + get_param(2)
				pc = pc + 4
			elseif opcode == 2 then
				addr = get_write_addr(3)
				memory[addr] = get_param(1) * get_param(2)
				pc = pc + 4
			elseif opcode == 3 then
				if #inputs == 0 then
					return "needs_input"
				end
				addr = get_write_addr(1)
				memory[addr] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then
				local out = get_param(1)
				pc = pc + 2
				return out
			elseif opcode == 5 then
				if get_param(1) ~= 0 then
					pc = get_param(2)
				else
					pc = pc + 3
				end
			elseif opcode == 6 then
				if get_param(1) == 0 then
					pc = get_param(2)
				else
					pc = pc + 3
				end
			elseif opcode == 7 then
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) < get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 8 then
				addr = get_write_addr(3)
				memory[addr] = (get_param(1) == get_param(2)) and 1 or 0
				pc = pc + 4
			elseif opcode == 9 then
				relative_base = relative_base + get_param(1)
				pc = pc + 2
			else
				error("Unknown opcode " .. tostring(opcode))
			end
		end
	end

	return run
end

local function solve(input)
	local memory = parse_input(input)

	local computers = {}
	local packet_queues = {}
	local output_buffers = {}

	for i = 0, 49 do
		computers[i] = create_intcode(memory)
		packet_queues[i] = {}
		output_buffers[i] = {}
		-- boot: give machine its address (this will either consume it or ask for input)
		computers[i](i)
	end

	local nat_packet = nil
	local part1_answer = nil
	local last_nat_y = nil

	while true do
		local activity_in_round = false

		for i = 0, 49 do
			-- If there's a queued packet, supply X then Y (and collect any outputs produced).
			if #packet_queues[i] > 0 then
				local packet = table.remove(packet_queues[i], 1)

				-- feed X
				local r = computers[i](packet.x)
				while r ~= nil and r ~= "needs_input" do
					table.insert(output_buffers[i], r)
					-- process any complete triples
					if #output_buffers[i] == 3 then
						local addr, x, y = table.unpack(output_buffers[i])
						output_buffers[i] = {}
						if addr == 255 then
							if not part1_answer then
								part1_answer = y
							end
							nat_packet = { x = x, y = y }
						elseif packet_queues[addr] then
							table.insert(packet_queues[addr], { x = x, y = y })
						end
					end
					r = computers[i]() -- poll for next output
				end

				-- feed Y
				r = computers[i](packet.y)
				while r ~= nil and r ~= "needs_input" do
					table.insert(output_buffers[i], r)
					if #output_buffers[i] == 3 then
						local addr, x, y = table.unpack(output_buffers[i])
						output_buffers[i] = {}
						if addr == 255 then
							if not part1_answer then
								part1_answer = y
							end
							nat_packet = { x = x, y = y }
						elseif packet_queues[addr] then
							table.insert(packet_queues[addr], { x = x, y = y })
						end
					end
					r = computers[i]()
				end

				-- we consumed a packet => activity
				activity_in_round = true
			else
				-- No queued packet: ask the VM for output/needs_input; if it asks for input, feed -1 once and collect outputs.
				local r = computers[i]() -- poll: this returns "needs_input" if VM wants input, or an output
				if r == "needs_input" then
					-- feed single -1 and collect outputs that follow
					r = computers[i](-1)
					while r ~= nil and r ~= "needs_input" do
						table.insert(output_buffers[i], r)
						if #output_buffers[i] == 3 then
							local addr, x, y = table.unpack(output_buffers[i])
							output_buffers[i] = {}
							if addr == 255 then
								if not part1_answer then
									part1_answer = y
								end
								nat_packet = { x = x, y = y }
							elseif packet_queues[addr] then
								table.insert(packet_queues[addr], { x = x, y = y })
							end
						end
						r = computers[i]()
					end
					-- feeding -1 that produced no outputs is not "activity"
				else
					-- r may be an output (rare), collect outputs
					while r ~= nil and r ~= "needs_input" do
						table.insert(output_buffers[i], r)
						if #output_buffers[i] == 3 then
							local addr, x, y = table.unpack(output_buffers[i])
							output_buffers[i] = {}
							if addr == 255 then
								if not part1_answer then
									part1_answer = y
								end
								nat_packet = { x = x, y = y }
							elseif packet_queues[addr] then
								table.insert(packet_queues[addr], { x = x, y = y })
							end
						end
						r = computers[i]()
					end
					-- if outputs were produced above, mark activity
					-- detect by checking if any outputs were appended this iteration: simple way is to check last step,
					-- but we already set activity when dequeuing packets. This branch is uncommon; mark activity only if we produced outputs.
					-- (We can detect by looking if output_buffers changed; for brevity, mark activity here if r was not nil initially)
					-- Conservative: if r was not nil at the start, mark activity
					if r ~= "needs_input" then
						-- nothing to do, but keep conservative behavior: no action required here
					end
				end
			end
		end

		-- Determine idle: all packet_queues empty and no outputs produced.
		-- activity_in_round is set when we dequeued packets (above) or when we produced outputs while dequeuing.
		-- If network is idle and NAT has a packet, send NAT packet to 0.
		local any_queue_nonempty = false
		for i = 0, 49 do
			if #packet_queues[i] > 0 then
				any_queue_nonempty = true
				break
			end
		end

		if not activity_in_round and not any_queue_nonempty and nat_packet then
			-- deliver NAT packet to address 0
			if last_nat_y == nat_packet.y then
				return part1_answer, nat_packet.y
			end
			last_nat_y = nat_packet.y
			table.insert(packet_queues[0], { x = nat_packet.x, y = nat_packet.y })
			-- we consider this an activity so the next loop won't immediately detect idle again
		end
	end
end

function M.part1(input)
	local p1, _ = solve(input)
	return p1
end

function M.part2(input)
	local _, p2 = solve(input)
	return p2
end

return M
