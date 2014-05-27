##init.lua##
This is the init file launched by luajit (luajit ../../../lua/init.lua)

1. All the basic functions needed are created (logging functions, _G.include, etc) 
2. all the all the libraries in /libraries are opened. 
3. The main_loop file is opened.

There are descriptive comments in the init file which tries to explain step by step what's going on.

##main_loop.lua##
This contains the main loop which updates Goluwa every frame using libraries/event.lua.

##libraries/##
Contains all the Goluwa libraries.

##modules/##
Contains all the standard Lua modules. 

Modules prefixed with lj- are ffi bindings made for Goluwa. They may not work outside of Goluwa yet.
