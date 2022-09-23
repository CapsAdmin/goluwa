return {
	AnalyzePostfixIndex = function(self, node)
		return self:Assert(
			self:IndexOperator(
				self:AnalyzeExpression(node.left),
				self:AnalyzeExpression(node.expression):GetFirstValue()
			)
		)
	end,
}
