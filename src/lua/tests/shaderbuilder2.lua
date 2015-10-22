local gl = require("graphics.ffi.opengl")

local source = [[
	uniforms
	{
		sampler2D tex = render.GetWhiteTexture()
		vec4 global_color = Color(1,1,1,1)
		float lol = function() return math.sin(os.clock()) end
	}

	vertex
	{
		in vec3 pos;
		in vec2 uv;
		in vec4 color;
		in float shade;

		out vec2 fuv;
		out vec3 fcolor;

		void main()
		{
			gl_Position = g_projection_view_world_2d * vec4(pos, 1);
			fuv = uv;
			fcolor = color;
		}
	}

	fragment
	{
		in vec2 uv;
		in vec4 color;
		vec4 out_color;

		void main()
		{
			vec4 tex_color = texture(tex, uv);
			vec4 override = lua[vec4 color_override = Color(0,0,0,0)];

			lua vec4 rofl = Color(0,0,0,0);

			/*if (override.r > 0) tex_color.r = override.r;
			if (override.g > 0) tex_color.g = override.g;
			if (override.b > 0) tex_color.b = override.b;
			if (override.a > 0) tex_color.a = override.a;*/

			##for _, v in ipairs({"r", "g", "b", "a"}) do
				if (override.$(v) > 0) tex_color.$(v) = override.$(v);
			##end

			vec4 c = tex_color * color * global_color + rofl;
			c.a = c.a * lua[float alpha_multiplier = 1];

			out_color = c;
		}
	}
]]

local function handle_error(error_str, source)
	if source then
		local lines = source:explode("\n")

		for line, error_num, error_type, str in error_str:gmatch("0%((.-)%) : error (.-): (.-), (.-)\n") do
			line = tonumber(line)
			logn("==== ", error_type, " ===")
			for i = -3, 3 do
				log(line + i, ": ", lines[line + i])
				if i == 0 then
					logn(" <<< ", str)
				else
					logn("")
				end
			end
			logn("==== ", error_type, " ===")
			logn("\n\n")
		end
	else
		logn(error_str)
	end
end

local function create_gl_shader(type, source)
	local shader = gl.CreateShader(type)

	local shader_strings = ffi.new("const char * [1]")
	shader_strings[0] = ffi.cast("const char *", source)
	gl.ShaderSource(shader, 1, shader_strings, nil)
	gl.CompileShader(shader)

	local status = ffi.new("GLint[1]")
	gl.GetShaderiv(shader, "GL_COMPILE_STATUS", status)

	if status[0] == 0 then
		local log = ffi.new("char[1024]")
		gl.GetShaderInfoLog(shader, 1024, nil, log)
		gl.DeleteShader(shader)

		handle_error(ffi.string(log), source)
	end

	return shader
end

local function create_program()
	return gl.CreateProgram()
end

local function attach_shader(program, shader)
	gl.AttachShader(program, shader)
end

local function link_program(program)
	gl.LinkProgram(program)

	local status = ffi.new("GLint[1]")
	gl.GetProgramiv(program, "GL_LINK_STATUS", status)

	if status[0] == 0 then
		local log = ffi.new("char[1024]")
		gl.GetProgramInfoLog(program, 1024, nil, log)
		gl.DeleteProgram(program)

		handle_error(ffi.string(log))
	end
end

local shader_stages = {
	"vertex",
	"geometry",
	"fragment",
}

local type_info =  {
	int = {"int", 1},
	float = {"float", 1},
	number = {"float", 1},
	vec2 = {"float", 2},
	vec3 = {"float", 3},
	vec4 = {"float", 4},
}

-- extend type info
for type_name, info in pairs(type_info) do
	local ctype, length = unpack(info) table.clear(info)

	info.size = ffi.sizeof(ctype)
	info.enum_type = "GL_" .. ctype:upper()
	info.decl = ("%s %%s[%i]"):format(ctype, length)
end

local data = {}

source = source:gsub("(%/%/.-)\n", "")
source = source:gsub("(%/%*.-%*/)", "")

local chunk = {"local out = {}\n"}
for i, line in ipairs(source:explode("\n")) do
	if string.find(line, "^%s-##") then
		table.insert(chunk, ("%s\n"):format(line:match("%s-##(.+)")))
	else
		local found = false
		local str = ""
		local last
		for text, expr, index in line:gmatch("(.-)$(%b())()") do
			last = index
			str = str .. text .. "]===]" .. " .. " .. expr .. " .. " .. "[===["
		end
		if last then
			last = line:sub(last)
			line = str .. last
		end
		table.insert(chunk, string.format('table.insert(out, [===[%s]===])', line) .. "\n")
	end
end
table.insert(chunk, [[return table.concat(out, "\n")]])

