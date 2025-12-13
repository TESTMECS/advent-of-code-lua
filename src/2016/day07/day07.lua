--- @title: Day 7: Internet Protocol Version 7 ---
local M = {}

--- @function: has_abba
--- @param s string
--- @return boolean
local function has_abba(s)
	for i = 1, #s - 3 do
		local a = s:sub(i, i)
		local b = s:sub(i + 1, i + 1)
		local c = s:sub(i + 2, i + 2)
		local d = s:sub(i + 3, i + 3)
		if a == d and b == c and a ~= b then
			return true
		end
	end
	return false
end

--- @function: get_aba
--- @param s string
--- @return table
local function get_aba(s)
	local abas = {}
	for i = 1, #s - 2 do
		local a = s:sub(i, i)
		local b = s:sub(i + 1, i + 1)
		local c = s:sub(i + 2, i + 2)
		if a == c and a ~= b then
			table.insert(abas, a .. b .. c)
		end
	end
	return abas
end

--- @function: has_bab
--- @param hypernets table
--- @param bab string
--- @return boolean
local function has_bab(hypernets, bab)
	for _, h in ipairs(hypernets) do
		if h:find(bab, 1, true) then
			return true
		end
	end
	return false
end

--- @description: Counts the number of IPs that support TLS by checking for ABBA sequences in supernet sequences but not in hypernet sequences.
--- @param input string The multiline input string containing IPv7 addresses.
--- @return number: The count of IPs supporting TLS.
function M.part1(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local supernet = {}
		local hypernet = {}
		local pos = 1
		while pos <= #line do
			local start_bracket = line:find("%[", pos)
			if start_bracket then
				if start_bracket > pos then
					table.insert(supernet, line:sub(pos, start_bracket - 1))
				end
				local end_bracket = line:find("%]", start_bracket)
				if end_bracket then
					table.insert(hypernet, line:sub(start_bracket + 1, end_bracket - 1))
					pos = end_bracket + 1
				else
					pos = #line + 1
				end
			else
				table.insert(supernet, line:sub(pos))
				pos = #line + 1
			end
		end
		local has_supernet_abba = false
		for _, s in ipairs(supernet) do
			if has_abba(s) then
				has_supernet_abba = true
				break
			end
		end
		local has_hypernet_abba = false
		for _, h in ipairs(hypernet) do
			if has_abba(h) then
				has_hypernet_abba = true
				break
			end
		end
		if has_supernet_abba and not has_hypernet_abba then
			count = count + 1
		end
	end
	return count
end

--- @description: Counts the number of IPs that support SSL by checking for ABA sequences in supernet sequences with corresponding BAB sequences in hypernet sequences.
--- @param input string: The multiline input string containing IPv7 addresses.
--- @return number: The count of IPs supporting SSL.
function M.part2(input)
	local count = 0
	for line in input:gmatch("[^\n]+") do
		local supernet = {}
		local hypernet = {}
		local pos = 1
		while pos <= #line do
			local start_bracket = line:find("%[", pos)
			if start_bracket then
				if start_bracket > pos then
					table.insert(supernet, line:sub(pos, start_bracket - 1))
				end
				local end_bracket = line:find("%]", start_bracket)
				if end_bracket then
					table.insert(hypernet, line:sub(start_bracket + 1, end_bracket - 1))
					pos = end_bracket + 1
				else
					pos = #line + 1
				end
			else
				table.insert(supernet, line:sub(pos))
				pos = #line + 1
			end
		end
		local abas = {}
		for _, s in ipairs(supernet) do
			for _, aba in ipairs(get_aba(s)) do
				table.insert(abas, aba)
			end
		end
		local supports = false
		for _, aba in ipairs(abas) do
			local bab = aba:sub(2, 2) .. aba:sub(1, 1) .. aba:sub(2, 2)
			if has_bab(hypernet, bab) then
				supports = true
				break
			end
		end
		if supports then
			count = count + 1
		end
	end
	return count
end

return M
