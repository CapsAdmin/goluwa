/* Public Domain Curses */

/* $Id: pdcwin.h,v 1.6 2008/07/13 06:36:32 wmcbrine Exp $ */

#ifdef PDC_WIDE
# define UNICODE
#endif

#include <windows.h>
#undef MOUSE_MOVED
#include <curspriv.h>

# if(CHTYPE_LONG >= 2)     /* 64-bit chtypes */
    # define PDC_ATTR_SHIFT  23
# else
#ifdef CHTYPE_LONG         /* 32-bit chtypes */
    # define PDC_ATTR_SHIFT  19
#else                      /* 16-bit chtypes */
    # define PDC_ATTR_SHIFT  8
#endif
#endif

extern unsigned char *pdc_atrtab;
extern HANDLE pdc_con_out, pdc_con_in;
extern DWORD pdc_quick_edit;

extern int PDC_get_buffer_rows(void);
