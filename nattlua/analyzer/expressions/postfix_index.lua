return {
	AnalyzePostfixIndex = function(self, node)
		return self:Assert(
			self:IndexOperator(
				self:AnalyzeExpression(node.left):GetFirstValue(),
				self:AnalyzeExpression(node.expression):GetFirstValue()
			)
		)
	end,
}