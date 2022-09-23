local types = {}

function types.Initialize()
	types.Table = require("nattlua.types.table").Table
	types.Union = require("nattlua.types.union").Union
	types.Nilable = require("nattlua.types.union").Nilable
	types.Tuple = require("nattlua.types.tuple").Tuple
	types.VarArg = require("nattlua.types.tuple").VarArg
	types.Number = require("nattlua.types.number").Number
	types.LNumber = require("nattlua.types.number").LNumber
	types.Function = require("nattlua.types.function").Function
	types.AnyFunction = require("nattlua.types.function").AnyFunction
	types.LuaTypeFunction = require("nattlua.types.function").LuaTypeFunction
	types.String = require("nattlua.types.string").String
	types.LString = require("nattlua.types.string").LString
	types.Any = require("nattlua.types.any").Any
	types.Symbol = require("nattlua.types.symbol").Symbol
	types.Nil = require("nattlua.types.symbol").Nil
	types.True = require("nattlua.types.symbol").True
	types.False = require("nattlua.types.symbol").False
	types.Boolean = require("nattlua.types.union").Boolean
end

return types
