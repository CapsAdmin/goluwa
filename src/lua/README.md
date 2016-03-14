### [autorun/](autorun/)

Lua files in this folder are run after everything has been initialized. It contains Lua scripts using the standard libraries.

### [libraries/](libraries/)

Goluwa specific libraries.

### [modules/](modules/)

Mostly unmodified standard Lua modules used by goluwa.

### [init.lua](init.lua)

This is the init file launched by luajit. The script that launches it looks something like this.
```
cd data/bin/*/
luajit ../../../src/lua/init.lua
```

There are descriptive comments in the init file which tries to explain step by step what's going on.

### [main_loop.lua](main_loop.lua)

This contains the main loop which updates Goluwa every frame.
