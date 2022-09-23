return {
	AnalyzeCall = function(self, statement)
		self:AnalyzeExpression(statement.value)
	end,
}