source = assert(loadstring(table.concat(chunk)))()

local auto_in_out

do
	data.vertex_attributes = {}
	data.vertex_attributes.members = {}

	local decl = "struct { "

	local found = false

	source = source:gsub("vertex_attributes%s-(%b{})", function(block)
		for line in (block:sub(2,-2):trim() .. "\n"):gmatch("(.-)\n") do
			local t, name = unpack(line:gsub("%s+", " "):trim():explode(" "))
			local info = table.copy(type_info[t])

			decl = decl .. info.decl:format(name) .. "; "

			table.insert(data.vertex_attributes.members, {type = t, name = name, info = info})
			found = true
		end
	end)

	if not found then
		local source_middle = source:match("vertex%s-(%b{})")
		for line in (source_middle:sub(2,-2):trim() .. "\n"):gmatch("%sin(.-);") do
			local t, name = unpack(line:gsub("%s+", " "):trim():explode(" "))

			local info = table.copy(type_info[t])

			decl = decl .. info.decl:format(name) .. "; "

			table.insert(data.vertex_attributes.members, {type = t, name = name, info = info})
		end
		auto_in_out = false
	end

	decl = decl .. "}"

	data.vertex_attributes.decl = decl
	data.vertex_attributes.size = ffi.sizeof(decl)
end

do
	local function parse_uniform_line(str)
		local keywords, lua = str:match("(.-)=(.+)")

		keywords = keywords:trim()
		lua = lua:trim()

		local t, name = unpack(keywords:gsub("%s+", " "):trim():explode(" "))
		local val = assert(loadstring("return " .. lua))()

		return t, name, val
	end

	data.uniforms = {}

	-- grab uniforms declared in the uiniforms block
	source = source:gsub("uniforms%s-(%b{})", function(block)
		for line in (block:sub(2,-2):trim() .. "\n"):gmatch("(.-)\n") do
			local t, name, val = parse_uniform_line(line)

			table.insert(data.uniforms, {type = t, name = name, val = val})
		end
		return ""
	end)

	-- grab uiniforms declared like so: vec4 override = lua[vec4 color_override = Color(0,0,0,0)];
	source = source:gsub("(lua%b[])", function(str)
		local t, name, val = parse_uniform_line(str:sub(5, -2))

		table.insert(data.uniforms, {type = t, name = name, val = val})

		return name
	end)

	-- grab uiniforms declared like so: lua vec4 rofl = Color(0,0,0,0);
	source = source:gsub("lua(%s-(%S-)%s-(%S-)%s-=(.-));", function(line)
		local t, name, val = parse_uniform_line(line)
		table.insert(data.uniforms, {type = t, name = name, val = val})
		return ""
	end)
end

data.stages = {}

for _, stage_name in pairs(shader_stages) do
	local source_middle = source:match(stage_name .. "%s-(%b{})")

	if source_middle then
		local stage = {}
		stage.name = stage_name

		do
			source_middle = source_middle:sub(2, -2)

			if source_middle:find("void%s-main") then
				source_middle = source_middle:gsub("void%s-main", function()
					return "void lua_main"
				end)
			else
				if stage_name == "vertex" then
					source_middle = "vec4 lua_main()\n{\n" .. source_middle .. "\n}"
				elseif stage_name == "fragment" then
					local return_type = source:match("(%S-) " .. stage_name) or "vec4"
					source_middle = return_type .. " lua_main()\n{\n" .. source_middle .. "\n}"
				end
			end

			stage.source_middle = source_middle
		end


		do
			local source_top = "#version 420\n"

			do -- regular uniforms
				local str = ""
				local found = false

				do
					local layout_index = 0

					for _, info in ipairs(data.uniforms) do
						if source_middle:find(info.name, nil, true) and info.type:find("sampler", nil, true) then
							str = str .. "layout(binding = "..layout_index..")  "
							str = str .. "uniform " .. info.type .. " " .. info.name .. ";\n"
							layout_index = layout_index + 1
							found = true
						end
					end
				end

				for name, v in pairs(render.global_shader_variables) do
					local type, val = next(v)

					if source_middle:gsub("_", "LOL"):find(name:gsub("_", "LOL") .. "[%s%p]") then
						str = str .. type .. " " .. name .. ";\n"
						found = true
					end
				end

				if found then
					source_top = source_top .. str .. "\n\n"
				end
			end

			do -- uniform block
				local str = "uniform variables\n{\n"
				local found = false

				for _, info in ipairs(data.uniforms) do
					if source_middle:find(info.name, nil, true) and not info.type:find("sampler", nil, true) then
						str = str .. "\t" .. info.type .. " " .. info.name .. ";\n"
						found = true
					end
				end

				str = str .. "};\n"

				if found then
					source_top = source_top .. str .. "\n\n"
				end
			end

			source_top = source_top .. render.GetGlobalShaderCode(source_top .. source_middle)

			stage.source_top = source_top
		end

		do
			local source_bottom = "\n\n\n\n"
			if stage_name == "vertex" then
				source_bottom = source_bottom .. "void main()\n"
				source_bottom = source_bottom .. "{\n"
				source_bottom = source_bottom .. "\t//__TOP__\n"
				source_bottom = source_bottom .. "\tgl_Position = lua_main();\n"
				source_bottom = source_bottom .. "}\n"
			elseif stage_name == "fragment" then
				local return_type = source:match("(%S-) " .. stage_name) or "vec4"
				source_bottom = source_bottom .. "out " .. return_type .. " lua_val_out;\n"
				source_bottom = source_bottom .. "void main()\n"
				source_bottom = source_bottom .. "{\n"
				source_bottom = source_bottom .. "\t//__TOP__\n"
				source_bottom = source_bottom .. "\tlua_val_out = lua_main();\n"
				source_bottom = source_bottom .. "}\n"
			else
				source_bottom = source_bottom .. "void main()\n"
				source_bottom = source_bottom .. "{\n"
				source_bottom = source_bottom .. "\t//__TOP__\n"
				source_bottom = source_bottom .. "\tlua_main();\n"
				source_bottom = source_bottom .. "}\n"
			end
			stage.source_bottom = source_bottom
		end

		table.insert(data.stages, stage)
	end
