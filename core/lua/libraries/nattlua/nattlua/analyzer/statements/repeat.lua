return {
	AnalyzeRepeat = function(self, statement)
		self:CreateAndPushScope()
		self:AnalyzeStatements(statement.statements)
		self:PopScope()
	end,
}
