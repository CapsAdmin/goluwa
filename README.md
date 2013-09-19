Goluwa is a game engine (3d) written in LuaJIT. It uses LuaJIT's FFI api to bind OpenGL and all the available extensions.

A lot of the low level libraries are made by parsing header data. So functions like "FT_Set_Char_Index" become "freetype.SetCharIndex" automatically to keep the style consistent.

The coding style is inspired by Garry's Mod (so also Source Engine), CryEngine and SFML.
