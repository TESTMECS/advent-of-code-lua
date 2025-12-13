--- Day 22: Monkey Market
local M = {}

local function evolve(secret)
    local mix = secret * 64
    secret = (secret ~ mix) % 16777216
    mix = math.floor(secret / 32)
    secret = (secret ~ mix) % 16777216
    mix = secret * 2048
    secret = (secret ~ mix) % 16777216
    return secret
end

function M.part1(input)
    local sum = 0
    for line in input:gmatch("[^\n]+") do
        if line ~= "" then
            local secret = tonumber(line)
            for i = 1, 2000 do
                secret = evolve(secret)
            end
            sum = sum + secret
        end
    end
    return sum
end

function M.part2(input)
    local seq_to_bananas = {}
    for line in input:gmatch("[^\n]+") do
        if line ~= "" then
            local secret = tonumber(line)
            local seen = {}
            local prev_price = secret % 10
            local changes = {}
            for i = 1, 2000 do
                secret = evolve(secret)
                local price = secret % 10
                local change = price - prev_price
                table.insert(changes, change)
                if #changes >= 4 then
                    local seq = changes[#changes-3] .. "," .. changes[#changes-2] .. "," .. changes[#changes-1] .. "," .. changes[#changes]
                    if not seen[seq] then
                        seen[seq] = true
                        seq_to_bananas[seq] = (seq_to_bananas[seq] or 0) + price
                    end
                end
                prev_price = price
            end
        end
    end
    local max_bananas = 0
    for _, bananas in pairs(seq_to_bananas) do
        if bananas > max_bananas then
            max_bananas = bananas
        end
    end
    return max_bananas
end

return M
