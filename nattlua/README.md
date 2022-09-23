# The steps involved turning NattLua code into Lua are:

## Syntax
Sets up the base syntax for the lexer and parser. Language constructs such as keywords, operators, operator precedence, etc are defined here.

## Lexer
Used to create tokens from code. Each token can also contain whitespace.

## Parser 
Parses the lua code into an AST (abstract syntax tree).

## Analyzer
An optional step which traverses the AST and runs type checking on it.

uses nattlua/definitions/index.nlua for its base types

## Transpiler
Emits the lua code ready to be executed along with runtime.lua


# Other

## types
Algebraic types in library form that the analyzer uses.

## Runtime
Includes the base type definitions
