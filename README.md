ASDFML is pretty much SFML bindings for luajit. 
But not quite.. 
It comes with alot of extra library load and it doesn't really follow the csfml style of coding either.

The functions are automatically bound to luajit from by parsing CSFML headers from luajit itself. 

See addons/sfml tests/lua/sfml_tests/* for some example usage.

The coding style is inspired by Garry's Mod Lua.
