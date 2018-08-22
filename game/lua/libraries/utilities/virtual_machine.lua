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
			local addr = self.current_function[self.ip]
			self.ip = self.ip + 1

			if self.stack[self.sp] == true then
				self.ip = addr
			end

			self.sp = self.sp - 1
		end

		function INSTR:jump_if_false()
			local addr = self.current_function[self.ip]

			if addr == "EOF" then
				addr = #self.current_function
			end

			self.ip = self.ip + 1

			if self.stack[self.sp] == false then
				self.ip = addr
			end

			self.sp = self.sp - 1
		end

		function INSTR:jump()
			self.ip = self.current_function[self.ip]
		end

		function INSTR:push_jump()
			self.pushed_ip = self.ip
		end

		function INSTR:pop_jump()
			self.ip = self.pushed_ip
		end

		function INSTR:value()
			self:Push(self.current_function[self.ip])
			self.ip = self.ip + 1
		end

		do
			local function load(self, tbl)
				local val = self.current_function[self.ip]
				self.ip = self.ip + 1
				self.sp = self.sp + 1

				self.stack[self.sp] = tbl[val]
			end

			local function store(self, tbl)
				local val = self.current_function[self.ip]
				self.ip = self.ip + 1

				tbl[val] = self.stack[self.sp]
				self.sp = self.sp - 1
			end

			function INSTR:local_load() load(self, self.current_function.locals) end
			function INSTR:local_store() store(self, self.current_function.locals) end

			function INSTR:global_load() load(self, self.globals) end
			function INSTR:global_store() store(self, self.globals) end
		end

		function INSTR:pop() self.sp = self.sp - 1 end

		function INSTR:call()
			local func_name = self.current_function[self.ip]
			local arg_count = self.ip + 1

			self.prev_function = self.current_function
			self.return_ip = self.ip + 2

			self.current_function = self.functions[func_name]
			self.ip = 1
		end

		function INSTR:ret()
			self.ip = self.return_ip
			self.current_function = self.prev_function
		end

		function INSTR:move()
			for i = #self.stack, 1 + #self.stack - self.current_function[self.ip], -1 do
				self:Push(self.stack[i])
			end
			self.ip = self.ip + 1
		end

		function INSTR:print()
			table.print(self.stack)
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
		local opcode = self.current_function[self.ip]

		self.ip = 1

		while opcode ~= "halt" do
			self.ip = self.ip + 1

			if not self.Instructions[opcode] then
				error(opcode .. "is not a defined instruction!")
			end

			self.Instructions[opcode](self)

			opcode = self.current_function[self.ip]
		end
	end

	function utility.CreateVirtualMachine(functions)

		assert(functions.main, "no main function")

		local self = setmetatable({}, META)
		self.functions = functions
		self.current_function = self.functions.main

		self.ip = 1
		self.sp = 0

		self.globals = {}
		self.stack = {}

		return self
	end
end

if RELOAD then
	do
		local code = {
			f = {
				"move", 1,

				"value", 2, "mul",

				"ret", 1
			},
			main = {
				"value", 10,
				"call", "f", 1,

				"print",

				"halt",
			},
		}

		local vm = utility.CreateVirtualMachine(code)
		vm:Run()
	end

	if false then
		local code = {
			main = {
				-- function main()
					-- _G.N = 10
					"value", 10, "global_store", "N",

					-- _G.I = 0
					"value", 0, "global_store", "I",

					--while I < N do -- ADDRESS: 9
					"push_jump",
						"global_load", "I", "global_load", "N", "less",
						"jump_if_false", "EOF",

						"global_load", "I",
						"value", 1, "add",
						"global_store", "I",

						"value", "I: ",
						"global_load", "I",
						"concat",
						"print",
					"pop_jump",

				"halt",
			}
		}

		local vm = utility.CreateVirtualMachine(code)
		vm:Run()
	end

end