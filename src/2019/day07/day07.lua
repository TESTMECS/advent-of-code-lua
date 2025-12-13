--- @title: Day 07: Title ---
local M = {}

--- @function: parse_input
--- @param input string
--- @return table
local function parse_input(input)
	local nums = {}
	for num in input:gmatch("%d+") do
		table.insert(nums, tonumber(num))
	end
	return nums
end

--- @function: create_amplifier
--- @param memory table
--- @param phase number
--- @return function
local function create_amplifier(memory, phase)
	local mem = {}
	for i, v in ipairs(memory) do
		mem[i] = v
	end
	local pc = 1
	local inputs = { phase }
	local halted = false
	local function run(signal)
		if halted then
			return nil
		end
		table.insert(inputs, signal)
		while true do
			local instr = mem[pc]
			local opcode = instr % 100
			local modes = {}
			local temp = math.floor(instr / 100)
			for i = 1, 3 do
				modes[i] = temp % 10
				temp = math.floor(temp / 10)
			end
			local function get_param(i)
				local mode = modes[i]
				local val = mem[pc + i]
				if mode == 0 then
					return mem[val + 1]
				else
					return val
				end
			end
			local function set_param(i, value)
				local val = mem[pc + i]
				mem[val + 1] = value
			end
			if opcode == 1 then
				local a = get_param(1)
				local b = get_param(2)
				set_param(3, a + b)
				pc = pc + 4
			elseif opcode == 2 then
				local a = get_param(1)
				local b = get_param(2)
				set_param(3, a * b)
				pc = pc + 4
			elseif opcode == 3 then
				if #inputs == 0 then
					return nil
				end
				mem[mem[pc + 1] + 1] = table.remove(inputs, 1)
				pc = pc + 2
			elseif opcode == 4 then
				local out = get_param(1)
				pc = pc + 2
				return out
			elseif opcode == 5 then
				local a = get_param(1)
				if a ~= 0 then
					pc = get_param(2) + 1
				else
					pc = pc + 3
				end
			elseif opcode == 6 then
				local a = get_param(1)
				if a == 0 then
					pc = get_param(2) + 1
				else
					pc = pc + 3
				end
			elseif opcode == 7 then
				local a = get_param(1)
				local b = get_param(2)
				set_param(3, a < b and 1 or 0)
				pc = pc + 4
			elseif opcode == 8 then
				local a = get_param(1)
				local b = get_param(2)
				set_param(3, a == b and 1 or 0)
				pc = pc + 4
			elseif opcode == 99 then
				halted = true
				return nil
			else
				error("unknown opcode " .. opcode)
			end
		end
	end
	return run
end

--- @description Find the maximum output from amplifiers with phases 0-4
--- @param input string the puzzle input
--- @return number the maximum output
function M.part1(input)
	local memory = parse_input(input)
	local max_output = 0
	local phases = { 0, 1, 2, 3, 4 }
	local function permute(arr, n)
		if n == 0 then
			local amps = {}
			for i, phase in ipairs(arr) do
				amps[i] = create_amplifier(memory, phase)
			end
			local signal = 0
			for i = 1, 5 do
				local out = amps[i](signal)
				signal = out
			end
			if signal > max_output then
				max_output = signal
			end
		else
			for i = 1, n do
				arr[i], arr[n] = arr[n], arr[i]
				permute(arr, n - 1)
				arr[i], arr[n] = arr[n], arr[i]
			end
		end
	end
	permute(phases, 5)
	return max_output
end

--- @description Find the maximum output from amplifiers with phases 5-9 in feedback loop
--- @param input string the puzzle input
--- @return number the maximum output
function M.part2(input)
	local memory = parse_input(input)
	local max_output = 0
	local phases = { 5, 6, 7, 8, 9 }
	local function permute(arr, n)
		if n == 0 then
			local amps = {}
			for i, phase in ipairs(arr) do
				amps[i] = create_amplifier(memory, phase)
			end
			local signal = 0
			local last_e = 0
			local all_halted = false
			while not all_halted do
				all_halted = true
				for i = 1, 5 do
					local out = amps[i](signal)
					if out then
						signal = out
						if i == 5 then
							last_e = out
						end
						all_halted = false
					end
				end
			end
			if last_e > max_output then
				max_output = last_e
			end
		else
			for i = 1, n do
				arr[i], arr[n] = arr[n], arr[i]
				permute(arr, n - 1)
				arr[i], arr[n] = arr[n], arr[i]
			end
		end
	end
	permute(phases, 5)
	return max_output
end

return M
