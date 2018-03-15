# About

Goluwa is a game engine, framework, a collection of utilities and experiments written in [LuaJIT](http://luajit.org/) leveraging FFI.


![ScreenShot](https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/screenshots/goluwa.png)

# Features
* [ffi build system](framework/lua/build) to automatically build LuaJIT ffi bindings.
* [gui](engine/lua/libraries/graphics/gui) with focus on automatic layout and [GWEN](!https://github.com/garrynewman/GWEN) skin support
* [font effects](framework/lua/libraries/graphics/fonts) to create outlined, shadowed, etc text.
* [markup language](engine/lua/libraries/graphics/gfx)
* [löve wrapper](game/lua/libraries/love) that lets you run Löve games in Goluwa
* [glua wrapper](game/lua/libraries/gmod) that lets you run GarrysMod Lua in Goluwa
* [entity editor](game/lua/autorun/graphics) similar to [PAC3's editor](http://steamcommunity.com/sharedfiles/filedetails/?id=104691717)
* [filesystem](core/lua/libraries/filesystem) with the ability to mount and treat many archive formats as directories
* [source engine](engine/lua/libraries/steam) formats are supported

##### Prototyping
* all resources can be loaded from the internet with urls
* fonts can be loaded directly from google webfont, dafont and other places
* many model, image and sound formats are supported
* most code can be reloaded without the need to restart
* integration with zerobrane

# Structure
Goluwa is split into 4 directories. ```core > framework > engine > game```. Going backwards, each directory depends on the previous directory, so if you delete the engine directory the game directory wont load.

##### -1. goluwa|.cmd
The shell and powershell script that will only download and launch luajit|.exe with core/lua/boot.lua
##### 0. core/lua/boot.lua
Responsible for downloading other binaries, the zerobrane ide, updating goluwa with or without git and launching goluwa. It's mostly lua but some of its helper functions use shell and powershell.
##### 1. Core
Contains the barebone framework that has no explicit dependencies on any external shared libraries.
##### 2. Framework
The basic framework utilizing sdl, opengl, openal, etc but does not implement anything. It has a renderer which is neither 2d or 3d, game math library, high level socket library, 2d rendering library, etc.
##### 3. Engine
The engine contains a 3d renderer, source engine asset compatibility, steam integration, zerobrane integration, networking, entities, gui, markup language, etc.
##### 4. Game
The game folder contains very high level scripts such as Löve2D implemented in goluwa, GarrysMod Lua implemented in goluwa, chatsounds, chatbox, scoreboard, player movement, etc.

# Caveats

While I want to support OSX and Windows they become low priority due to lack of windows and osx machines. I try to test goluwa in a VM and ask friends but that's about as much as I can do.

Writing everything in LuaJIT also comes with some challenges. I try to write JIT compilable code, especially in areas that are intensive but this is not always easy without resorting to ugly code which I try to avoid.

# Credits
* [Garry Newman](https://github.com/garrynewman/) - I learned programming in garrysmod and many of the ideas and libraries in goluwa were developed in garrysmod initially.
* [Crytek](http://www.crytek.com/) - Playing around with the Crysis Wars SDK was how I started to learn C++. I made [oohh
](https://github.com/capsadmin/oohh) which was a garrysmod-like mod attempt. The C++ Lua binder I made there included a standard game oriented lua library which eventualy evolved into goluwa.
* [Ronny](http://steamcommunity.com/id/76561197990112245/) - Helped me making the gui when it was made for [oohh](https://github.com/CapsAdmin/oohh).
* [Malkia](https://github.com/malkia) - the source inspiration for doing this entirely in luajit was [ufo](https://github.com/malkia/ufo)
* [Morten Erlandsen](https://github.com/mortenae) - Provided help and code with BSP (especially the displacement bit) and supporting linux early on.
* [Leandro Fonseca](https://github.com/Shell64) - Started working on the löve wrapper early on and has helped with explaining how löve works.
* [Somepotato](https://github.com/Someguynamedpie) - Started proper font support using a font atlas.
* [ZeqMacaw](http://steamcommunity.com/id/zeqmacaw) - The source engine MDL decoding code was based on the [CrowbarTool](http://steamcommunity.com/groups/CrowbarTool)
