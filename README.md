Goluwa is a 3d "engine" written in Lua. It uses LuaJIT's FFI api to bind OpenGL and all the availible extensions.
The coding style is inspired by Garry's Mod (so also Source Engine) and CryEngine.

Here's a list of some of the libraries:

non lua modules (ffi):
	gl 			- rendering
	glfw 		- window and input manager
	ftgl 		- font rendering using freetype
	freeimage 	- image loading
	pdcurses 	- for non blocking console input on windows. ncurses is used on linux

lua modules:
	luasocket 	- sockets
	lfs 		- additional file system operations
	
standard:

	luasocket 	- a high level and non blocking wrapper for luasocket
	timer		- timers..
	event		- event manager (similar to _G.hook in gmod)
	vfs 		- virtual file system
	luadata 	- like json but using lua instead
	input		- used to setup and unify keyboard, mouse and joystick events
	console		- handles high level console commands and persistent console variables
	
goluwa:
	render 		- used to help and simplify opengl rendering
	surface 	- used for drawing 2d shapes

	players		- a player object if networking is used
	network		- handles hosting a server and connecting to server
	message		- to handle high level messages (similar to usermessage or net in gmod)
	nvars		- handles persistent variables in players (similar to ent.dt in gmod)
	chat		- for chatting between players and server

constructors:
	Mesh		- mesh object which takes mesh data (similiar to Mesh in gmod)
	Window		- to create a window
	Font		- to create fonts
	
ffi structs:
	Vec3
	Vec2
	Ang3
	Color
	Matrix34
	Matrix44
	Quat
	Rect	