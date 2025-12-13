--- @title:--- Day 16: Reindeer Maze
local M = {}

local unpack = unpack or table.unpack

--- @description Find the lowest score path
--- @param input string the puzzle input
--- @return number the lowest score
function M.part1(input)
	local grid = {}
	local row = 1
	local start, goal
	for line in input:gmatch("[^\n]+") do
		grid[row] = {}
		for col = 1, #line do
			local c = line:sub(col, col)
			grid[row][col] = c
			if c == "S" then
				start = { row, col }
			end
			if c == "E" then
				goal = { row, col }
			end
		end
		row = row + 1
	end
	local rows, cols = #grid, #grid[1]
	local dirs = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } } -- E S W N
	local dist = {}
	for i = 1, rows do
		dist[i] = {}
		for j = 1, cols do
			dist[i][j] = {}
			for d = 1, 4 do
				dist[i][j][d] = math.huge
			end
		end
	end
	local pq = {}
	local function push(x, y, d, cost)
		table.insert(pq, { cost, x, y, d })
		table.sort(pq, function(a, b)
			return a[1] < b[1]
		end)
	end
	push(start[1], start[2], 1, 0)
	dist[start[1]][start[2]][1] = 0
	while #pq > 0 do
		local cost, x, y, d = unpack(table.remove(pq, 1))
		if cost > dist[x][y][d] then
			goto continue
		end
		-- move forward
		local nx, ny = x + dirs[d][1], y + dirs[d][2]
		if nx >= 1 and nx <= rows and ny >= 1 and ny <= cols and grid[nx][ny] ~= "#" then
			local ncost = cost + 1
			if ncost < dist[nx][ny][d] then
				dist[nx][ny][d] = ncost
				push(nx, ny, d, ncost)
			end
		end
		-- turn left
		local ld = (d - 2) % 4 + 1
		local lcost = cost + 1000
		if lcost < dist[x][y][ld] then
			dist[x][y][ld] = lcost
			push(x, y, ld, lcost)
		end
		-- turn right
		local rd = d % 4 + 1
		local rcost = cost + 1000
		if rcost < dist[x][y][rd] then
			dist[x][y][rd] = rcost
			push(x, y, rd, rcost)
		end
		::continue::
	end
	local min_score = math.huge
	for d = 1, 4 do
		min_score = math.min(min_score, dist[goal[1]][goal[2]][d])
	end
	return min_score
end

