ffi.cdef[[
	/* Type declarations. */
	typedef struct {
	  int	   _cury;			/* current pseudo-cursor */
	  int	   _curx;
	  int      _maxy;			/* max coordinates */
	  int      _maxx;
	  int      _begy;			/* origin on screen */
	  int      _begx;
	  int	   _flags;			/* window properties */
	  int	   _attrs;			/* attributes of written characters */
	  int      _tabsize;			/* tab character size */
	  bool	   _clear;			/* causes clear at next refresh */
	  bool	   _leave;			/* leaves cursor as it happens */
	  bool	   _scroll;			/* allows window scrolling */
	  bool	   _nodelay;			/* input character wait flag */
	  bool	   _keypad;			/* flags keypad key mode active */
	  int    **_line;			/* pointer to line pointer array */
	  int	  *_minchng;			/* First changed character in line */
	  int	  *_maxchng;			/* Last changed character in line */
	  int	   _regtop;			/* Top/bottom of scrolling region */
	  int	   _regbottom;
	} WINDOW;


	typedef void* WINDOW;
	WINDOW *initscr();
	void timeout(int delay);
	int wtimeout(WINDOW *win, int delay);
	void halfdelay(int delay);
	void cbreak();
	void nocbreak();
	void noecho();
	int getch();
	int wgetch(WINDOW *win);
	
	int idlok(WINDOW *win, bool bf);
	int leaveok(WINDOW *win, bool bf);
	int keypad(WINDOW *win, bool bf);
	int scrollok(WINDOW *win, bool bf);

	int nodelay(WINDOW *win, bool b);
	int notimeout(WINDOW *win, bool b);
	WINDOW *derwin(WINDOW*, int nlines, int ncols, int begin_y, int begin_x);
	int wrefresh(WINDOW *win);
	int box(WINDOW *win, int, int);
	int werase(WINDOW *win);
	int hline(const char *, int);
	int COLS;   
	int LINES;
	const char *killchar();
	void keypad(WINDOW*, bool);
	const char *keyname(int c);
	int waddstr(WINDOW *win, const char *chstr);
	int wmove(WINDOW *win, int y, int x);
]]

local dll = ffi.load("pdcurses")

local main = dll.initscr()
local window = dll.derwin(main, 1,128,dll.LINES-1,0)
dll.cbreak()
dll.nodelay(window, true)
dll.wrefresh(window)
dll.keypad(window, true);

--dll.scrollok(window, true);
--dll.leaveok(window, true);
--dll.idlok(window, true);
--dll.keypad(window, true);

local curses = {}

curses.timeout = dll.timeout
curses.getch = function() return dll.wgetch(window) end
curses.clear = function(str) 
	local y, x = window._cury, window._curx
	dll.werase(window) 
	if str then 
		dll.waddstr(window, str) 
	end 
	if str then
		dll.wmove(window, y, x) 
	else
		dll.wmove(window, y, 0) 
	end
	dll.wrefresh(window) 
end
curses.backspace = function() return dll.killchar() end
curses.keyname = function(num) return dll.keyname(num) end
curses.move = function(y, x)
	return dll.wmove(window, window._cury + y, window._curx + x) 
end
curses.setpos = function(y, x) 
	return dll.wmove(window, y, x) 
end
curses.getx = function() return window._curx end

return curses