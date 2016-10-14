#About
Goluwa is a framework coded in LuaJIT that I use to further develop Goluwa with and satisfy my programming hobby. I don't really have any long term plans so I just code whatever I feel like coding. I'm interested in game engines and middleware for games so Goluwa ends up being something that vaguely resembles a game engine. I constantly refactor and change the api so I wouldn't recommend using Goluwa to make a game or anything like that but I'd be happy if you find code to use or learn from.

![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/goluwa.png)

#Features
* [ffi build system](https://github.com/CapsAdmin/goluwa/tree/master/src/lua/build) to automatically build cdef and lua bindings.
* [gui](src/lua/libraries/graphics/gui) with focus on automatic layout and gwen skin support
* [markup language](src/lua/libraries/graphics/gui) used by gui and chat
* [löve wrapper](src/lua/libraries/lovemu) that lets you run löve games in goluwa
* [glua wrapper](src/lua/libraries/gmod) that lets you run garrysmod lua in goluwa
* [enitity editor](src/lua/autorun/graphics) similar to the [pac3 editor](http://steamcommunity.com/sharedfiles/filedetails/?id=104691717)
* [filesystem](src/lua/libraries/filesystem) with the ability to mount and treat many archive formats as directories 
* all assets can be loaded from the internet using urls.
* fonts can be loaded directly from google webfont, dafont and other places for prototyping.
* lots of model and image formats supported for prototyping. including [source engine formats](src/lua/libraries/steam)
* most code can be reloaded without the need to restart.
* tight integration with zerobrane

I mainly use and develop this on Linux so windows support isn't high priority even though it should work there. It may also work on OSX but I can't test rendering as I'm limited to using mac in a vm.

#Credits
* [Garry Newman](https://github.com/garrynewman/) - I learned programming in garrysmod and many of the ideas and libraries in goluwa were developed in garrysmod initially.
* [Crytek](http://www.crytek.com/) - Playing around with the Crysis Wars SDK was how I started to learn C++. I made [oohh
](https://github.com/capsadmin/oohh) which was a garrysmod-like mod attempt. The C++ Lua binder I made there included a standard game oriented lua library which eventualy evolved into goluwa.
* [Ronny](http://steamcommunity.com/id/76561197990112245/) - Helped me making the gui when it was made for [oohh](https://github.com/CapsAdmin/oohh).
* [Malkia](https://github.com/malkia) - the source inspiration for doing this entirely in luajit was [ufo](https://github.com/malkia/ufo)
* [Morten Erlandsen](https://github.com/mortenae) - Provided help and code with BSP (especially the displacement bit) and supporting linux early on.
* [Leandro Fonseca](https://github.com/Shell64) - Started working on the löve wrapper early on and has helped with explaining how löve works.
* [Somepotato](https://github.com/Someguynamedpie) - Started proper font support using a font atlas.
* [ZeqMacaw](http://steamcommunity.com/id/zeqmacaw) - The source engine MDL decoding code was based on the [CrowbarTool](http://steamcommunity.com/groups/CrowbarTool)
