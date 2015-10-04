---
tagline: combo boxes and drop-down lists
---

## `require'winapi.comboboxclass'`

This module implements the `ComboBox` class for creating combo boxes
and drop-down lists.

## ComboBox

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* ComboBox

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
w, h							irw		size													100, 100
tabstop						irw		focus on tab										true				WS_TABSTOP
type							irw		'simple', 'dropdown', 'dropdownlist'		'simple'			CBS_SIMPLE/DROPDOWN/DROPDOWNLIST
autohscroll					irw		auto horizontal scroll							true				CBS_AUTOHSCROLL
vscroll						irw		always show vertical scroll 					false				CBS_DISABLENOSCROLL
fixedheight					irw		fixed height										false				CBS_NOINTEGRALHEIGHT
sort							irw		sort items											false				CBS_SORT
case_sensitive				irw		'normal', 'upper', 'lower'						'normal'			CBS_UPPER/LOWERCASE
__dropdowns__
no_edit_image				irw		TODO																		CBES_EX_NOEDITIMAGE
no_edit_image2				irw		TODO																		CBES_EX_NOEDITIMAGEINDENT
path_word_break			irw		TODO																		CBES_EX_PATHWORDBREAKPROC
no_size_limit				irw		TODO																		CBES_EX_NOSIZELIMIT
case_sensitive				irw		TODO																		CBES_EX_CASESENSITIVE
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>


### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_memory_error()						TODO														CBN_ERRSPACE
on_selection_change()				TODO														CBN_SELCHANGE
on_double_click()						TODO														CBN_DBLCLK
on_focus()								TODO														CBN_SETFOCUS
on_blur()								TODO														CBN_KILLFOCUS
on_edit_change()						TODO														CBN_EDITCHANGE
on_edit_update()						TODO														CBN_EDITUPDATE
on_dropdown()							TODO														CBN_DROPDOWN
on_closeup()							TODO														CBN_CLOSEUP
on_select()								TODO														CBN_SELENDOK
on_cancel()								TODO														CBN_SELENDCANCEL
--------------------------------	-------------------------------------------- ---------------------
</div>
