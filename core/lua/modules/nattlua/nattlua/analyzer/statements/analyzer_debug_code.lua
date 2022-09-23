return {
	AnalyzeAnalyzerDebugCode = function(self, statement)
		local code = statement.lua_code.value.value:sub(3)
		self:CallLuaTypeFunction(self:CompileLuaAnalyzerDebugCode(code, statement.lua_code), self:GetScope())
	end,
}
