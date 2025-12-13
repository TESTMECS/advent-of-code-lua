--- @title: --- Day 20: Pulse Propagation ---
local M = {}

--- @description
--- @param input string
--- @return number
function M.part1(input)
	local nodes = {}
	local node_status = {}
	local node_inputs = {}
	for line in input:gmatch("[^\n]+") do
		local nodeName = ""
		for nodeType, name in line:gmatch("(%S)(%S+)%s%->") do
			nodeName = name
			node_status[nodeName] = { ["type"] = nodeType, ["status"] = false }
		end

		line = line .. ","
		for connectedNode in line:gmatch("(%S+),") do
			nodes[nodeName] = nodes[nodeName] or {}
			table.insert(nodes[nodeName], connectedNode)
			node_inputs[connectedNode] = node_inputs[connectedNode] or {}
			node_inputs[connectedNode][nodeName] = false
		end
	end
	local low = 1000
	local high = 0
	local function push(queue, from, signal)
		if signal then
			high = high + #nodes[from]
		else
			low = low + #nodes[from]
		end
		for _, receiver in ipairs(nodes[from]) do
			table.insert(queue, { receiver, signal, from })
		end
	end

	for times = 1, 1000 do
		local queue = { { "roadcaster", false, "button" } }
		while next(queue) do
			local item = table.remove(queue, 1)
			local node, signal, fromNode = table.unpack(item)

			if not node_status[node] then
				goto continue
			end
			if node_status[node]["type"] == "%" then
				if not signal then
					node_status[node]["status"] = not node_status[node]["status"]
					if node_status[node]["status"] then
						push(queue, node, true)
						goto continue
					else
						push(queue, node, false)
						goto continue
					end
				end
			elseif node_status[node]["type"] == "&" then
				node_inputs[node][fromNode] = signal
				for _, inputStatus in pairs(node_inputs[node]) do
					if not inputStatus then
						push(queue, node, true)
						goto continue
					end
				end
				push(queue, node, false)
				goto continue
			else
				push(queue, node, false)
				goto continue
			end
			::continue::
		end
	end
	return high * low
end

--- @description add description here
--- @param input string the puzzle input
--- @return number describe the output
function M.part2(input)
	local nodes = {}
	local node_status = {}
	local node_inputs = {}
	for line in input:gmatch("[^\n]+") do
		local nodeName = ""
		for nodeType, name in line:gmatch("(%S)(%S+)%s%->") do
			nodeName = name
			node_status[nodeName] = { ["type"] = nodeType, ["status"] = false }
		end
		line = line .. ","
		for connectedNode in line:gmatch("(%S+),") do
			nodes[nodeName] = nodes[nodeName] or {}
			table.insert(nodes[nodeName], connectedNode)
			node_inputs[connectedNode] = node_inputs[connectedNode] or {}
			node_inputs[connectedNode][nodeName] = false
		end
	end
	local low = 1000
	local high = 0
	local function push(queue, from, signal)
		if signal then
			high = high + #nodes[from]
		else
			low = low + #nodes[from]
		end
		for _, receiver in ipairs(nodes[from]) do
			table.insert(queue, { receiver, signal, from })
		end
	end
	local target_node = ""
	for from, pipeline in pairs(nodes) do
		for _, node in ipairs(pipeline) do
			if node == "rx" then
				target_node = from
			end
		end
	end
	local inputs = 0
	for _, pipeline in pairs(nodes) do
		for _, node in ipairs(pipeline) do
			if node == target_node then
				inputs = inputs + 1
			end
		end
	end
	local function len(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end
	local function gcd(a, b)
		while b ~= 0 do
			local q = a
			a = b
			b = q % a
		end
		return a
	end
	local function lcm(a, b)
		return (m ~= 0 and n ~= 0) and (a * b) / gcd(a, b) or 0
	end
	local cycle = {}
	for times = 1, 1000000000 do
		local queue = { { "roadcaster", false, "button" } }
		while next(queue) do
			local item = table.remove(queue, 1)
			local node, signal, from = table.unpack(item)
			if node == target_node and signal then
				if cycle[from] then
					cycle[from] = times - cycle[from]
				else
					cycle[from] = times
				end
			end
			if len(cycle) == inputs then
				local result = 1
				for _, v in pairs(cycle) do
					result = lcm(result, v)
				end
				return math.ceil(result)
			end
			if not node_status[node] then
				goto continue
			end
			if node_status[node]["type"] == "%" then
				if not signal then
					node_status[node]["status"] = not node_status[node]["status"]
					if node_status[node]["status"] then
						push(queue, node, true)
						goto continue
					else
						push(queue, node, false)
						goto continue
					end
				end
			elseif node_status[node]["type"] == "&" then
				node_inputs[node][from] = signal
				for _, inputStatus in pairs(node_inputs[node]) do
					if not inputStatus then
						push(queue, node, true)
						goto continue
					end
				end
				push(queue, node, false)
				goto continue
			else
				push(queue, node, false)
				goto continue
			end
			::continue::
		end
	end
	return 0
end

return M
