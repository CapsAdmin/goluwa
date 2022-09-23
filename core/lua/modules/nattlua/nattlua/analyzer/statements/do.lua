return {
	AnalyzeDo = function(self, statement)
		self:CreateAndPushScope()
		self:AnalyzeStatements(statement.statements)
		self:PopScope()
	end,
}
