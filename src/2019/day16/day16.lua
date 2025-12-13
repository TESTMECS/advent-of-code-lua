--- @title: Day 16: Flawed Frequency Transmission ---
local M = {}

-- Base pattern
local base_pattern = { 0, 1, 0, -1 }

--- @function: Generate the pattern for a given position (1-based index)
--- @param pos number: The position.
--- @param length number: The length.
--- @return table: The pattern.
local function pattern_for_position(pos, length)
	local pat = {}
	while #pat <= length do
		for _, val in ipairs(base_pattern) do
			for _ = 1, pos do
				table.insert(pat, val)
			end
		end
	end
	-- Skip the very first element
	table.remove(pat, 1)
	return pat
end

--- @function: Apply one phase of FFT
--- @param signal table: The signal.
--- @return table: The output.
local function fft_phase(signal)
	local output = {}
	local n = #signal
	for pos = 1, n do
		local pat = pattern_for_position(pos, n)
		local sum = 0
		for i = 1, n do
			sum = sum + signal[i] * pat[i]
		end
		output[pos] = math.abs(sum) % 10
	end
	return output
end

--- @function: Convert string to digit array
--- @param s string: The string.
--- @return table: The digit array.
local function to_digits(s)
	local t = {}
	for i = 1, #s do
		t[i] = tonumber(s:sub(i, i))
	end
	return t
end

--- @function: Convert digit array to string
--- @param t table: The digit array.
--- @param from number: The start index.
--- @param to_ number: The end index.
--- @return string: The string.
local function digits_to_str(t, from, to_)
	local out = {}
	for i = from, to_ do
		table.insert(out, tostring(t[i]))
	end
	return table.concat(out)
end

--- @description: Find the signal.
--- @param input string: The puzzle input.
--- @return string: The signal.
function M.part1(input)
	local signal = to_digits(input:match("^%s*(.-)%s*$"))
	for _ = 1, 100 do
		signal = fft_phase(signal)
	end
	return digits_to_str(signal, 1, 8)
end

--- @description: Find the signal.
--- @param input string: The puzzle input.
--- @return string: The signal.
function M.part2(input)
	local signal_str = input:match("^%s*(.-)%s*$")
	local offset = tonumber(signal_str:sub(1, 7))
	local signal = to_digits(signal_str)

	-- Repeat 10000 times
	local full_len = #signal * 10000
	local tail_len = full_len - offset

	-- Only build the part we care about (offset .. end)
	local tail = {}
	for i = 1, tail_len do
		local idx = ((offset + i - 1) % #signal) + 1
		tail[i] = signal[idx]
	end

	-- Apply 100 phases with suffix-sum trick
	for _ = 1, 100 do
		local acc = 0
		for i = #tail, 1, -1 do
			acc = (acc + tail[i]) % 10
			tail[i] = acc
		end
	end

	return digits_to_str(tail, 1, 8)
end

return M
