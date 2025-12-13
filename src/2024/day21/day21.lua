---  @title: Day 21: Keypad Conundrum
local M = {}

local numeric_keypad = {
    ["7"] = {1,1}, ["8"] = {2,1}, ["9"] = {3,1},
    ["4"] = {1,2}, ["5"] = {2,2}, ["6"] = {3,2},
    ["1"] = {1,3}, ["2"] = {2,3}, ["3"] = {3,3},
    ["0"] = {2,4}, ["A"] = {3,4}
}

local directional_keypad = {
    ["^"] = {2,1}, ["A"] = {3,1},
    ["<"] = {1,2}, ["v"] = {2,2}, [">"] = {3,2}
}

local memo = {}

local function get_pos(keypad, key)
    return keypad[key][1], keypad[key][2]
end

local function moves_from_to(keypad, from, to, dead)
    local fx, fy = get_pos(keypad, from)
    local tx, ty = get_pos(keypad, to)
    local dx, dy = tx - fx, ty - fy
    local horiz = (dx > 0 and ">" or "<"):rep(math.abs(dx))
    local vert = (dy > 0 and "v" or "^"):rep(math.abs(dy))
    local paths = {}
    if dx ~= 0 and dy ~= 0 then
        -- two possible orders
        local path1 = horiz .. vert .. "A"
        local path2 = vert .. horiz .. "A"
        -- check if either path avoids dead
        local function avoids_dead(path)
            local x, y = fx, fy
            for i = 1, #path - 1 do
                local move = path:sub(i,i)
                if move == ">" then x = x + 1
                elseif move == "<" then x = x - 1
                elseif move == "^" then y = y - 1
                elseif move == "v" then y = y + 1 end
                if x == dead[1] and y == dead[2] then return false end
            end
            return true
        end
        if avoids_dead(path1) then table.insert(paths, path1) end
        if avoids_dead(path2) then table.insert(paths, path2) end
    else
        table.insert(paths, horiz .. vert .. "A")
    end
    return paths
end

local function min_length(code, depth, keypad, dead)
    if depth == 0 then return #code end
    local key = code .. depth
    if memo[key] then return memo[key] end
    local total = 0
    local prev = "A"
    for i = 1, #code do
        local char = code:sub(i,i)
        local paths = moves_from_to(keypad, prev, char, dead)
        local min_len = math.huge
        for _, path in ipairs(paths) do
            min_len = math.min(min_len, min_length(path, depth - 1, directional_keypad, {1,1}))
        end
        total = total + min_len
        prev = char
    end
    memo[key] = total
    return total
end

function M.part1(input)
    local lines = {}
    for line in input:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local sum = 0
    for _, code in ipairs(lines) do
        local len = min_length(code, 2, numeric_keypad, {1,4})
        local num = tonumber(code:match("%d+"))
        sum = sum + len * num
    end
    return sum
end

function M.part2(input)
    local lines = {}
    for line in input:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local sum = 0
    for _, code in ipairs(lines) do
        local len = min_length(code, 25, numeric_keypad, {1,4})
        local num = tonumber(code:match("%d+"))
        sum = sum + len * num
    end
    return sum
end

return M
