do
	local Hypher = {}
	Hypher.__index = Hypher

	Hypher.en = runfile("lua/examples/hypher_en.lua")

	function CreateHypher(language)
		language = Hypher[language]
		local self = setmetatable({}, Hypher)
		self.leftMin = language.leftmin
		self.rightMin = language.rightmin
		self:createTrie(language.patterns)
		self.exceptions = {}

		-- CHECK ME
		if language.exceptions then
			for exception in language["exceptions"]:gmatch(",%s") do
				local hyphenationMarker = exception:find("=") and "=" or "-"
				self.exceptions[exception:replace(hyphenationMarker, "")] = exception:split(hyphenationMarker)
			end
		end
		-- CHECK ME

		return self
	end

	function Hypher:createTrie(patterns)
		local tree = {
			_points = {}
		}

		for size, pattern in pairs(patterns) do
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
		self.trie = tree
	end

	function Hypher:hyphenate(word)
		if self.exceptions and self.exceptions[word] then
			return self.exceptions[word]
		end
		-- \u00AD
		if word:find("\xC2\xAD") then
			return {word}
		end

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
			local node = self.trie
			for j = i-1, wordLength do
				node = node[characterPoints[j]]

				if not node then break end

				local nodePoints = node._points
				if nodePoints then
					for k = 0, #nodePoints-1 do
						points[i + k] = math.max(points[i + k], nodePoints[k+1])
					end
				end
			end
		end

		local result = {""}

		for i = 2, wordLength - 1 do
			if i-1 > self.leftMin and i-1 < (wordLength - self.rightMin) and points[i] % 2 ~= 0 then
				table.insert(result, originalCharacters[i])
			else
				result[#result] = result[#result] .. originalCharacters[i]
			end
		end

		return result
	end
end

local linebreak = {}

local infinity = 10000

local h = CreateHypher("en")
local hyphenPenalty = 100

local function breakpoint(position, demerits, ratio, line, fitness_class, totals, previous)
	return {
		position = position,
		demerits = demerits,
		ratio = ratio,
		line = line,
		fitness_class = fitness_class,
		totals = totals or {
			width = 0,
			stretch = 0,
			shrink = 0
		},
		previous = previous
	}
end

function linebreak.linebreak(text, type, line_lengths, options)
	options = options or {}
	options.tolerance = options.tolerance or 2

	options.demerits = options.demerits or {}
	options.demerits.line = options.demerits.line or 10
	options.demerits.flagged = options.demerits.flagged or 1000
	options.demerits.fitness = options.demerits.fitness or 3000

	options.space = options.space or {}
	options.space.width = options.space.width or 1
	options.space.stretch = options.space.stretch or 6
	options.space.shrink = options.space.shrink or 5

    local spaceWidth = gfx.GetTextSize(" ")
	local spaceStretch = (spaceWidth * options.space.width) / options.space.stretch
	local spaceShrink = (spaceWidth * options.space.width) / options.space.shrink

	local nodes = {}
	local words = text:split(" ")

	if type == "center" then
		 -- Although not specified in the Knuth and Plass whitepaper, this box is necessary
		-- to keep the glue from disappearing.
		table.insert(nodes, linebreak.box(0, ""))
		table.insert(nodes, linebreak.glue(0, 12, 0))
	end

	for index, word in ipairs(words) do
		local hyphenated = h:hyphenate(word)
		if hyphenated[2] and #word > 4 then
			for partIndex, part in ipairs(hyphenated) do
				table.insert(nodes, linebreak.box(gfx.GetTextSize(part), part))
				if partIndex ~= #hyphenated then
					table.insert(nodes, linebreak.penalty(gfx.GetTextSize("-")*3, hyphenPenalty, 1))
				end
			end
		else
			table.insert(nodes, linebreak.box(gfx.GetTextSize(word), word))
		end

		if type == "center" then
			if index == #words then
				table.insert(nodes, linebreak.glue(0, 12, 0))
				table.insert(nodes, linebreak.penalty(0, -infinity, 0))
			else
				table.insert(nodes, linebreak.glue(0, 12, 0))
				table.insert(nodes, linebreak.penalty(0, 0, 0))
				table.insert(nodes, linebreak.glue(spaceWidth, -24, 0))
				table.insert(nodes, linebreak.box(0, ""))
				table.insert(nodes, linebreak.penalty(0, infinity, 0))
				table.insert(nodes, linebreak.glue(0, 12, 0))
			end
		elseif type == "justify" then
			if index == #words then
				table.insert(nodes, linebreak.glue(0, infinity, 0))
				table.insert(nodes, linebreak.penalty(0, -infinity, 1))
			else
				table.insert(nodes, linebreak.glue(spaceWidth, spaceStretch, spaceShrink))
			end
		elseif type == "left" then
			if index == #words then
				table.insert(nodes, linebreak.glue(0, infinity, 0))
				table.insert(nodes, linebreak.penalty(0, -infinity, 1))
			else
				table.insert(nodes, linebreak.glue(0, 12, 0))
				table.insert(nodes, linebreak.penalty(0, 0, 0))
				table.insert(nodes, linebreak.glue(spaceWidth, -12, 0))
			end
		end
	end

	local active_nodes = {}

	local sum = {
		width = 0,
		stretch = 0,
		shrink = 0,
	}

	table.insert(active_nodes, breakpoint(1, 0, 0, 1, 1, nil, nil))

	for index, node in ipairs(nodes) do
		if node.type == "box" then
			sum.width = sum.width + node.width
		elseif node.type == "glue" then
			sum.width = sum.width + node.width
			sum.stretch = sum.stretch + node.stretch
			sum.shrink = sum.shrink + node.shrink
		end

		if (node.type == "penalty" and node.penalty ~= infinity) or (node.type == "glue" and index > 1 and nodes[index - 1].type == "box") then
			local active = active_nodes[1]

			-- The inner loop iterates through all the active nodes with line < currentLine and then
			-- breaks out to insert the new active node candidates before looking at the next active
			-- nodes for the next lines. The result of this is that the active node list is always
			-- sorted by line number.

			for i = 1, 500 do if not active then break end
				local candidates = {
					{demerits = math.huge},
					{demerits = math.huge},
					{demerits = math.huge},
					{demerits = math.huge},
				}

				--for i = 1, 500 do if not active then break end
					local current_line = active.line

					local ratio = 0

					local width = sum.width - active.totals.width

					-- If the current line index is within the list of line_lengths, use it, otherwise use
					-- the last line length of the list.
					local line_length = line_lengths[current_line] or line_lengths[#line_lengths]

					if nodes[index].type == "penalty" then
						width = width + nodes[index].width
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


					-- Deactive nodes when the distance between the current active node and the
					-- current node becomes too large (i.e. it exceeds the stretch limit and the stretch
					-- ratio becomes negative) or when the current node is a forced break (i.e. the end
					-- of the paragraph when we want to remove all active nodes, but possibly have a final
					-- candidate active node---if the paragraph can be set using the given tolerance value.)
					if ratio < -1 or (node.type == "penalty" and node.penalty == -infinity) then
						for i,v in ipairs(active_nodes) do
							if v == active then
								v.removed_index = i
								table.remove(active_nodes, i)
								break
							end
						end
					end

					-- If the ratio is within the valid range of -1 <= ratio <= tolerance calculate the
					-- total demerits and record a candidate active node.
					if -1 <= ratio and ratio <= options.tolerance then
						local badness = 100 * math.pow(math.abs(ratio), 3)
						local demerits

						-- Positive penalty
						if node.type == "penalty" and node.penalty >= 0 then
							demerits = math.pow(options.demerits.line + badness, 2) + math.pow(node.penalty, 2)
						-- Negative penalty but not a forced break
						elseif node.type == "penalty" and node.penalty ~= -infinity then
							demerits = math.pow(options.demerits.line + badness, 2) - math.pow(node.penalty, 2)
						-- All other cases
						else
							demerits = math.pow(options.demerits.line + badness, 2)
						end

						if node.type == "penalty" and nodes[active.position].type == "penalty" then
							demerits = demerits + options.demerits.flagged * node.flagged * nodes[active.position].flagged
						end

						local current_class

						-- Calculate the fitness class for this candidate active node.
						if ratio < -0.5 then
							current_class = 1
						elseif ratio <= 0.5 then
							current_class = 2
						elseif ratio <= 1 then
							current_class = 3
						else
							current_class = 4
						end

						-- Add a fitness penalty to the demerits if the fitness classes of two adjacent lines
						-- differ too much.
						if math.abs((current_class-1) - (active.fitness_class-1)) > 1 then
							demerits = demerits + options.demerits.fitness
						end

						-- Add the total demerits of the active node to get the total demerits of this candidate node.
						demerits = demerits + active.demerits

						-- Only store the best candidate for each fitness class
						if demerits < candidates[current_class].demerits then
							candidates[current_class] = {
								active = active,
								demerits = demerits,
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

					-- Stop iterating through active nodes to insert new candidate active nodes in the active list
					-- before moving on to the active nodes for the next line.
					-- TODO: The Knuth and Plass paper suggests a conditional for currentLine < j0. This means paragraphs
					-- with identical line lengths will not be sorted by line number. Find out if that is a desirable outcome.
					-- For now I left this out, as it only adds minimal overhead to the algorithm and keeping the active node
					-- list sorted has a higher priority.
					if active and active.line >= current_line then
						break
					end
				--end

				-- Add width, stretch and shrink values from the current
				-- break point up to the next box or forced penalty.

				local result = {
					width = sum.width,
					stretch = sum.stretch,
					shrink = sum.shrink,
				}

				for i = index, #nodes do
					local node = nodes[i]

					if node.type == "glue" then
						result.width = result.width + node.width
						result.stretch = result.stretch + node.stretch
						result.shrink = result.shrink + node.shrink
					elseif node.type == "box" or (node.type == "penalty" and node.penalty == -infinity and i > index) then
						break
					end
				end

				for fitness_class, candidate in ipairs(candidates) do
					if candidate.demerits < math.huge then
						local new_node = breakpoint(
							index,
							candidate.demerits,
							candidate.ratio,
							candidate.active.line + 1,
							fitness_class,
							result,
							candidate.active
						)
						if active then
							for i,v in ipairs(active_nodes) do
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
		local temp = {demerits = math.huge}

		-- Find the best active node (the one with the least total demerits.)
		for i, node in ipairs(active_nodes) do
			if node.demerits < temp.demerits then
				temp = node
			end
		end

		while temp do
			table.insert(breaks, {
				position = temp.position,
				ratio = temp.ratio,
			})
			temp = temp.previous
		end

		breaks = table.reverse(breaks)
	end

	local maxLength = math.max(0, unpack(line_lengths))

	do
		local h = select(2, gfx.GetTextSize("|"))
		local y = 0
		for i = 2, #breaks do
			local line_length = line_lengths[i-1] or line_lengths[#line_lengths]
			local x = 0
			if options.center then
				x = (maxLength - line_length) / 2
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

		local point = break_.position
		for j = line_start, #nodes do
			local node = nodes[j]
			if not node then break end
			-- After a line break, we skip any nodes unless they are boxes or forced breaks.
			if node.type == "box" or (node.type == "penalty" and node.penalty == -infinity) then
				line_start = j
				break
			end
		end

		table.insert(lines, {ratio = break_.ratio, nodes = table.slice(nodes, line_start, point), position = point})
		line_start = point
	end

	for lineIndex, line in ipairs(lines) do
		local x = 0
		local line_length = line_lengths[lineIndex] or line_lengths[#line_lengths]
		if options.center then
			x = x + (maxLength - line_length) / 2
		end

		for index, node in ipairs(line.nodes) do
			if node.type == "box" then
				gfx.DrawText(node.value, x, y)
				x = x + node.width
			elseif node.type == "glue" then
				x = x + node.width + line.ratio * (line.ratio < 0 and node.shrink or node.stretch)
			elseif node.type == "penalty" and node.penalty == hyphenPenalty and index == #line.nodes then
				gfx.DrawText("-", x, y)
			end
		end
		-- move lower to draw the next line
		y = y + select(2, gfx.GetTextSize("|"))
	end
end

function linebreak.glue(width, stretch, shrink)
	return {
		type = "glue",
		width = width,
		stretch = stretch,
		shrink = shrink
	}
end

function linebreak.box(width, value)
	return {
		type = "box",
		width = width,
		value = value
	}
end

function linebreak.penalty(width, penalty, flagged)
	return {
		type = "penalty",
		width = width,
		penalty = penalty,
		flagged = flagged
	}
end

local r = {}
local radius = 200

for j = 0, (radius * 2) - 1, 21 do
	local v = math.round(math.sqrt((radius - j / 2) * (8 * j)))
	if v > 30 then
		table.insert(r, v)
	end
end

table.print(r)

local text = "In olden times when wishing still helped one, there lived a king whose daughters were all beautiful; and the youngest was so beautiful that the sun itself, which has seen so much, was astonished whenever it shone in her face. Close by the king's castle lay a great dark forest, and under an old limetree in the forest was a well, and when the day was very warm, the king's child went out to the forest and sat down by the fountain; and when she was bored she took a golden ball, and threw it up on high and caught it; and this ball was her favorite plaything."
text = text:rep(2) .. "!!!!"

local font = fonts.CreateFont({path = "fonts/vera.ttf", size = 16})
gfx.SetFont(font)
--I"" align("justify", {350, 350, 350, 200, 200, 200, 200, 200, 200, 200, 350, 350}, 3) I""

function goluwa.PreDrawGUI()
	gfx.SetFont(font)
	local x = gfx.GetMousePosition()
	--print(x)
	--linebreak.linebreak(text, "justify", {x}, {tolerance = 3})
	linebreak.linebreak(text, "center", {x}, {tolerance = 5})
	--linebreak.linebreak(text, "center", {350}, {tolerance = 2})
	--linebreak.linebreak(text, "justify", {350, 350, 350, 200, 200, 200, 200, 200, 200, 200, 350, 350}, {tolerance = 2})
	--linebreak.linebreak(text, "justify", {50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550}, {tolerance = 3, center = true})
	--linebreak.linebreak(text, "justify", r, {tolerance = 3, center = true})
end