end

if auto_in_out == nil then
	auto_in_out = #data.stages == 2
end

if auto_in_out then
	for i, stage in ipairs(data.stages) do
		if stage.name == "vertex" then
			local next_stage_name = data.stages[i + 1] and data.stages[i + 1].name or "huh"

			do -- vertex layout
				local str = ""
				local found = false

				for _, info in ipairs(data.vertex_attributes.members) do
					if stage_name == "vertex" then
						str = str .. "in highp " .. info.type .. " " .. info.name .. ";\n"
						found = true
					end
				end

				if found then
					tage.source_top = str .. "\n\n" .. stage.source_top
				end
			end

			local found = {}
			for i, stage in ipairs(data.stages) do
				if stage.name ~= "vertex" then
					for i, info in ipairs(data.vertex_attributes.members) do
						if stage.source_middle:find(info.name, nil, true) then
							found[i] = info
						end
					end
				end
			end

			for i, info in pairs(found) do
				stage.source_top = stage.source_top .. "out " .. info.type .. " lua_" .. next_stage_name .. "_" .. info.name .. ";\n"
			end

			local str = ""

			for i, info in pairs(found) do
				str = str .. "\tlua_"..next_stage_name.."_" .. info.name .. " = " .. info.name .. ";\n"
			end

			stage.source_bottom = stage.source_bottom:gsub("\t//__TOP__", str)
		else
			local prev_stage_name = data.stages[i - 1] and data.stages[i - 1].name or "huh"

			do -- vertex layout
				local str = ""
				local found = false

				for _, info in ipairs(data.vertex_attributes.members) do
					if stage_name == "vertex" then
						str = str .. "in highp " .. info.type .. " " .. info.name .. ";\n"
						found = true
					end
				end

				if found then
					tage.source_top = str .. "\n\n" .. stage.source_top
				end
			end

			for i, info in ipairs(data.vertex_attributes.members) do
				if stage.source_middle:find(info.name, nil, true) then
					stage.source_top = stage.source_top .. "in highp " .. info.type .. " lua_" .. prev_stage_name .. "_" .. info.name .. ";\n"
					stage.source_top = stage.source_top .. "#define uv lua_" .. prev_stage_name .. "_" .. info.name .. "\n"
				end
			end
		end
	end
end

local program = create_program()

for i, stage in ipairs(data.stages) do
	attach_shader(program, create_gl_shader("GL_" .. stage.name:upper() .. "_SHADER", stage.source_top .. stage.source_middle .. stage.source_bottom))
end

link_program(program)
do return end
local id = render.CreateGLProgram(function(prog)
	local vertex_attributes = {}
	local pos = 0

	for i, data in pairs(data.vertex_attributes.members) do
		gl.BindAttribLocation(prog, i - 1, data.name)

		vertex_attributes[i] = {
			arg_count = data.info.arg_count,
			enum = data.info.enum_type,
			stride = data.vertex_attributes.size,
			type_stride = ffi.cast("void*", data.info.size * pos),
			location = i - 1,
		}

		pos = pos + data.info.arg_count
	end

	data.vertex_attributes = vertex_attributes
end, unpack(data.shaders))