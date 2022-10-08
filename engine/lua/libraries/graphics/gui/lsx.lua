local gui = ... or _G.gui
gui.BaseLSXElements = gui.BaseLSXElements or {}

do
	local META = prototype.CreateTemplate("lsx_node", "base")
	META.Kind = "node"
	runfile("lua/libraries/prototype/parenting_template.lua", META)

	function META:OnRemove()
		self:UnParent()
		prototype.MakeNULL(self)
	end

	do
		local function unpack_children(children, out)--[[#: List<|any|>]]
			out = out or {}

			for i, v in ipairs(children) do
				if list.is_list(v) then
					unpack_children(v, out)
				else
					table.insert(out, v)
				end
			end

			return out
		end

		local function normalize_children(children)
			children = unpack_children(children)
			local out = {}
			local last_type

			for i, v in ipairs(children) do
				local t = type(v)

				if t == "number" then
					v = tostring(v)
					t = "string"
				end

				if t == "string" and last_type == t then
					out[#out] = out[#out] .. v
				else
					table.insert(out, v)
				end

				last_type = t
			end

			for i, v in ipairs(out) do
				if type(v) == "string" then
					local self = META:CreateObject()
					self.Kind = "text"
					self.Value = v
					out[i] = self
				end
			end

			return out
		end

		local function cleanup_name(name)
			if not name then return "unknown" end

			return name:gsub("%b()", ""):trim()
		end

		local function Node(
			render--[[#: Function]],
			props--[[#: Table]],
			children--[[#: List<|string | Table|>]]
		)
			assert(render, "render function is nil")
			children = normalize_children(children or {})
			local self = META:CreateObject()
			self.props = props

			for i, v in ipairs(children) do
				if not v:IsValid() then error("invalid child", 2) end

				self:AddChild(v)
			end

			if gui.BaseLSXElements[render] then
				self.build_panel = render
			else
				do
					local map = {}

					for _, kv in ipairs(props) do
						map[kv.k] = kv.v
					end

					map.children = children
					self.props_evaluate = map
				end

				self.evaluate = render
			end

			self.name = gui.BaseLSXElements[render] or cleanup_name(debug.get_name(render))
			return self
		end

		-- the xml syntax will be transformed to call LSX(render, props, children)
		_G.LSX = Node
	end

	function META:Evaluate()
		self.persistent_state_index = 0

		-- nodes with evaluate are nodes that are custom functions
		-- for example a wrapper contaier that takes in children and renders them
		-- so we have to discard their initial children, ie:
		-- local function Wrapper(props) return <Base>{props.children}</Base> end
		-- <Wrapper>foo</Wrapper> 
		-- >> <Base>foo</Base>
		if self.evaluate then
			-- a function component only returns 1 node
			local prev_child = self:GetChildren()[1]
			local panel = prev_child and prev_child.panel
			local child_list = self:GetChildrenList()
			local panel_list = {}

			for i, v in ipairs(child_list) do
				panel_list[i] = {
					panel = v.panel,
					persistent_states = v.persistent_states,
					persistent_state_index = v.persistent_state_index,
				}
			end

			--self:RemoveChildren() --TODO
			self.Children = {} -- maybe don't remove but just unparent children?
			local test = self.evaluate(self.props_evaluate, self)

			if test then
				test.panel = panel
				test:Evaluate()
				self:AddChild(test)

				for _, child in ipairs(self:GetChildren()) do
					if child.Kind == "node" then child:Evaluate() end

					child:SetParent(self)
				end

				table.remove(panel_list, 1)

				for i, v in ipairs(test:GetChildrenList()) do
					if v.Kind == "node" then
						if panel_list[i] then
							v.panel = panel_list[i].panel
							v.persistent_states = panel_list[i].persistent_states
							v.persistent_state_index = panel_list[i].persistent_state_index
						end
					end
				end

				return self
			else
				utility.SafeRemove(panel)
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.Kind == "node" then
				child:Evaluate()
			--child:SetParent(self)
			end
		end

		return self
	end

	function META:BuildPanels(parent)
		local mounted = not self.build_panel and self.panel == nil

		if self.build_panel then
			local mounted = self.panel == nil

			if mounted then self:OnUnmount() end

			self.panel = self.build_panel(self, "nokey", self.props, self.panel, parent)

			if mounted then self:OnMount(self.panel) end
		else
			if mounted then self:OnUnmount() end

			self.panel = parent
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.Kind == "node" then
				child:BuildPanels(self.panel)
			elseif self.panel then
				local str = tostring(child.Value)

				if not self.panel.SetText then
					error("panel " .. tostring(self) .. " is not a text panel " .. str)
				end

				self.panel:SetText(str)
			end
		end

		if mounted then self:OnMount(self:GetChildren()[1].panel) end

		if self:HasParent() then self:GetParent():OnRender(self.panel) end
	end

	function META:PersistentTable(state)
		self.persistent_states = self.persistent_states or {}
		self.persistent_state_index = self.persistent_state_index + 1

		if self.persistent_states[self.persistent_state_index] == nil then
			self.persistent_states[self.persistent_state_index] = state
		end

		return self.persistent_states[self.persistent_state_index]
	end

	function META:ReRender()
		self:Evaluate()

		if self:HasParent() then
			self:BuildPanels(self:GetParent().panel)
		else
			self:BuildPanels(self.root_panel)
		end
	end

	function META:OnMount(parent) end

	function META:OnRender(parent) end

	function META:OnUnmount() end

	function META:useEffect(func, deps)
		self.effects = self.effects or {}
		local state = self:PersistentTable({
			effect = true,
			dependencies = deps,
			func = func,
		})
	end

	function META:memo(val, deps)
		local state = self:PersistentTable({value = val(), deps = deps})

		if not table.equal(state.deps, deps) then
			state.value = val()
			state.deps = deps
		end

		return state.value
	end

	function META:useState(init)
		local state

		local function set(new_state)
			if not table.equal(state.value, new_state) then
				state.value = new_state
				state.set = set
				self:ReRender()
			end
		end

		state = self:PersistentTable({value = init, set = set})
		return state.value, state.set
	end

	function META:useRef(init)
		local state = self:PersistentTable({current = init})
		return state
	end

	function META:Dump(indent, depth)
		depth = depth or 0
		local str = ""
		str = "<" .. self.name

		if next(self.props) then str = str .. " " end

		for _, kv in pairs(self.props) do
			str = str .. kv.k .. "=" .. tostring(kv.v)

			if _ ~= #self.props then str = str .. " " end
		end

		str = str .. ">"

		if indent then
			if #self:GetChildren() > 0 then
				str = str .. "\n"
				depth = depth + 1
				str = str .. string.rep("\t", depth)
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.Kind == "node" then
				str = str .. child:Dump(indent, depth)
			else
				str = str .. "\"" .. child.Value .. "\""
			end

			if indent then
				if _ ~= #self:GetChildren() then
					str = str .. "\n"
					str = str .. string.rep("\t", depth)
				end
			end
		end

		if indent then
			if #self:GetChildren() > 0 then
				str = str .. "\n"
				depth = depth - 1
				str = str .. string.rep("\t", depth)
			end
		end

		str = str .. "<" .. self.name .. "/>"
		return str
	end

	META:Register()
end

local function Panel(type--[[#: string]], node, key, props--[[#: Table]], panel, parent)
	local pnl = panel or gui.CreatePanel(type)

	for _, kv in pairs(props) do
		local k = kv.k
		local v = kv.v
		k = k:transform_case("foo_bar", "FooBar")

		if k == "OnMount" or k == "OnUnmount" or k == "OnRender" then
			print(type, k, v)
			node[k] = v
		elseif k:starts_with("On") then
			pnl[k] = v
		elseif pnl["Set" .. k] then
			pnl["Set" .. k](pnl, v)
		elseif _G.type(pnl[k]) == "function" then
			if k == "SetupLayout" then
				pnl[k](pnl, unpack(v))
			else
				pnl[k](pnl, v)
			end
		end
	end

	if not panel then pnl:SetParent(parent) end

	return pnl
end

function gui.RegisterLSXNodes()
	for tag in pairs(prototype.GetRegisteredSubTypes("panel")) do
		local name = tag:transform_case("foo_bar", "FooBar")
		_G[name] = function(...)
			return Panel(tag, ...)
		end
		gui.BaseLSXElements[_G[name]] = name
	end
end

if RELOAD then
	gui.RegisterLSXNodes()
	runfile("/home/caps/github/goluwa/game/lua/examples/gui/lsx/design_system.nlua")
end