local ipairs = ipairs
local table = _G.table
local Union = require("nattlua.types.union").Union

local function mutation_solver(mutations, scope, obj)
	do
		do
			for i = #mutations, 1, -1 do
				local mut_a = mutations[i]

				for i = i - 1, 1, -1 do
					local mut_b = mutations[i]

					if mut_a.scope == mut_b.scope then
						table.remove(mutations, i)

						break
					end
				end
			end
		end

		for i = #mutations, 1, -1 do
			local mut = mutations[i]

			if
				(
					scope:IsPartOfTestStatementAs(mut.scope) or
					(
						mut.from_tracking and
						not mut.scope:Contains(scope)
					)
				)
				and
				scope ~= mut.scope
			then
				table.remove(mutations, i)
			end
		end

		do
			for i = #mutations, 1, -1 do
				local mut = mutations[i]

				if mut.scope:IsElseConditionalScope() then
					while true do
						local mut = mutations[i]

						if not mut then break end

						if
							not mut.scope:IsPartOfTestStatementAs(scope) and
							not mut.scope:IsCertainFromScope(scope)
						then
							for i = i, 1, -1 do
								if mutations[i].scope:IsCertainFromScope(scope) then
									-- redudant mutation before else part of if statement
									table.remove(mutations, i)
								end
							end

							break
						end

						i = i - 1
					end

					break
				end
			end
		end

		do
			local test_scope_a = scope:FindFirstConditionalScope()

			if test_scope_a then
				for _, mut in ipairs(mutations) do
					if mut.scope ~= scope then
						local test_scope_b = mut.scope:FindFirstConditionalScope()

						if test_scope_b and test_scope_b ~= test_scope_a and obj.Type ~= "table" then
							if test_scope_a:TracksSameAs(test_scope_b, obj) then
								-- forcing scope certainty because this scope is using the same test condition
								mut.certain_override = true
							end
						end
					end
				end
			end
		end
	end

	if not mutations[1] then return end

	local union = Union({})

	if obj.Type == "upvalue" then union:SetUpvalue(obj) end

	for _, mut in ipairs(mutations) do
		local value = mut.value

		if value.Type == "union" and #value:GetData() == 1 then
			value = value:GetData()[1]
		end

		do
			local upvalues = mut.scope:GetTrackedUpvalues()

			if upvalues then
				for _, data in ipairs(upvalues) do
					local stack = data.stack

					if stack then
						local val

						if mut.scope:IsElseConditionalScope() then
							val = stack[#stack].falsy
						else
							val = stack[#stack].truthy
						end

						if val and (val.Type ~= "union" or not val:IsEmpty()) then
							union:RemoveType(val)
						end
					end
				end
			end
		end

		-- IsCertain isn't really accurate and seems to be used as a last resort in case the above logic doesn't work
		if mut.certain_override or mut.scope:IsCertainFromScope(scope) then
			union:Clear()
		end

		if
			union:Get(value) and
			value.Type ~= "any" and
			mutations[1].value.Type ~= "union" and
			mutations[1].value.Type ~= "function" and
			mutations[1].value.Type ~= "any"
		then
			union:RemoveType(mutations[1].value)
		end

		if _ == 1 and value.Type == "union" then
			union = value:Copy()

			if obj.Type == "upvalue" then union:SetUpvalue(obj) end
		else
			union:AddType(value)
		end
	end

	local value = union

	if #union:GetData() == 1 then
		value = union:GetData()[1]

		if obj.Type == "upvalue" then value:SetUpvalue(obj) end

		return value
	end

	local found_scope, data = scope:FindResponsibleConditionalScopeFromUpvalue(obj)

	if not found_scope or not data.stack then return value end

	local stack = data.stack

	if
		found_scope:IsElseConditionalScope() or
		(
			found_scope ~= scope and
			scope:IsPartOfTestStatementAs(found_scope)
		)
	then
		local union = stack[#stack].falsy

		if union:GetLength() == 0 then
			union = Union()

			for _, val in ipairs(stack) do
				union:AddType(val.falsy)
			end
		end

		if obj.Type == "upvalue" then union:SetUpvalue(obj) end

		return union
	end

	local union = Union()

	for _, val in ipairs(stack) do
		union:AddType(val.truthy)
	end

	if obj.Type == "upvalue" then union:SetUpvalue(obj) end

	return union
end

return mutation_solver