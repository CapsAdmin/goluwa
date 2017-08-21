local loaded = {}

function hyphenate_word(language, word)
	if not loaded[language] then
		local data = runfile("lua/examples/hypher_"..language..".lua")

		local tree = {
			_points = {}
		}

		for size, pattern in pairs(data.patterns) do
			for i = 1, #pattern, size do
				local str = pattern:sub(i, i + size)
				local chars = str:gsub("%d", ""):utotable()
				local points = str:gsub("[^%d]", ""):utotable()

				local t = tree

				for _, char in ipairs(chars) do
					local code_point = utf8.byte(char)

					if not t[code_point] then
						t[code_point] = {}
					end

					t = t[code_point]
				end

				t._points = points
			end
		end

		loaded[language] = {
			tree = tree,
			left_min = data.leftmin,
			right_min = data.rightmin,
		}
	end

	local data = loaded[language]

	-- \u00AD
	if word:find("\xC2\xAD") then return {word} end

	word = "_" .. word .. "_"

	local characterPoints = {}
	local points = {}
	local characters = utf8.totable(utf8.lower(word))
	local originalCharacters = utf8.totable(word)
	local wordLength = #characters

	for i = 1, wordLength do
		points[i] = 0
		characterPoints[i] = characters[i]:ubyte(1) or 0
	end

	for i = 1, wordLength do
		local node = data.tree
		for j = i-1, wordLength do
			node = node[characterPoints[j]]

			if not node then break end

			local nodePoints = node._points
			if nodePoints then
				for k = 0, #nodePoints-1 do
					points[i + k] = math.max(points[i + k] or 0, nodePoints[k+1])
				end
			end
		end
	end

	local result = {""}

	for i = 2, wordLength - 1 do
		if i-1 > data.left_min and i-1 < (wordLength - data.right_min) and points[i] % 2 ~= 0 then
			table.insert(result, originalCharacters[i])
		else
			result[#result] = result[#result] .. originalCharacters[i]
		end
	end

	return result
end

local linebreak = {}

local infinity = 0xDEADBEEFCAFEBABE

local function bond(width, stretch, shrink)
	return {
		type = "bond",
		width = width,
		stretch = stretch,
		shrink = shrink
	}
end

local function box(width, value)
	return {
		type = "box",
		width = width,
		value = value
	}
end

local function damage(width, damage, flagged)
	return {
		type = "damage",
		width = width,
		damage = damage,
		flagged = flagged
	}
end

linebreak.debug = false

local function dump_node(node, index)
	if node.type == "box" then
		log(node.value)
	elseif node.type == "damage" then
		log(">", node.damage, "<")
	elseif node.type == "bond" then
		--log("[", node.type, "<", node.stretch, ">,>",node.shrink,"<]")
		log(" ~ ")
	end
end

local function dump_active_nodes(active_nodes, nodes)
	logn(#active_nodes, " active nodes:")
	for index, data in ipairs(active_nodes) do
		local node = nodes[data.node_index]
		log("\t[", index, "] ", node.type, ": ") dump_node(node) logn()
		logn("\t\tclass: ", data.fitness_class)
		logn("\t\tratio: ", data.ratio)
		logn("\t\ttotal damage: ", data.total_damage)
	end
	logn()
end

local function dump_nodes(nodes)
	logn(#nodes, " nodes:")
	local bonds = 0
	local boxes = 0
	local damages = 0
	for index, node in ipairs(nodes) do
		dump_node(node, index)
	end
	logn()
end

function linebreak.linebreak(text, type, line_lengths, options)
	options = options or {}

	options.tolerance = options.tolerance or 2

	options.damage = options.damage or {}
	options.damage.line = options.damage.line or 10
	options.damage.flagged = options.damage.flagged or 1000
	options.damage.fitness = options.damage.fitness or 3000
	options.damage.hyphen = options.damage.hyphen or 100

	options.space = options.space or {}
	options.space.width = options.space.width or 1
	options.space.stretch = options.space.stretch or 6
	options.space.shrink = options.space.shrink or 5

    local space_width = gfx.GetTextSize(" ")
	local space_stretch = (space_width * options.space.width) / options.space.stretch
	local space_shrink = (space_width * options.space.width) / options.space.shrink

	local nodes = {}
	local words = text:split(" ")

	if type == "center" then
		 -- Although not specified in the Knuth and Plass whitepaper, this box is necessary
		-- to keep the bond from disappearing.
		table.insert(nodes, box(0, ""))
		table.insert(nodes, bond(0, 12, 0))
	end

	for index, word in ipairs(words) do
		local hyphenated = hyphenate_word("en", word)
		if hyphenated[2] and #word > 4 then
			for partIndex, part in ipairs(hyphenated) do
				table.insert(nodes, box(gfx.GetTextSize(part), part))
				if partIndex ~= #hyphenated then
					local width = gfx.GetTextSize("-")
					table.insert(nodes, damage(width*2, options.damage.hyphen, 1))
				end
			end
		else
			table.insert(nodes, box(gfx.GetTextSize(word), word))
		end

		if type == "center" then
			if index == #words then
				table.insert(nodes, bond(0, 12, 0))
				table.insert(nodes, damage(0, -infinity, 0))
			else
				table.insert(nodes, bond(0, 12, 0))
				table.insert(nodes, damage(0, 0, 0))
				table.insert(nodes, bond(space_width, -24, 0))
				table.insert(nodes, box(0, ""))
				table.insert(nodes, damage(0, infinity, 0))
				table.insert(nodes, bond(0, 12, 0))
			end
		elseif type == "justify" then
			if index == #words then
				table.insert(nodes, bond(0, infinity, 0))
				table.insert(nodes, damage(0, -infinity, 1))
			else
				table.insert(nodes, bond(space_width, space_stretch, space_shrink))
			end
		elseif type == "left" then
			if index == #words then
				table.insert(nodes, bond(0, infinity, 0))
				table.insert(nodes, damage(0, -infinity, 1))
			else
				table.insert(nodes, bond(0, 12, 0))
				table.insert(nodes, damage(0, 0, 0))
				table.insert(nodes, bond(space_width, -12, 0))
			end
		end
	end

	if linebreak.debug then
		logn("====================")
		dump_nodes(nodes)
	end

	local active_nodes = {}

	local sum = {
		width = 0,
		stretch = 0,
		shrink = 0,
	}

	-- insert the first node
	table.insert(active_nodes, {
		node_index = 1,
		total_damage = 0,
		ratio = 0,
		line = 1,
		fitness_class = 1,
		totals = {
			width = 0,
			stretch = 0,
			shrink = 0
		},
		previous_candidate = nil,
	})

	if linebreak.debug then
		dump_active_nodes(active_nodes, nodes)
	end

	for index, node in ipairs(nodes) do
		local prev_node = nodes[index - 1] or node

		if node.type == "box" or node.type == "bond" then
			sum.width = sum.width + node.width
		end

		if node.type == "bond" then
			sum.stretch = sum.stretch + node.stretch
			sum.shrink = sum.shrink + node.shrink
		end

		if (node.type == "damage" and node.damage ~= infinity) or (node.type == "bond" and prev_node.type == "box") then
			local active = active_nodes[1]

			for i = 1, 500 do if not active then break end

				local candidates = {
					{total_damage = math.huge},
					{total_damage = math.huge},
					{total_damage = math.huge},
					{total_damage = math.huge},
				}

				-- The inner loop iterates through all the active nodes with line < currentLine and then
				-- breaks out to insert the new active node candidates before looking at the next active
				-- nodes for the next lines. The result of this is that the active node list is always
				-- sorted by line number.

				for i = 1, 500 do if not active then break end

					local current_line = active.line
					local ratio = 0

					local width = sum.width - active.totals.width

					-- If the current line index is within the list of line_lengths, use it, otherwise use
					-- the last line length of the list.
					local line_length = line_lengths[current_line] or line_lengths[#line_lengths]

					if node.type == "damage" then
						width = width + node.width
					end

					if width < line_length then
						-- Calculate the stretch ratio
						local stretch = sum.stretch - active.totals.stretch

						if stretch > 0 then
							ratio = (line_length - width) / stretch
						else
							ratio = infinity
						end
					elseif width > line_length then
						-- Calculate the shrink ratio
						local shrink = sum.shrink - active.totals.shrink

						if shrink > 0 then
							ratio = (line_length - width) / shrink
						else
							ratio = infinity
						end
					end

	--				if ratio <= -1 then ratio = 0 end

					-- Deactive nodes when the distance between the current active node and the
					-- current node becomes too large (i.e. it exceeds the stretch limit and the stretch
					-- ratio becomes negative) or when the current node is a forced break (i.e. the end
					-- of the paragraph when we want to remove all active nodes, but possibly have a final
					-- candidate active node---if the paragraph can be set using the given tolerance value.)
					if (ratio <= -1 and math.abs(ratio) >= options.tolerance) or (node.type == "damage" and node.damage == -infinity) then
						if linebreak.debug then
							logn("REMOVING NODE:")
							logn("[", index, "] ", node.type)
							logn("BEFORE:")
							dump_active_nodes(active_nodes, nodes)
						end

						for i, v in ipairs(active_nodes) do
							if v == active then
								v.removed_index = i
								table.remove(active_nodes, i)
								break
							end
						end

						if linebreak.debug then
							logn("AFTER:")
							dump_active_nodes(active_nodes, nodes)
						end
					end

					-- If the ratio is within the valid range of -1 <= ratio <= tolerance calculate the
					-- total damage and record a candidate active node.
					if ratio >= -1 and ratio <= options.tolerance then
						local badness = 100 * math.pow(math.abs(ratio), 3)
						local total_damage

						-- Positive damage
						if node.type == "damage" and node.damage >= 0 then
							total_damage = math.pow(options.damage.line + badness, 2) + math.pow(node.damage, 2)
						-- Negative damage but not a forced break
						elseif node.type == "damage" and node.damage ~= -infinity then
							total_damage = math.pow(options.damage.line + badness, 2) - math.pow(node.damage, 2)
						-- All other cases
						else
							total_damage = math.pow(options.damage.line + badness, 2)
						end

						if node.type == "damage" and nodes[active.node_index].type == "damage" then
							total_damage = total_damage + options.damage.flagged * node.flagged * nodes[active.node_index].flagged
						end

						local current_class

						-- Calculate the fitness class for this candidate active node.
						if ratio <= -0.5 then
							current_class = 1
						elseif ratio <= 0.5 then
							current_class = 2
						elseif ratio <= 1 then
							current_class = 3
						else
							current_class = 4
						end

						-- Add a fitness damage to the total damage if the fitness classes of two adjacent lines
						-- differ too much.
						if math.abs((current_class-1) - (active.fitness_class-1)) > 1 then
							total_damage = total_damage + options.damage.fitness
						end

						-- Add the total damage of the active node to get the total damage of this candidate node.
						total_damage = total_damage + active.total_damage

						-- Only store the best candidate for each fitness class
						if total_damage <= candidates[current_class].total_damage then
							candidates[current_class] = {
								active = active,
								total_damage = total_damage,
								ratio = ratio
							}
						end
					end

					if active.removed_index then
						active = active_nodes[active.removed_index]
					else
						local temp
						for i,v in ipairs(active_nodes) do
							if v == active then
								temp = active_nodes[i+1]
								break
							end
						end
						active = temp
					end

					if linebreak.debug then
						logn("ACTIVE NODE:")
						if active then
							logn(i, " [", active.node_index, "] ", active)
						else
							logn(i, " nil")
						end
					end

					-- Stop iterating through active nodes to insert new candidate active nodes in the active list
					-- before moving on to the active nodes for the next line.
					-- TODO: The Knuth and Plass paper suggests a conditional for currentLine < j0. This means paragraphs
					-- with identical line lengths will not be sorted by line number. Find out if that is a desirable outcome.
					-- For now I left this out, as it only adds minimal overhead to the algorithm and keeping the active node
					-- list sorted has a higher priority.
					if active and active.line >= current_line then
						break
					end
				end

				-- Add width, stretch and shrink values from the current
				-- break point up to the next box or forced damage.

				local result = {
					width = sum.width,
					stretch = sum.stretch,
					shrink = sum.shrink,
				}

				for i = index, #nodes do
					local node = nodes[i]

					if node.type == "bond" then
						result.width = result.width + node.width
						result.stretch = result.stretch + node.stretch
						result.shrink = result.shrink + node.shrink
					elseif node.type == "box" or (node.type == "damage" and node.damage == -infinity and i > index) then
						break
					end
				end

				for fitness_class, candidate in ipairs(candidates) do
					if candidate.total_damage < math.huge then
						local new_node = {
							node_index = index,
							total_damage = candidate.total_damage,
							ratio = candidate.ratio,
							line = candidate.active.line + 1,
							fitness_class = fitness_class,
							totals = result,
							previous_candidate = candidate.active
						}
						if active then
							for i, v in ipairs(active_nodes) do
								if v == active then
									table.insert(active_nodes, i, new_node)
									break
								end
							end
						else
							table.insert(active_nodes, new_node)
						end
					end
				end
			end
		end
	end

	local breaks = {}

	if active_nodes[1] then
		local temp = {total_damage = math.huge}

		-- Find the best active node (the one with the least total damage.)
		for i, node in ipairs(active_nodes) do
			if node.total_damage < temp.total_damage then
				temp = node
			end
		end

		while temp do
			table.insert(breaks, {
				node_index = temp.node_index,
				ratio = temp.ratio,
			})
			temp = temp.previous_candidate
		end

		breaks = table.reverse(breaks)
	end

	local max_length = math.max(0, unpack(line_lengths))

	if linebreak.debug or true then
		local h = select(2, gfx.GetTextSize("|"))
		local y = 0
		for i = 2, #breaks do
			local line_length = line_lengths[i-1] or line_lengths[#line_lengths]
			local x = 0
			if options.center then
				x = (max_length - line_length) / 2
			end
			gfx.DrawRect(x, y, line_length, h, gfx, 1,0,0,0.25)
			y = y + h
		end
	end

	local lines = {}
	local line_start = 1
	local y = 0

	-- Iterate through the line breaks, and split the nodes at the
	-- correct point.
	for i = 2, #breaks do
		local break_ = breaks[i]

		local node_index = break_.node_index
		for j = line_start, #nodes do
			local node = nodes[j]
			if not node then break end
			-- After a line break, we skip any nodes unless they are boxes or forced breaks.
			if node.type == "box" or (node.type == "damage" and node.damage == -infinity) then
				line_start = j
				break
			end
		end

		table.insert(lines, {ratio = break_.ratio, nodes = table.slice(nodes, line_start, node_index)})
		line_start = node_index
	end

	for lineIndex, line in ipairs(lines) do
		local x = 0
		local line_length = line_lengths[lineIndex] or line_lengths[#line_lengths]

		if options.center then
			x = (max_length - line_length) / 2
		end

		for index, node in ipairs(line.nodes) do
			if node.type == "box" then
				gfx.DrawText(node.value, x, y)
				x = x + node.width
			elseif node.type == "bond" then
				x = x + node.width + (line.ratio * (line.ratio < 0 and node.shrink or node.stretch))
			elseif node.type == "damage" and node.damage == options.damage.hyphen and index == #line.nodes then
				gfx.DrawText("-", x, y)
			end
		end
		-- move lower to draw the next line
		y = y + select(2, gfx.GetTextSize("|"))
	end
end

local r = {}
local radius = 200

for j = 0, (radius * 2) - 1, 5 do
	local v = math.round(math.sqrt((radius - j / 2) * (2 * j)))
	if v > 30 then
		table.insert(r, v)
	end
end

local text = "In olden times when wishing still helped one, there lived a king whose daughters were all beautiful; and the youngest was so beautiful that the sun itself, which has seen so much, was astonished whenever it shone in her face. Close by the king's castle lay a great dark forest, and under an old limetree in the forest was a well, and when the day was very warm, the king's child went out to the forest and sat down by the fountain; and when she was bored she took a golden ball, and threw it up on high and caught it; and this ball was her favorite plaything."
--text = text:rep(4) .. "!!!!"
--text = string.randomwords(4) .. " somehow"

local font = fonts.CreateFont({path = "fonts/vera.ttf", size = 20})
gfx.SetFont(font)

function goluwa.PreDrawGUI()
	gfx.SetFont(font)
	local x = gfx.GetMousePosition()
	gfx.DrawLine(x, 0, x, select(2, render2d.GetSize()))
	--print(x)
	--x = 53
	--linebreak.linebreak(text, "justify", {x}, {tolerance = 3})
	--linebreak.linebreak(text, "justify", {x}, {tolerance = 4})
	--linebreak.linebreak(text, "center", {350}, {tolerance = 2})
	linebreak.linebreak(text, "justify", {350, 350, 350, 200, 200, 200, 200, 200, 200, 200, 350, 350}, {tolerance = 15})
	--linebreak.linebreak(text, "justify", {50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550}, {tolerance = 3, center = true})
	--linebreak.linebreak(text, "justify", r, {tolerance = 20, center = true})
end