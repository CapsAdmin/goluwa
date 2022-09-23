local table = _G.table
local type = type
local ipairs = ipairs
local tostring = tostring
local io = io
local debug = debug
local error = error
local helpers = require("nattlua.other.helpers")
local Any = require("nattlua.types.any").Any
return function(META)
	--[[#type META.diagnostics = {
		[1 .. inf] = {
			node = any,
			start = number,
			stop = number,
			msg = string,
			severity = "warning" | "error",
			traceback = string,
		},
	}]]

	table.insert(META.OnInitialize, function(self)
		self.diagnostics = {}
	end)

	function META:Assert(ok, err, ...)
		if ok == nil or ok == false then
			err = err or "assertion failed!"
			self:Error(err)
			return Any()
		end

		return ok, err, ...
	end

	function META:ErrorAssert(ok, err)
		if not ok then error(self:ErrorMessageToString(err or "assertion failed!")) end
	end

	function META:ErrorMessageToString(tbl)
		if type(tbl) == "string" then return tbl end

		local out = {}

		for i, v in ipairs(tbl) do
			if type(v) == "table" then
				if v.Type then
					table.insert(out, tostring(v))
				else
					table.insert(out, self:ErrorMessageToString(v))
				end
			else
				table.insert(out, tostring(v))
			end
		end

		return table.concat(out)
	end

	function META:ReportDiagnostic(
		msg--[[#: {reasons = {[number] = string}} | {[number] = string}]],
		severity--[[#: "warning" | "error"]]
	)
		if self.SuppressDiagnostics then return end

		local node = self.current_expression or self.current_statement

		if not msg or not severity then
			io.write("msg = ", tostring(msg), "\n")
			io.write("severity = ", tostring(severity), "\n")
			io.write(debug.traceback(), "\n")
			error("bad call to ReportDiagnostic")
		end

		local msg_str = self:ErrorMessageToString(msg)

		if
			self.expect_diagnostic and
			self.expect_diagnostic[1] and
			self.expect_diagnostic[1].severity == severity and
			msg_str:find(self.expect_diagnostic[1].msg)
		then
			table.remove(self.expect_diagnostic, 1)
			return
		end

		local key = msg_str .. "-" .. tostring(node) .. "-" .. "severity"
		self.diagnostics_map = self.diagnostics_map or {}

		if self.diagnostics_map[key] then return end

		self.diagnostics_map[key] = true
		severity = severity or "warning"
		local start, stop = node:GetStartStop()

		if self.OnDiagnostic and not self:IsTypeProtectedCall() then
			self:OnDiagnostic(node.Code, msg_str, severity, start, stop, node)
		end

		table.insert(
			self.diagnostics,
			{
				node = node,
				start = start,
				stop = stop,
				msg = msg_str,
				severity = severity,
				traceback = debug.traceback(),
				protected_call = self:IsTypeProtectedCall(),
			}
		)
	end

	function META:PushProtectedCall()
		self:PushContextRef("type_protected_call")
	end

	function META:PopProtectedCall()
		self:PopContextRef("type_protected_call")
	end

	function META:IsTypeProtectedCall()
		return self:GetContextRef("type_protected_call")
	end

	function META:Error(msg)
		return self:ReportDiagnostic(msg, "error")
	end

	function META:Warning(msg)
		return self:ReportDiagnostic(msg, "warning")
	end

	function META:FatalError(msg)
		error(msg, 2)
	end

	function META:GetDiagnostics()
		return self.diagnostics
	end
end
