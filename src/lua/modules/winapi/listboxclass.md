---
tagline: list boxes
---

## `require'winapi.listboxclass'`

This module implements the `ListBox` class for creating list boxes.

## ListBox

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* ListBox

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
w, h							irw		size													100, 100
border						irw		TODO													false				WS_BORDER
sort							irw		sort items											false				LBS_SORT
select						irw		'single', 'multiple', 'extended'				'single'			LBS_MULTIPLE/EXTENDEDSEL
tabstops						irw		focus on tab										false				LBS_USETABSTOPS
free_height					irw		TODO													true				LBS_NOINTEGRALHEIGHT
multicolumn					irw		TODO													false				LBS_MULTICOLUMN
vscroll						irw		show vertical scrollbar							true				WS_VSCROLL
hscroll						irw		show horizontal scrollbar						true				WS_HSCROLL
always_show_scrollbars	irw		always show scrollbars							true				LBS_DISABLENOSCROLL
hextent						irw		horizontal extent									0					LB_GET/SETHORIZONTALEXTENT
allow_select				irw		allow select										true				LBS_NOSEL
client_edge					irw		bordered												true				WS_EX_CLIENTEDGE
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>


### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_memory_error()						TODO														LBN_ERRSPACE
on_select()								TODO														LBN_SELCHANGE
on_double_click()						TODO														LBN_DBLCLK
on_cancel()								TODO														LBN_SELCANCEL
on_focus()								TODO														LBN_SETFOCUS
on_blur()								TODO														LBN_KILLFOCUS
--------------------------------	-------------------------------------------- ---------------------
</div>

