--- @title Day 20: Jurassic Jigsaw ---
local M = {}
local util = require("util")

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS FOR TILE MANIPULATION
--------------------------------------------------------------------------------

--- @function: Reverses a string.
local function reverse(s)
    return s:reverse()
end

--- @function: Rotates a grid (table of strings) 90 degrees clockwise.
local function rotate_grid(grid)
    local new_grid = {}
    local size = #grid
    for i = 1, size do
        local new_row = ""
        for j = size, 1, -1 do
            new_row = new_row .. grid[j]:sub(i, i)
        end
        new_grid[i] = new_row
    end
    return new_grid
end

--- @function: Flips a grid horizontally.
local function flip_grid_horizontal(grid)
    local new_grid = {}
    for i, row in ipairs(grid) do
        new_grid[i] = reverse(row)
    end
    return new_grid
end

--- @function: Gets the 4 borders of a tile's grid: [top, right, bottom, left].
local function get_borders(grid)
    local size = #grid
    local top = grid[1]
    local bottom = grid[size]
    local left = ""
    local right = ""
    for i = 1, size do
        left = left .. grid[i]:sub(1, 1)
        right = right .. grid[i]:sub(size, size)
    end
    return { top, right, bottom, left }
end
--- @function: Parses a comma-separated string of numbers into a Lua table.
--- @param input string
--- @return table
--- @return table
local function parse_input(input)
    input = input:gsub("\r", "")
    local tiles = {}
    local border_to_ids = {}

    for id_str, grid_str in input:gmatch("Tile (%d+):\n(.-)\n\n") do
        local id = tonumber(id_str)
        local grid = {}
        for line in grid_str:gmatch("[^\n]+") do
            table.insert(grid, line)
        end

        tiles[id] = { id = id, grid = grid }

        -- Store all 8 border variations for easy lookup later
        local borders = get_borders(grid)
        for _, border in ipairs(borders) do
            border_to_ids[border] = border_to_ids[border] or {}
            table.insert(border_to_ids[border], id)
            local rev_border = reverse(border)
            border_to_ids[rev_border] = border_to_ids[rev_border] or {}
            table.insert(border_to_ids[rev_border], id)
        end
    end
    return tiles, border_to_ids
end


--- @description: Finds the product of all corner tiles
--- @param input string: the puzzle input
--- @return number: the product
function M.part1(input)
    local tiles, border_to_ids = parse_input(input)
    local corners = {}
    local product = 1

    for id, tile in pairs(tiles) do
        local neighbor_count = 0
        local borders = get_borders(tile.grid)
        for _, border in ipairs(borders) do
            if #border_to_ids[border] > 1 then
                neighbor_count = neighbor_count + 1
            end
        end
        -- A corner tile has exactly 2 neighbors.
        if neighbor_count == 2 then
            table.insert(corners, id)
            product = product * id
        end
    end
    return product
end


