--- @title: Day 18: Duet ---
local M = {}

--- @description: Find the first recovered frequency
--- @return number|nil: the frequency
local function get_val(regs, arg)
	if arg:match("^%-?%d") then
		return tonumber(arg)
	else
		return regs[arg] or 0
	end
end

--- @description: Find the first recovered frequency
--- @param input string: the program
--- @return number: the frequency
function M.part1(input)
	local instructions = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(instructions, line)
	end
	local regs = {}
	local pc = 1
	local last_sound = 0
	while pc >= 1 and pc <= #instructions do
		local line = instructions[pc]
		local parts = {}
		for word in line:gmatch("%S+") do
			table.insert(parts, word)
		end
		local op = parts[1]
		local x = parts[2]
		local y = parts[3]
		if op == "snd" then
			last_sound = get_val(regs, x)
			pc = pc + 1
		elseif op == "set" then
			regs[x] = get_val(regs, y)
			pc = pc + 1
		elseif op == "add" then
			regs[x] = (regs[x] or 0) + get_val(regs, y)
			pc = pc + 1
		elseif op == "mul" then
			regs[x] = (regs[x] or 0) * get_val(regs, y)
			pc = pc + 1
		elseif op == "mod" then
			regs[x] = (regs[x] or 0) % get_val(regs, y)
			pc = pc + 1
		elseif op == "rcv" then
			if get_val(regs, x) ~= 0 then
				return last_sound
			end
			pc = pc + 1
		elseif op == "jgz" then
			if get_val(regs, x) > 0 then
				pc = pc + get_val(regs, y)
			else
				pc = pc + 1
			end
		end
	end
	return 0
end

--- @description: Count sends by program 1
--- @param input string: the program
--- @return number: the count
function M.part2(input)
	local instructions = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(instructions, line)
	end
	local prog0 = { regs = { p = 0 }, pc = 1, queue = {}, done = false, waiting = false }
	local prog1 = { regs = { p = 1 }, pc = 1, queue = {}, done = false, waiting = false }
	local send_count = 0
	local step = 0
	while not (prog0.done and prog1.done) do
		step = step + 1
		local prog = step % 2 == 1 and prog0 or prog1
		if not prog.done then
			local line = instructions[prog.pc]
			if not line then
				prog.done = true
			else
				local parts = {}
				for word in line:gmatch("%S+") do
					table.insert(parts, word)
				end
				local op = parts[1]
				local x = parts[2]
				local y = parts[3]
				if op == "snd" then
					local other = step % 2 == 1 and prog1 or prog0
					table.insert(other.queue, get_val(prog.regs, x))
					if step % 2 == 0 then
						send_count = send_count + 1
					end
					prog.pc = prog.pc + 1
				elseif op == "set" then
					prog.regs[x] = get_val(prog.regs, y)
					prog.pc = prog.pc + 1
				elseif op == "add" then
					prog.regs[x] = (prog.regs[x] or 0) + get_val(prog.regs, y)
					prog.pc = prog.pc + 1
				elseif op == "mul" then
					prog.regs[x] = (prog.regs[x] or 0) * get_val(prog.regs, y)
					prog.pc = prog.pc + 1
				elseif op == "mod" then
					prog.regs[x] = (prog.regs[x] or 0) % get_val(prog.regs, y)
					prog.pc = prog.pc + 1
				elseif op == "rcv" then
					if #prog.queue > 0 then
						prog.regs[x] = table.remove(prog.queue, 1)
						prog.pc = prog.pc + 1
						prog.waiting = false
					else
						prog.waiting = true
					end
				elseif op == "jgz" then
					if get_val(prog.regs, x) > 0 then
						prog.pc = prog.pc + get_val(prog.regs, y)
					else
						prog.pc = prog.pc + 1
					end
				end
				if prog.pc < 1 or prog.pc > #instructions then
					prog.done = true
				end
			end
		end
		if prog0.waiting and prog1.waiting then
			break
		end
	end
	return send_count
end

return M
