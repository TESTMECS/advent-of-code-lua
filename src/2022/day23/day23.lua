--- @title: Day 23: Unstable Diffusion ---
local M = {}

local dirs = {
    {dy = -1, dx = 0, checks = {{dy = -1, dx = -1}, {dy = -1, dx = 0}, {dy = -1, dx = 1}}}, -- north
    {dy = 1, dx = 0, checks = {{dy = 1, dx = -1}, {dy = 1, dx = 0}, {dy = 1, dx = 1}}},   -- south
    {dy = 0, dx = -1, checks = {{dy = -1, dx = -1}, {dy = 0, dx = -1}, {dy = 1, dx = -1}}}, -- west
    {dy = 0, dx = 1, checks = {{dy = -1, dx = 1}, {dy = 0, dx = 1}, {dy = 1, dx = 1}}},     -- east
}

local function parse(input)
    local elves = {}
    local y = 0
    for line in input:gmatch("[^\n]+") do
        line = line:gsub("\r", "")
        if #line > 0 then
            y = y + 1
            for x = 1, #line do
                if line:sub(x, x) == '#' then
                    elves[y .. "," .. x] = true
                end
            end
        end
    end
    return elves
end

local function has_adjacent(elves, y, x)
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dy ~= 0 or dx ~= 0 then
                if elves[(y + dy) .. "," .. (x + dx)] then
                    return true
                end
            end
        end
    end
    return false
end

local function simulate_round(elves, dir_index)
    local proposals = {}
    for pos in pairs(elves) do
        local y, x = pos:match("(-?%d+),(-?%d+)")
        y, x = tonumber(y), tonumber(x)

        if has_adjacent(elves, y, x) then
            for i = 0, 3 do
                local d = dirs[(dir_index + i - 1) % 4 + 1]
                local can = true
                for _, c in ipairs(d.checks) do
                    if elves[(y + c.dy) .. "," .. (x + c.dx)] then
                        can = false
                        break
                    end
                end
                if can then
                    local ny, nx = y + d.dy, x + d.dx
                    local npos = ny .. "," .. nx
                    if not proposals[npos] then proposals[npos] = {} end
                    table.insert(proposals[npos], pos)
                    break
                end
            end
        end
    end

    local movers = {}
    for npos, froms in pairs(proposals) do
        if #froms == 1 then
            movers[froms[1]] = npos
        end
    end

    local new_elves = {}
    local moved = false
    for pos in pairs(elves) do
        if movers[pos] then
            new_elves[movers[pos]] = true
            moved = true
        else
            new_elves[pos] = true
        end
    end
    return new_elves, moved
end

--- @description Simulate 10 rounds and count empty ground in bounding rectangle
--- @param input string the puzzle input
--- @return number the number of empty ground tiles
function M.part1(input)
    local elves = parse(input)
    local dir_index = 1
    for round = 1, 10 do
        elves, _ = simulate_round(elves, dir_index)
        dir_index = dir_index % 4 + 1
    end

    local miny, maxy, minx, maxx = math.huge, -math.huge, math.huge, -math.huge
    for pos in pairs(elves) do
        local y, x = pos:match("(-?%d+),(-?%d+)")
        y, x = tonumber(y), tonumber(x)
        miny = math.min(miny, y)
        maxy = math.max(maxy, y)
        minx = math.min(minx, x)
        maxx = math.max(maxx, x)
    end
    local area = (maxy - miny + 1) * (maxx - minx + 1)
    local count = 0
    for _ in pairs(elves) do count = count + 1 end
    return area - count
end

--- @description Find the first round where no elf moves
--- @param input string the puzzle input
--- @return number the round number
function M.part2(input)
    local elves = parse(input)
    local dir_index = 1
    local round = 0
    while true do
        round = round + 1
        local moved
        elves, moved = simulate_round(elves, dir_index)
        if not moved then
            return round
        end
        dir_index = dir_index % 4 + 1
    end
end

return M