--- @description: Finds the total number of hashes in the image
--- @param input string: the puzzle input
--- @return number: the total number of hashes
function M.part2(input)
    local tiles, border_to_ids = parse_input(input)

    -- Step 1: Find a corner tile to start with
    local start_id
    for id, tile in pairs(tiles) do
        local neighbor_count = 0
        for _, border in ipairs(get_borders(tile.grid)) do
            if #border_to_ids[border] > 1 then neighbor_count = neighbor_count + 1 end
        end
        if neighbor_count == 2 then
            start_id = id
            break
        end
    end

    -- Step 2: Orient the starting corner tile to be the top-left piece
    local top_left_tile = tiles[start_id]
    for _ = 1, 4 do -- Try rotations
        local borders = get_borders(top_left_tile.grid)
        -- The top and left borders must be the ones with no neighbors
        if #border_to_ids[borders[1]] == 1 and #border_to_ids[borders[4]] == 1 then break end
        top_left_tile.grid = rotate_grid(top_left_tile.grid)
    end
    -- It could also be flipped
    local borders = get_borders(top_left_tile.grid)
    if not (#border_to_ids[borders[1]] == 1 and #border_to_ids[borders[4]] == 1) then
        top_left_tile.grid = flip_grid_horizontal(top_left_tile.grid)
        for _ = 1, 4 do -- Try rotations again after flip
            borders = get_borders(top_left_tile.grid)
            if #border_to_ids[borders[1]] == 1 and #border_to_ids[borders[4]] == 1 then break end
            top_left_tile.grid = rotate_grid(top_left_tile.grid)
        end
    end

    -- Step 3: Assemble the entire grid of tiles
    local image_size = math.sqrt(#util.keyset(tiles))
    local image_grid = {}
    local used_ids = { [start_id] = true }
    image_grid[1] = { [1] = top_left_tile }

    for r = 1, image_size do
        for c = 1, image_size do
            if r == 1 and c == 1 then goto continue end

            local tile_to_match
            local border_to_match
            local border_side_to_match -- Which side on the NEW tile needs to match (e.g., left=4)
            
            if c > 1 then
                -- Match the tile to the left
                tile_to_match = image_grid[r][c - 1]
                border_to_match = get_borders(tile_to_match.grid)[2] -- Right border
                border_side_to_match = 4 -- Left
            else
                -- Match the tile above
                tile_to_match = image_grid[r - 1][c]
                border_to_match = get_borders(tile_to_match.grid)[3] -- Bottom border
                border_side_to_match = 1 -- Top
            end

            -- Find the neighbor tile
            local neighbor_id
            for _, id in ipairs(border_to_ids[border_to_match]) do
                if not used_ids[id] then
                    neighbor_id = id
                    break
                end
            end
            used_ids[neighbor_id] = true
            local neighbor_tile = tiles[neighbor_id]

            -- Orient the neighbor tile correctly
            local found = false
            for _ = 1, 2 do -- Normal and Flipped
                for _ = 1, 4 do -- 4 Rotations
                    if get_borders(neighbor_tile.grid)[border_side_to_match] == border_to_match then
                        found = true
                        break
                    end
                    neighbor_tile.grid = rotate_grid(neighbor_tile.grid)
                end
                if found then break end
                neighbor_tile.grid = flip_grid_horizontal(neighbor_tile.grid)
            end
            
            if not image_grid[r] then image_grid[r] = {} end
            image_grid[r][c] = neighbor_tile
            ::continue::
        end
    end

    -- Step 4: Create the final image by stitching tiles without borders
    local final_image = {}
    for r = 1, image_size do
        for inner_r = 2, 9 do -- 8 rows per tile (skip border)
            local line = ""
            for c = 1, image_size do
                line = line .. image_grid[r][c].grid[inner_r]:sub(2, 9)
            end
            table.insert(final_image, line)
        end
    end

    -- Step 5: Find and mark sea monsters
    local monster_pattern = {
        "                  # ",
        "#    ##    ##    ###",
        " #  #  #  #  #  #   ",
    }
    local monster_coords = {}
    for r, line in ipairs(monster_pattern) do
        for c = 1, #line do
            if line:sub(c, c) == "#" then table.insert(monster_coords, {r, c}) end
        end
    end
    local monster_height = #monster_pattern
    local monster_width = #monster_pattern[1]
    
    local monsters_found = 0
    local is_monster_part = {} -- A grid to mark monster parts
    
    for _ = 1, 2 do -- Normal and Flipped
        for _ = 1, 4 do -- 4 Rotations
            if monsters_found > 0 then break end
            -- Search for monsters in this orientation
            for r = 1, #final_image - monster_height + 1 do
                for c = 1, #final_image[1] - monster_width + 1 do
                    local is_match = true
                    for _, coord in ipairs(monster_coords) do
                        if final_image[r + coord[1] - 1]:sub(c + coord[2] - 1, c + coord[2] - 1) ~= "#" then
                            is_match = false
                            break
                        end
                    end
                    if is_match then
                        monsters_found = monsters_found + 1
                        -- Mark the parts
                        for _, coord in ipairs(monster_coords) do
                            local mark_r, mark_c = r + coord[1] - 1, c + coord[2] - 1
                            if not is_monster_part[mark_r] then is_monster_part[mark_r] = {} end
                            is_monster_part[mark_r][mark_c] = true
                        end
                    end
                end
            end
            if monsters_found > 0 then break end
            final_image = rotate_grid(final_image)
        end
        if monsters_found > 0 then break end
        final_image = flip_grid_horizontal(final_image)
    end

    -- Step 6: Count the remaining '#'
    local total_hashes = 0
    for _, line in ipairs(final_image) do
        total_hashes = total_hashes + #line:gsub("[^#]", "")
    end

    return total_hashes - (monsters_found * #monster_coords)
end



return M
