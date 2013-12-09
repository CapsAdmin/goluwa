Goluwa is an experimental framework written in LuaJIT targeted at games. It includes high level libraries to render graphics, play audio, handle input, networking and much more. 3D is the main interest but 2D is also important.

The coding style is inspired by Garry's Mod, Source Engine and UFO (https://github.com/malkia/ufo).

LuaJit's FFI api is used to bind to the following libraries:


GLFW - window and input handler

OpenAL Soft - sound library

FreeImage - image decoding

FreeType - font decoding

libsnd - sound decoding

pdcurses - console

lfs - additional file functions

luasocket - networking

assimp - model decoding

opengl - graphics


Goluwa also comes with a Love2D wrapper which is used for fun and unit testing.
