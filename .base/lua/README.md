##init.lua##
This is the init file launched by luajit.exe (luajit.exe ../../../lua/init.lua) First it will create the basic functions needed (logging functions, include functions, etc) and then it includes and initializes all the libraries in /libraries. Then the main_loop file is opened.

I've tried to make descriptive comments in the init file to explain what happens step by step so if you need more info check out its source.

##main_loop.lua##
This contains the main loop which updates golwa every frame using the event and timer system.