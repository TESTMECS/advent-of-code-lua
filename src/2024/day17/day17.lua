--- @title: --- Day 17: Chronospatial Computer
local M = {}

--- @description Run the program and output the result
--- @param input string the puzzle input
--- @return string the output
function M.part1(input)
    local lines = {}
    for line in input:gmatch("[^\n]+") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    local a = tonumber(lines[1]:match("Register A: (%d+)"))
    local b = tonumber(lines[2]:match("Register B: (%d+)"))
    local c = tonumber(lines[3]:match("Register C: (%d+)"))
    local prog_str = lines[4]:match("Program: (.+)")
    local prog = {}
    for num in prog_str:gmatch("%d+") do
        table.insert(prog, tonumber(num))
    end
    local ip = 1
    local output = {}
    local function combo(op)
        if op <= 3 then return op
        elseif op == 4 then return a
        elseif op == 5 then return b
        elseif op == 6 then return c
        end
    end
    while ip <= #prog do
        local ins = prog[ip]
        local op = prog[ip + 1]
        if ins == 0 then -- adv
            a = a // (2 ^ combo(op))
        elseif ins == 1 then -- bxl
            b = b ~ op
        elseif ins == 2 then -- bst
            b = combo(op) % 8
        elseif ins == 3 then -- jnz
            if a ~= 0 then ip = op + 1 goto continue end
        elseif ins == 4 then -- bxc
            b = b ~ c
        elseif ins == 5 then -- out
            table.insert(output, combo(op) % 8)
        elseif ins == 6 then -- bdv
            b = a // (2 ^ combo(op))
        elseif ins == 7 then -- cdv
            c = a // (2 ^ combo(op))
        end
        ip = ip + 2
        ::continue::
    end
    return table.concat(output, ",")
end

--- @description Find the initial A that outputs the program
--- @param input string the puzzle input
--- @return number the initial A
function M.part2(input)
    local lines = {}
    for line in input:gmatch("[^\n]+") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    local prog_str = lines[4]:match("Program: (.+)")
    local prog = {}
    for num in prog_str:gmatch("%d+") do
        table.insert(prog, tonumber(num))
    end
    local function run(a)
        local b, c = 0, 0
        local ip = 1
        local output = {}
        local function combo(op)
            if op <= 3 then return op
            elseif op == 4 then return a
            elseif op == 5 then return b
            elseif op == 6 then return c
            end
        end
        while ip <= #prog do
            local ins = prog[ip]
            local op = prog[ip + 1]
            if ins == 0 then
                a = a // (2 ^ combo(op))
            elseif ins == 1 then
                b = b ~ op
            elseif ins == 2 then
                b = combo(op) % 8
            elseif ins == 3 then
                if a ~= 0 then ip = op + 1 goto continue end
            elseif ins == 4 then
                b = b ~ c
            elseif ins == 5 then
                table.insert(output, combo(op) % 8)
            elseif ins == 6 then
                b = a // (2 ^ combo(op))
            elseif ins == 7 then
                c = a // (2 ^ combo(op))
            end
            ip = ip + 2
            ::continue::
        end
        return output
    end
    local function find_a(index, current_a)
        if index == 0 then
            local out = run(current_a)
            if #out == #prog then return current_a end
            return nil
        end
        for i = 0, 7 do
            local test_a = current_a * 8 + i
            local out = run(test_a)
            if #out >= index and out[index] == prog[index] then
                local res = find_a(index - 1, test_a)
                if res then return res end
            end
        end
        return nil
    end
    return find_a(#prog, 0) or 0
end
return M
