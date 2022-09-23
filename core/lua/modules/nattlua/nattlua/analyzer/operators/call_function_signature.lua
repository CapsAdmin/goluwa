local ipairs = ipairs
local type_errors = require("nattlua.types.error_messages")
return function(META)
	function META:CallFunctionSignature(obj, input)
		do
			local ok, reason, a, b, i = input:IsSubsetOfTuple(obj:GetInputSignature())

			if not ok then
				return type_errors.subset(a, b, {"argument #", i, " - ", reason})
			end
		end

		for i, arg in ipairs(input:GetData()) do
			if arg.Type == "table" and arg:GetAnalyzerEnvironment() == "runtime" then
				if self.config.external_mutation then
					self:Warning(
						{
							"argument #",
							i,
							" ",
							arg,
							" can be mutated by external call",
						}
					)
				end
			end
		end

		local ret = obj:GetOutputSignature():Copy()

		-- clear any reference id from the returned arguments
		for _, v in ipairs(ret:GetData()) do
			if v.Type == "table" then v:SetReferenceId(nil) end
		end

		return ret
	end
end
