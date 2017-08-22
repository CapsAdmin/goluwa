
do -- tree
	local META = prototype.CreateTemplate("tree")

	function META:SetEntry(str, value)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if type(next[key]) ~= "table" then
					next[key] = {}
				end
				next = next[key]
			end
		end

		next.key = str
		next.value = value
	end

	function META:GetEntry(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "key ".. key .." not found"
				end
				next = next[key]
			end
		end

		return next.value
	end

	function META:GetChildren(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "not found"
				end
				next = next[key]
			end
		end

		return next
	end

	META:Register()

	function utility.CreateTree(delimiter, tree)
		local self = META:CreateObject()

		self.tree = tree or {}
		self.delimiter = delimiter

		return self
	end
end
