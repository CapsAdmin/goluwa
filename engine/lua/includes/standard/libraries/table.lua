function table.HasValue(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then
			return k
		end
	end

	return false
end

function table.GetKey(tbl, val)
	for k,v in pairs(tbl) do
		if k == val then
			return k
		end
	end

	return nil
end

function table.count(tbl)
	local i = 0
	
	for k,v in pairs(tbl) do
		i = i + 1
	end

	return i
end

function table.merge(a,b)
	for k,v in pairs(b) do
		a[k] = v
	end

	return a
end

function table.random(tbl)
	local key = math.random(1, table.count(tbl))
	local i = 1
	for _key, _val in pairs(tbl) do
		if i == key then
			return _val, _key
		end
		i = i + 1
	end
end

do -- table print
	local function _toMarkup(val, spacing, colors, parsed)
		if type(val) == "string" then
			return {{v = string.format("%q", val), i = spacing, c = colors.string or colors["default"]}}
		elseif type(val) == "boolean" then
			return {{v = val and "true" or "false", i = spacing, c = colors.boolean or colors["default"]}}
		elseif type(val) == "number" then
			return {{v = tostring(val), i = spacing, c = colors.number or colors["default"]}}
		elseif type(val) == "function" then
			local info = debug.getinfo(val, "S")
			if not info or info.what == "C" then
				return {{v = "function:([C])", i = spacing, c = colors.c_function or colors["function"] or colors["default"]}}
			else
				return {{v = ("function:(%s : %s-%s)"):format(info.short_src, info.linedefined, info.lastlinedefined), i = spacing, c = colors["function"] or colors["default"]}} --"..table.concat(debug.getparams(val), ",").."
			end
		elseif type(val) == "table" then
			if parsed[val] then
				return {{v = "<"..tostring(val)..">", i = spacing, c = colors.table or colors["default"]}}
			else
				parsed[val] = true
				local s = {{v = "{", n = true, i = spacing, c = colors.table or colors["default"]}}
				for key,val2 in pairs(val) do
					table.insert(s, {v = "[", i = spacing+1, c = colors.table or colors["default"]})
					local k_s = _toMarkup(key, spacing+1, colors, parsed)
					k_s.i = spacing+1
					for k_i = 1, #k_s do
						table.insert(s, k_s[k_i])
					end
					table.insert(s, {v = "]", i = spacing+1, c = colors.table or colors["default"]})
					table.insert(s, {v = " = ", i = spacing, c = colors.table or colors["default"]})
					local v_s = _toMarkup(val2, spacing+1, colors, parsed)
					v_s.i = spacing+1
					for v_i = 1, #v_s do
						table.insert(s, v_s[v_i])
					end
					table.insert(s, {v = ",", n = true, c = colors.table or colors["default"]})
				end
				table.insert(s, {v = "}", i = spacing, c = colors.table or colors["default"]})
				return s
			end
		elseif type(val) == "nil" then
			return {{v = "nil", c = colors["nil"] or colors["default"]}}
		end
		return {{v = "<"..type(val)..">: "..tostring(val)..">", c = colors["default"]}}
	end

	local function toMarkup(val, colors)
		return _toMarkup(val, 0, colors, {})
	end

	local function MarkupToHTML(markup, colors_override)
		local colors = colors_override or table.markup_colors
		local s, cc, ic, first = "", colors.default, 0, true
		local jn = true
		for oi = 1, #markup do
			local object = markup[oi]
			local c = object.c
			local changes = ""
			if c and c.r ~= cc.r or c.g ~= cc.g or c.b ~= cc.b then
				changes = changes.."color:#"..string.format("%X", (c.r*256+c.g)*256+c.b)..";"
				cc = c
			end
			--[[if object.i and object.i ~= ic then
				changes = changes.."text-ident: "..(5+10*object.i).."pt;"
				ic = object.i
			end]]
			if changes ~= "" then
				s = s..(first and "" or "</span>")..'<span style="'..changes..'">'
				first = false
			end
			s = s
				..(jn and ("&nbsp;"):rep((object.i  or 0)*4) or "")
				..string.gsub(object.v or "", ".", function(c)
					local b = string.byte(c)
					return (b < 32 or b > 155 or b == 60 or b == 62 or b == 38) and "&#"..b..";"
				end)
				..(object.n and "<br/>\n" or "")
			jn = object.n
		end
		if not first then
			s = s.."</span>"
		end
		return s
	end
	
	local markup_colors = {}
	
	if Color then
		markup_colors = {
			table = Color(255, 150, 255),
			string = color_white,
			number = Color(255, 128, 0),
			boolean = Color(150, 255, 150),
			["function"] = Color(100, 150, 255),
			c_function = Color(100, 255, 255), -- what colour is this? :S
			default = Color(255, 100, 100),
		}
	end
	
	function table.tomarkup(t, colors_override)
		return toMarkup(t, colors_override or markup_colors)
	end

	local function MsgColor(color, msg)
		if console and console.Print then
			console.Print(color, msg)
		elseif MsgC then
			MsgC(color,msg)
		else
			Msg(msg)
		end
	end

	local function table_print(tbl, colors_override)
		local markup = table.tomarkup(tbl, colors_override)
		local jn = true
		for oi = 1, #markup do
			local object = markup[oi]
			MsgColor(object.c, ("\t"):rep(jn and object.i or 0)..(object.v or "")..(object.n and "\n" or ""))
			jn = object.n
		end
		MsgColor(markup_colors.default,"\n")
	end

	table.print = function(...) -- so we don't pass extra tables..
		for k,tbl in pairs{...} do
			table_print(tbl)
		end
	end

	function table.tohtml(tbl, colors_override)
		return MarkupToHTML(table.tomarkup(tbl, colors_override))
	end

end

do -- table copy
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end

	function table.copy(object)
		lookup_table = {}
		return _copy(object)
	end
end