local render = (...) or _G.render

render.global_shader_variables = render.global_shader_variables or {}

function render.SetGlobalShaderVariable(key, val, type)
	render.global_shader_variables[key] = {
		[type] = val,
		type = type,
		key = key,
		val = val
	}
end

function render.GetGlobalShaderVariableBlock()
	local str = "layout(std140) buffer global_variables\n"
	str = str .. "{\n"
	for name, info in pairs(render.global_shader_variables) do
		if not info.type:find("sampler") then
			str = str .. "\t" .. info.type .. " " .. name .. ";\n"
		end
	end
	str = str .. "};\n"
	return str
end

function render.GetGlobalShaderBlockIndex(shader_block_info)
	if not render.global_variables_ssbo or shader_block_info.buffer_data_size ~= render.global_variables_ssbo.size then

		for i, info in ipairs(shader_block_info.variables) do
			info.fetch = render.global_shader_variables[info.name].val
			info.key = render.global_shader_variables[info.name].key
			info.fetch_type = render.global_shader_variables[info.name].type
		end

		render.global_variables_ssbo = render.CreateShaderStorageBuffer("dynamic_draw", nil, shader_block_info.buffer_data_size)
		render.global_variables_ssbo:Bind(2)
		render.global_variables_info = {}

		local function gen_lua(filter)
			local lua = ""
			lua = lua .. "local ffi = require('ffi')\n"

			lua = lua .. "local box = ffi.new('float[16]')\n"
			lua = lua .. "local env = {}\n"
			lua = lua .. "return function()\n"
			lua = lua .. "local ssbo = render.global_variables_ssbo\n"
			lua = lua .. "local variables = render.global_variables_info\n"
			for i, info in ipairs(shader_block_info.variables) do
				if filter(info.key) then
					render.global_variables_info[i] = info.fetch

					lua = lua .. "\tlocal v = variables["..i.."]()\n"
					lua = lua .. "\tif true then\n--v ~= env['"..tostring(info.key).."'] then\n"

					if info.type.name == "float" then
						lua = lua .. "\t\tbox[0] = v\n"
					elseif info.type.name == "vec2" then
						lua = lua .. "\t\tbox[0], box[1] = v:Unpack()\n"
					elseif info.type.name == "vec3" then
						lua = lua .. "\t\tbox[0], box[1], box[2] = v:Unpack()\n"
					elseif info.type.name == "vec4" then
						lua = lua .. "\t\tbox[0], box[1], box[2], box[3] = v:Unpack()\n"
					elseif info.type.name == "mat4" then
						lua = lua .. [[
		box[0] = v.m00
		box[1] = v.m01
		box[2] = v.m02
		box[3] = v.m03
		box[4] = v.m10
		box[5] = v.m11
		box[6] = v.m12
		box[7] = v.m13
		box[8] = v.m20
		box[9] = v.m21
		box[10] = v.m22
		box[11] = v.m23
		box[12] = v.m30
		box[13] = v.m31
		box[14] = v.m32
		box[15] = v.m33
]]
					end

					lua = lua .. "\t\tssbo:UpdateData(box, " .. info.type.size .. ", " .. info.offset .. ")\n"
					lua = lua .. "\t\tenv['"..tostring(info.key).."'] = v\n"
					lua = lua .. "\tend\n"
				end
			end
			lua = lua .. "end\n"
			print(lua)
			return assert(loadstring(lua))()
		end

		render.update_globals = gen_lua(function(s) return not s:find("world") end)
		render.update_globals2 = gen_lua(function(s) return s:find("world") end)
	end

	return shader_block_info.block_index, 2
end

render.global_shader_code = render.global_shader_code or {}

function render.AddGlobalShaderCode(glsl_code, function_name)
	function_name = function_name or glsl_code:match(".+%s([a-zA-Z0-9_]-)%b()%s-%b{}%s*$")

	if glsl_code:endswith(".brdf") then
		local str = vfs.Read(glsl_code)
		if str then
			local shader_name = glsl_code:match(".+/(.+)%.brdf")

			local parameters = str:match("::begin parameters(.+)::end parameters")
			local code = str:match("::begin shader(.+)::end shader")

			local arg_line = {}

			for _, line in pairs(parameters:split("\n")) do
				local type, name = unpack(line:split(" "))
				if type and name then
					if type == "color" then type = "vec3" end
					table.insert(arg_line, type .. " " .. name)
				end
			end

			code = code:replace(
				"vec3 BRDF( vec3 L, vec3 V, vec3 N, vec3 X, vec3 Y )",
				"vec3 "..shader_name.."_brdf( vec3 L, vec3 V, vec3 N, vec3 X, vec3 Y, " .. table.concat(arg_line, ", ") .. " )"
			)

			glsl_code = code
			function_name = shader_name
		end
	end

	render.global_shader_code[function_name] = {
		function_name = function_name,
		code = glsl_code,
	}
end

function render.GetGlobalShaderCode(code)

	local done = {}

	local node = {value = "", dependencies = {}}

	local function add_code(code, node)
		-- iterate other code
		for _, info in pairs(render.global_shader_code) do
			-- does this code use this other code? (using simple find as it doesn't really need to be more sophisticated)
			if code:find(info.function_name, nil, true) then
				if not done[info.function_name] then
					local new_node = {value = info.code, dependencies = {}}
					table.insert(node.dependencies, new_node)
					done[info.function_name] = true
					-- check if this other code also has dependencies
					add_code(info.code, new_node)
				end
			end
		end
	end

	add_code(code, node)

	--(03:32:42 AM) thej89: .
	local function ts( l, s, x )
		--Already in l
		if s[x] then return end
		--Add x's dependencies to l first
		for _, x in ipairs( x.dependencies ) do
			ts( l, s, x )
		end
		--Now add x to l
		s[x] = true
		table.insert( l, x.value )
	end

	local out = {}

	ts(out, {}, node)

	if SSBO then
		return render.GetGlobalShaderVariableBlock() .. "\n\n" .. table.concat(out, "\n\n")
	else
		return table.concat(out, "\n\n")
	end
end

render.AddGlobalShaderCode([[
	vec4 textureLatLon(sampler2D tex, vec3 dir)
	{
		return texture(tex, vec2((atan(dir.y, dir.x) / 3.1415926 + 1.0) * 0.5, 1.0 - acos(dir.z) / 3.1415926));
	}
]])

render.AddGlobalShaderCode([[
	vec3 rgb2hsv(vec3 c)
	{
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}
]])

render.AddGlobalShaderCode([[
	vec3 hsv2rgb(vec3 c)
	{
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
]])