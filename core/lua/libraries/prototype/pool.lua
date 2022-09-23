local prototype = ... or _G.prototype
local list_remove = list.remove

function prototype.CreateObjectPool(name)
	return {
		i = 1,
		list = {},
		map = {},
		remove = function(self, obj)
			if not self.map[obj] then
				error("tried to remove non existing object in pool " .. name, 2)
			end

			for i = 1, self.i do
				if obj == self.list[i] then
					list_remove(self.list, i)
					self.map[obj] = nil
					self.i = self.i - 1

					break
				end
			end

			if self.map[obj] then
				error("unable to remove " .. tostring(obj) .. " from pool " .. name)
			end
		end,
		insert = function(self, obj)
			if self.map[obj] then
				error("tried to add existing object to pool " .. name, 2)
			end

			self.list[self.i] = obj
			self.map[obj] = self.i
			self.i = self.i + 1
		end,
		call = function(self, func_name, ...)
			for _, obj in ipairs(self.list) do
				if obj[func_name] then obj[func_name](obj, ...) end
			end
		end,
	}
end