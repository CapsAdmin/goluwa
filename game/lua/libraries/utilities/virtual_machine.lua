do
	local META = {}
	META.__index = META

	do
		local INSTR = {}

		do
			local function generic(op)
				return loadstring([[
					return function(self)
						local b, a = self:Pop(), self:Pop()
						self:Push(a ]] .. op .. [[ b)
					end
				]])()
			end

			INSTR.add = generic("+")
			INSTR.sub = generic("-")
			INSTR.mul = generic("*")
			INSTR.div = generic("/")
			INSTR.pow = generic("^")
			INSTR.mod = generic("%")
			INSTR.concat = generic("..")

			INSTR.index = function(self) local b, a = self:Pop(), self:Pop() self:Push(a[b]) end
			INSTR.newindex = function(self) local c, b, a = self:Pop(), self:Pop(), self:Pop() a[b] = c end

			INSTR.unary_minus = function(self) self:Push(-self:Pop()) end
			INSTR.unary_length = function(self) self:Push(#self:Pop()) end

			INSTR.logic_and = generic("and")
			INSTR.logic_or = generic("or")
			INSTR.logic_not = function(self) self:Push(not self:Pop()) end

			INSTR.less = generic("<")
			INSTR.greater = generic(">")
			INSTR.equal = generic("==")
			INSTR.not_equal = generic("~=")

			INSTR.greater_or_equal = generic(">=")
			INSTR.less_or_equal = generic("<=")
		end

		function INSTR:jump_if_true()
			local addr = self.code[self.ip]
			self.ip = self.ip + 1

			if self.stack[self.sp] == true then
				self.ip = addr
			end

			self.sp = self.sp - 1
		end

		function INSTR:jump_if_false()
			local addr = self.code[self.ip]
			self.ip = self.ip + 1

			if self.stack[self.sp] == false then
				self.ip = addr
			end

			self.sp = self.sp - 1
		end

		function INSTR:jump()
			self.ip = self.code[self.ip]
		end

		function INSTR:value()
			self:Push(self.code[self.ip])
			self.ip = self.ip + 1
		end

		do
			local function load(self, tbl)
				local val = self.code[self.ip]
				self.ip = self.ip + 1
				self.sp = self.sp + 1

				self.stack[self.sp] = tbl[val]
			end

			local function store(self, tbl)
				local val = self.code[self.ip]
				self.ip = self.ip + 1

				tbl[val] = self.stack[self.sp]
				self.sp = self.sp - 1
			end

			function INSTR:local_load() load(self, self.ctx.locals) end
			function INSTR:local_store() store(self, self.ctx.locals) end

			function INSTR:global_load() load(self, self.globals) end
			function INSTR:global_store() store(self, self.globals) end
		end

		function INSTR:pop() self.sp = self.sp - 1 end

		function INSTR:call()
			local findex = self.code[self.ip]
			self.ip = self.ip + 1


			local nargs = self.metadata[findex].args

			self.ctx = {prev_context = self.ctx, return_ip = self.ip, metadata = self.metadata[findex], locals = {}}

			local firstarg = self.sp - nargs + 1

			for i = 1, nargs do
				self.ctx.locals[i] = self.stack[firstarg + i - 1]
			end

			self.sp = self.sp - (nargs - 1)
			self.ip = self.metadata[findex].address
		end

		function INSTR:ret()
			self.ip = self.ctx.return_ip
			self.ctx = self.ctx.prev_context
		end

		function INSTR:print()
			print(self.stack[self.sp])
			self.sp = self.sp - 1
		end

		function INSTR:halt() print("halt") end

		META.Instructions = INSTR
	end

	function META:Pop()
		local val = self.stack[self.sp]
		self.sp = self.sp - 1
		return val
	end

	function META:Push(val)
		self.sp = self.sp + 1
		self.stack[self.sp] = val
	end

	function META:Run()
		local opcode = self.code[self.ip]

		self.ctx = {prev_context = nil, return_ip = 1, metadata = self.metadata[1], locals = {}}
		self.ip = 1

		while opcode ~= "halt" do
			self.ip = self.ip + 1

			if not self.Instructions[opcode] then
				error(opcode .. "is not a defined instruction!")
			end

			self.Instructions[opcode](self)

			opcode = self.code[self.ip]
		end
	end

	function utility.CreateVirtualMachine(code, metadata)
		local self = setmetatable({}, META)
		self.code = code
		self.ip = 1
		self.sp = 0

		self.globals = {}
		self.stack = {}

		self.metadata = metadata or {}
		return self
	end
end

if RELOAD then
	do
		local code = {
			-- function main()
				-- print(f(10))
				"value", 10,
				"call", 2,
				"print",
				"halt",
			-- end

			-- function f(x) (ARGS=1, LOCALS=1)
				-- local a = x;
					"local_load", 1,
					"local_store", 2,

				-- return 2*a
					"local_load", 2,
					"value", 2,
					"mul",
					"ret"
			-- end
		};

		local vm = VirtualMachine(code, {
			{name = "main", address = 1,},
			{name = "f", address = 7, args = 1,}
		})
		vm:Run()
	end

	do
		local code = {
			-- function main()
				-- _G.N = 10
				"value", 10,
				"global_store", "N",

				-- _G.I = 0
				"value", 0,
				"global_store", "I",

				--while I < N do -- ADDRESS: 9
					"global_load", "I",
					"global_load", "N",
					"less",
					"jump_if_false", 28, -- end of main

					"global_load", "I",
					"value", 1,
					"add",
					"global_store", "I",

					"global_load", "I",
					"print",
				"jump", 9,

			"halt", -- ADDRESS: 25
		}

		local vm = VirtualMachine(code, {
			{name = "main", address = 1,}
		})
		vm:Run()
	end

end