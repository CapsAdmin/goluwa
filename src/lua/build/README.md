## simple example:

```lua
local header = ffibuild.BuildCHeader([[
	#define PURPLE_PLUGINS
	#include <libpurple/purple.h>
]], "$(pkg-config purple --cflags)")

local meta_data = ffibuild.GetMetaData(header)

local code = "local CLIB = ffi.load('purple')\n"

code = code .. "local library = {}\n"

for func_name, func_type in pairs(meta_data.functions) do
	local friendly_name = ffibuild.ChangeCase(func_name, "foo_bar", "fooBar")
	code = code .. "library." .. friendly_name .. " = " .. ffibuild.BuildLuaFunction(func_name, func_type) .. "\n"
end

code = code .. "return library\n"
```

This creates a bunch of globals from this_casing to thisCasing based header input.




## ffi.GetMetaData(header)
ffi.GetMetaData returns a table structured like so

```lua
{
	functions = {[function], ...},
	structs = {struct _PurpleAccount = [struct], struct _PurpleBuddy = [struct]},
	unions = {union _PurpleAccount = [union], ...},
	typedefs = {gboolean = [type], gint = [type], ...},
	variables = {[variable], ...},
	enums = {[enums], [enums], [enums]},
	global_enums = {[enums], [enums], [enums]},
} = ffibuild.GetMetaData(header)
```

Where [???] represents a type object.

the returned meta_data also has some functions.

```lua
meta_data:GetStructTypes(pattern) -- returns a table with all structs whose tag matches the pattern
meta_data:FindFunctions(pattern, from, to) -- returns a table with all functions whose name matches the pattern. from and to is just a shortcut for ffibuild.ChangeCase(str, from, to)
meta_data:GetFunctionsStartingWithType(type) -- returns a table with all functions that starts with the type (useful for object functions)
meta_data:BuildMinimalHeader(check_function, check_enum, keep_structs) -- returns a minimal header where check function and enum are used as filters and keep_structs make it so structs are not empty (which might not be useful)
meta_data:BuildFunctions(pattern) -- this builds a table of functions and somewhat automates the first example in this readme
meta_data:BuildEnums(pattern) -- this builds a table of enums. usually in examples enums are built so they can be accessed like library.e.FOO
```


## types
```lua
-- all functions that take meta_data will attempt to get the most primitive type or declaration
string = type:GetDeclaration(meta_data) -- Gets the declaration for the type such as "const char *", "void (*)(int, char)", "enums {FOO=1,BAR=2}", etc
string = type:GetBasicType(meta_data) -- Gets the basic type such as if type:GetDeclaration() would return "const char *" type:GetbasicType() would return "char"
[type] = type:GetPrimitive(meta_data) -- Attempts to get the primitive type.
```

## functions
```lua
func_type:GetDeclaration(as_callback) -- gets the function declaration or as a callback if requested. A function cold also be a callback intitially and so GetDeclaration would return that by default.

if func_type.arguments then
	for arg_pos, type in ipairs(func_type.arguments) do
		-- see type section above
		type.name -- the name of this argument if any
	end
end

func_type.return_type -- the return argument type
```

## trimming the header and evaluating types

In the first example you would get glib functions exported as well since purple uses them internally. This is generally not wanted but you can use `meta_data:BuildMinimalHeader(check_function, check_enum, keep_structs)` where check_function would be a function to find c functions. Based on the functions you need it will return a stripped down header based on the function arguments.

```lua
    local header = meta_data:BuildMinimalHeader(function(name) return name:find("^purple_") end, function(name) return name:find("PURPLE_") end, true)
```

This would return a header with all functions that start with purple_ and the required structs, unions and enums based on what those functions need. The check enum function will just remove any global or typedef enum that don't start with PURPLE_

## todo
Use mingw, visual studio or maybe lcpp on windows somehow.
Don't strip out pragma pack and other compiler specific things
Make struct to table functions
Have a way to make anonymous definitions using typeof and parameterized types
add a way to prefix types for "namespaces" to avoid conflicting libraries
