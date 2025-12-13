--- @title: Day 10: Balance Bots ---
local M = {}

--- @description: Find the bot that compares value-61 microchips with value-17 microchips
--- @param input table: of instruction strings
--- @return number: the bot ID that compares 61 and 17
function M.part1(input)
	local bots = {}
	local outputs = {}

	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	-- Parse bot rules
	local value_instructions = {}
	local bot_instructions = {}
	for _, line in ipairs(lines) do
		if line:match("^value") then
			table.insert(value_instructions, line)
		else
			table.insert(bot_instructions, line)
		end
	end

	-- Parse bot rules first
	for _, line in ipairs(bot_instructions) do
		local bot_id, low_type, low_id, high_type, high_id =
			line:match("bot (%d+) gives low to (%w+) (%d+) and high to (%w+) (%d+)")
		bot_id = tonumber(bot_id)
		low_id = tonumber(low_id)
		high_id = tonumber(high_id)
		if not bots[bot_id] then
			if bot_id == nil then
				error("Invalid bot ID")
			end
			bots[bot_id] = { chips = {}, low_to = nil, high_to = nil }
		end
		bots[bot_id].low_to = { type = low_type, id = low_id }
		bots[bot_id].high_to = { type = high_type, id = high_id }
	end

	--- @function: Helper function to give chip to target
	--- @param target_type string: the type of target
	--- @param target_id number|nil: the ID of target
	--- @param value number|nil: the value to give
	--- @param queue table: the queue of bots to process
	--- @param processed table: the processed bots
	--- @return nil
	local function give(target_type, target_id, value, queue, processed)
		if target_type == "bot" then
			if not bots[target_id] then
				if not target_id then
					error("Invalid bot ID")
				end
				bots[target_id] = { chips = {}, low_to = nil, high_to = nil }
			end
			table.insert(bots[target_id].chips, value)
			if #bots[target_id].chips == 2 and not processed[target_id] then
				table.insert(queue, target_id)
				if not target_id then
					error("Invalid bot ID")
				end
				processed[target_id] = true
			end
		elseif target_type == "output" then
			if not outputs[target_id] then
				if not target_id then
					error("Invalid output ID")
				end
				outputs[target_id] = {}
			end
			table.insert(outputs[target_id], value)
		end
	end

	-- Process value instructions and simulate
	local queue = {}
	local processed = {}
	local part1_answer = nil

	for _, line in ipairs(value_instructions) do
		local val, bot_id = line:match("value (%d+) goes to bot (%d+)")
		val = tonumber(val)
		bot_id = tonumber(bot_id)
		give("bot", bot_id, val, queue, processed)
	end

	while #queue > 0 do
		local bot_id = table.remove(queue, 1)
		local bot = bots[bot_id]
		if #bot.chips == 2 and bot.low_to and bot.high_to then
			table.sort(bot.chips)
			local low_val = bot.chips[1]
			local high_val = bot.chips[2]
			if (low_val == 17 and high_val == 61) or (low_val == 61 and high_val == 17) then
				part1_answer = bot_id
			end
			give(bot.low_to.type, bot.low_to.id, low_val, queue, processed)
			give(bot.high_to.type, bot.high_to.id, high_val, queue, processed)
			bot.chips = {}
		end
	end

	return part1_answer
end

--- @description Multiply the values in output bins 0, 1, and 2
--- @param input table of instruction strings
--- @return number the product of values in outputs 0, 1, 2
function M.part2(input)
	local bots = {}
	local outputs = {}

	local lines = {}
	for line in input:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	-- Parse bot rules
	local value_instructions = {}
	local bot_instructions = {}
	for _, line in ipairs(lines) do
		if line:match("^value") then
			table.insert(value_instructions, line)
		else
			table.insert(bot_instructions, line)
		end
	end

	-- Parse bot rules first
	for _, line in ipairs(bot_instructions) do
		local bot_id, low_type, low_id, high_type, high_id =
			line:match("bot (%d+) gives low to (%w+) (%d+) and high to (%w+) (%d+)")
		bot_id = tonumber(bot_id)
		low_id = tonumber(low_id)
		high_id = tonumber(high_id)
		if not bots[bot_id] then
			if bot_id == nil then
				error("Invalid bot ID")
			end
			bots[bot_id] = { chips = {}, low_to = nil, high_to = nil }
		end
		bots[bot_id].low_to = { type = low_type, id = low_id }
		bots[bot_id].high_to = { type = high_type, id = high_id }
	end

	--- @function: Helper function to give chip to target
	--- @param target_type string: Type of target
	--- @param target_id number: ID of target
	--- @param value number: Value of chip to give
	--- @param queue table: Queue of bots to process
	--- @param processed table: Table of processed bots
	--- @return nil
	local function give(target_type, target_id, value, queue, processed)
		if target_type == "bot" then
			if not bots[target_id] then
				bots[target_id] = { chips = {}, low_to = nil, high_to = nil }
			end
			table.insert(bots[target_id].chips, value)
			if #bots[target_id].chips == 2 and not processed[target_id] then
				table.insert(queue, target_id)
				processed[target_id] = true
			end
		elseif target_type == "output" then
			if not outputs[target_id] then
				outputs[target_id] = {}
			end
			table.insert(outputs[target_id], value)
		end
	end

	-- Process value instructions and simulate
	local queue = {}
	local processed = {}

	for _, line in ipairs(value_instructions) do
		local val, bot_id = line:match("value (%d+) goes to bot (%d+)")
		val = tonumber(val)
		bot_id = tonumber(bot_id)
		give("bot", bot_id, val, queue, processed)
	end

	while #queue > 0 do
		local bot_id = table.remove(queue, 1)
		local bot = bots[bot_id]
		if #bot.chips == 2 and bot.low_to and bot.high_to then
			table.sort(bot.chips)
			local low_val = bot.chips[1]
			local high_val = bot.chips[2]
			give(bot.low_to.type, bot.low_to.id, low_val, queue, processed)
			give(bot.high_to.type, bot.high_to.id, high_val, queue, processed)
			bot.chips = {}
		end
	end

	-- Calculate product of outputs 0, 1, 2
	local product = outputs[0][1] * outputs[1][1] * outputs[2][1]
	return product
end

return M
