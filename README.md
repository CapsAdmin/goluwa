Goluwa is an experimental game engine/framework/personal toolbox written in LuaJIT targeted at games. It includes high level libraries to render graphics, play audio, handle input, networking and much more. 3D is the main interest but 2D is also important.

The coding style is inspired by Garry's Mod, Source Engine. UFO (https://github.com/malkia/ufo) gave me the idea and motivation.

I can't guarantee that Goluwa will run out of box if you download it at the moment. There is a BitSync version that I could invite you to if you're interested but that means you'll have to contact me.

My goal with this isn't very clear either. I just like to code.

LuaJit's FFI api is used to bind to the following shared libraries:

* OpenGL - graphics
* GLFW - window and input handler
* OpenAL Soft - sound library
* FreeType - font decoding
* Libsndfile - sound decoding
* FreeImage - image decoding
* FFMpeg - sound decoding (mp3)
* VTFLib - image decoding (valves texture format)
* PDCurses - console
* Assimp - model decoding
* steamfriends - steam friends communication

Goluwa also has a Love2D wrapper which is used for fun and unit testing for 2D graphics.

![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-19-17.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-19-30.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-20-26.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-21-03.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-28-32.png)
