local META = (...) or prototype.GetRegistered("markup")

local function parse_tag_arguments(self, arg_line)
	local out = {}
	local str = {}
	local in_lua = false

	for _, char in pairs(utf8.totable(arg_line)) do
		if char == "[" then
			in_lua = true
		elseif in_lua and char == "]" then -- todo: longest match
			in_lua = false
			local exp = table.concat(str, "")
			local ok, func = expression.Compile(exp)
			if ok then
				table.insert(out, func)
			else
				logf(exp)
				logf("markup expression error: %s", func)
			end
			str = {}
		elseif char == "," and not in_lua then
			if #str > 0 then
				table.insert(out, table.concat(str, ""))
				str = {}
			end
		else
			table.insert(str, char)
		end
	end

	if #str > 0 then
		table.insert(out, table.concat(str, ""))
		str = {}
	end

	for k,v in pairs(out) do
		if tonumber(v) then
			out[k] = tonumber(v)
		end
	end

	return out
end

function META:StringTagsToTable(str)

	str = tostring(str)

	str = str:gsub("<rep=(%d+)>(.-)</rep>", function(count, str)
		count = math.min(math.max(tonumber(count), 1), 500)

		if #str:rep(count):gsub("<(.-)=(.-)>", ""):gsub("</(.-)>", ""):gsub("%^%d","") > 500 then
			return "rep limit reached"
		end

		return str:rep(count)
	end)

	local chunks = {}
	local found = false

	local in_tag = false
	local current_string = {}
	local current_tag = {}

	local last_font
	local last_color

	for _, char in pairs(utf8.totable(str)) do
		if char == "<" then

			-- if we've been parsing a string add it
			if current_string then
				table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
			end

			-- stat a new tag
			current_tag = {}
			in_tag = true
		elseif char == ">" and in_tag then
			-- maybe the string was "sdasd :> sdsadasd <color123>..."
			if current_tag then
				local tag_str = table.concat(current_tag, "") .. ">"
				local tag, arg_str = tag_str:match("<(.-)=(.+)>")
				local stop_tag = false

				if not tag or not self.tags[tag] then
					tag = tag_str:match("<(.-)>")
				end

				if not tag or not self.tags[tag] then
					tag = tag_str:match("</(.-)>")
					stop_tag = true
				end

				local info = self.tags[tag]
				local is_expression = false

				if info then
					local args = {}

					if not stop_tag then
						info.arg_types = {}

						args = parse_tag_arguments(self, arg_str or "")

						for i = 1, #info.arguments do
							local arg = args[i]
							local default = info.arguments[i]
							local t = type(default)

							info.arg_types[i] = t == "table" and "number" or t

							if t == "number" then
								local num = tonumber(arg)

								if not num and type(arg) == "function" then
									is_expression = true
									num = arg
								end

								args[i] = num or default
							elseif t == "string" then
								if not arg or arg == "" then
									arg = default
								end

								args[i] = arg
							elseif t == "table" then
								if default.min or default.max or default.default then
									local num = tonumber(arg)

									if num then
										if default.min and default.max then
											args[i] = math.min(math.max(num, default.min), default.max)
										elseif default.min then
											args[i] = math.min(num, default.min)
										elseif default.max then
											args[i] = math.max(num, default.max)
										end
									else
										if type(arg) == "function" then
											if default.min and default.max then
												args[i] = function(...) return math.min(math.max(arg(...) or default.default, default.min), default.max) end
											elseif default.min then
												args[i] = function(...) return math.min(arg(...) or default.default, default.min) end
											elseif default.max then
												args[i] = function(...) return math.max(arg(...) or default.default, default.max) end
											end
											is_expression = true
										else
											args[i] = default.default
										end
									end
								end
							end
						end
					end

					found = true

					-- if this is a string tag just put color and font as if they were var args for better performance
					if not is_expression and tag == "font" then
						if stop_tag then
							if last_font then
								table.insert(chunks, {type = "font", val = last_font})
							end
						else
							local font = surface.FindFont(args[1])
							table.insert(chunks, {type = "font", val = font})
							last_font = font
						end
					elseif not is_expression and tag == "color" then
						if stop_tag then
							if last_color then
								table.insert(chunks, {type = "color", val = Color(unpack(last_color))})
							end
						else
							table.insert(chunks, {type = "color", val = Color(unpack(args))})
							last_color = args
						end
					else
						table.insert(chunks, {type = "custom", val = {tag = info, type = tag, args = args, stop_tag = stop_tag}})
					end

				end
			end

			current_string = {}
			in_tag = false
		end

		if in_tag then
			table.insert(current_tag, char)
		elseif char ~= ">" then
			table.insert(current_string, char)
		end
	end

	if found then
		table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
	else
		chunks = {{type = "string", val = str}}
	end


	-- text modifiers
	-- this wont work if you do markup:AddTable({"<strmod>sada  sad ad wad d asdasd", Color(1,1,1,1), "</strmod>"})
	-- since it can only be applied to one markup.AddString(str, true) call
	for i, chunk in ipairs(chunks) do
		if chunk.type == "custom" and self.tags[chunk.val.type].modify_text then
			local start_chunk = chunk
			local func = self.tags[start_chunk.val.type].modify_text

			for i = i, #chunks do
				local chunk = chunks[i]

				if chunk.type == "string" then
					chunk.val = func(self, chunk, chunk.val, unpack(start_chunk.val.args)) or chunk.val
				end

				if chunk.type == "tag_stopper" or (chunk.type == "custom" and chunk.val.type == start_chunk.val.type and chunk.val.stop_tag) then
					break
				end
			end
		end
	end

	return chunks
end

prototype.UpdateObjects(META)