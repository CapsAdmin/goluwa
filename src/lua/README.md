### [init.lua](init.lua)

This is the init file launched by luajit. The script that launches it looks something like this.
```
cd data/bin/*/
luajit ../../../src/lua/init.lua
```

There are descriptive comments in the init file which tries to explain step by step what's going on.

### [modules/](modules/)

Mostly unmodified standard Lua modules used by goluwa.

### [libraries/](libraries/)

Goluwa specific libraries.

### [main_loop.lua](main_loop.lua)

This contains the main loop which updates Goluwa every frame.

### [examples/](examples/)

As the name implies it contains various example usage. If an example becomes useful/funny/whatever it might get moved to autorun.

### [autorun/](autorun/)

Lua files in this folder are run after everything has been initialized. It contains Lua scripts using the standard libraries.