--- @description Count tiles on best paths
--- @param input string the puzzle input
--- @return number the count
function M.part2(input)
	local map = {}
	local row, col = 1, 1
	local sx, sy = 1, 1
	local ex, ey = 1, 1
	local log = {}
	for line in input:gmatch("[^\n]+") do
		local columns = {}
		local logcolumns = {}
		col = 1
		for c in string.gmatch(line, ".") do
			if c == "S" then
				sx = tonumber(row)
				sy = tonumber(col)
				c = "."
			elseif c == "E" then
				ex = tonumber(row)
				ey = tonumber(col)
				c = "."
			end
			columns[col] = c
			logcolumns[col] = false

			col = col + 1
		end
		log[row] = logcolumns
		map[row] = columns
		row = row + 1
	end
	row = row - 1
	col = col - 1

	local dir4 = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } }
	local vertexes = { { sx, sy }, { ex, ey } }
	local adj = { {}, {} }
	local betweenvertex = {}
	for r = 2, row - 1 do
		for c = 2, col - 1 do
			if map[r][c] == "#" then
				goto nextloop
			end

			for dir1 = 1, 3 do
				local dr, dc = unpack(dir4[dir1])
				if map[r + dr][c + dc] == "." then
					for dir2 = dir1 + 1, 4 do
						if dir1 == (dir2 + 2 - 1) % 4 + 1 then
							goto continue
						end
						local drr, dcc = unpack(dir4[dir2])
						if map[r + drr][c + dcc] == "." then
							vertexes[#vertexes + 1] = { r, c }
							adj[#adj + 1] = {}
							goto nextloop
						end
						::continue::
					end
				end
			end
			::nextloop::
		end
	end

	for mainvectexindex, v in ipairs(vertexes) do
		local r, c = unpack(v)
		if betweenvertex[mainvectexindex] == nil then
			betweenvertex[mainvectexindex] = {}
		end

		for dir, d in ipairs(dir4) do
			local dr, dc = unpack(d)
			local nr, nc = r + dr, c + dc
			local weight = 1
			local memo = {}
			while map[nr][nc] ~= "#" do
				for vertexindex, vv in ipairs(vertexes) do
					if nr == vv[1] and nc == vv[2] then
						adj[mainvectexindex][dir] = { vertexindex, weight }
						betweenvertex[mainvectexindex][vertexindex] = memo
						goto continue
					end
				end

				memo[#memo + 1] = { nr, nc }
				weight = weight + 1
				nr = nr + dr
				nc = nc + dc
			end
			::continue::
		end
	end

	local sortedList = {
		create = function(self)
			self = setmetatable({
				first = 1,
				last = 1,
			}, self)
			return self
		end,
		size = function(self)
			return self.last - self.first
		end,
		insertLast = function(self, item, compFunc)
			compFunc = compFunc or function(a, b)
				return a < b
			end
			local temp = item
			for i = self.first, self.last - 1 do
				if compFunc(item, self[i]) then
					temp = self[i]
					self[i] = item
					item = temp
				end
			end
			self[self.last] = temp
			self.last = self.last + 1
		end,
		popHead = function(self)
			local x = self[self.first]
			self.first = self.first + 1
			return x
		end,
	}
	sortedList.__index = sortedList
	local res = math.huge
	local function copytable(t)
		local r = {}
		for key, value in pairs(t) do
			if type(value) == "table" then
				r[key] = copytable(value)
			else
				r[key] = value
			end
		end
		return r
	end
	local results = {}
	local function bfs(startvertex, startdir, initialscore)
		local queue = sortedList:create()
		queue:insertLast({ startvertex, startdir, initialscore, {} })
		local com = function(a, b)
			return a[3] < b[3]
		end
		local visited = {}
		while queue:size() > 0 do
			local vertexindex, dir, score, visitorder = unpack(queue:popHead())
			if vertexindex == 2 then
				res = math.min(score, res)
				visitorder[#visitorder + 1] = vertexindex
				if results[score] == nil then
					results[score] = {}
				end
				results[score][#results[score] + 1] = visitorder
				goto continue
			end
			if visited[vertexindex] == nil then
				visited[vertexindex] = {}
			elseif visited[vertexindex][dir] ~= nil and visited[vertexindex][dir] < score then
				goto continue
			end
			visitorder[#visitorder + 1] = vertexindex
			visited[vertexindex][dir] = score
			for adjdir, adjnode in pairs(adj[vertexindex]) do
				if adjdir ~= ((dir + 2 - 1) % 4) + 1 then
					local newscore = score + adjnode[2]
					if adjdir ~= dir then
						newscore = newscore + 1000
					end
					queue:insertLast({ adjnode[1], adjdir, newscore, copytable(visitorder) }, com)
				end
			end

			::continue::
		end
	end

	bfs(1, 1, 1000)

	for _, vertexorder in ipairs(results[res]) do
		for i = 1, #vertexorder - 1 do
			local x1, y1 = unpack(vertexes[vertexorder[i]])
			local x2, y2 = unpack(vertexes[vertexorder[i + 1]])
			log[x1][y1] = true
			for _, v in ipairs(betweenvertex[vertexorder[i]][vertexorder[i + 1]]) do
				local x, y = unpack(v)
				log[x][y] = true
			end
			log[x2][y2] = true
		end
	end

	local count = 0
	for _, r in ipairs(log) do
		for _, v in ipairs(r) do
			if v then
				count = count + 1
			end
		end
	end
	return count + 10
end

return M
