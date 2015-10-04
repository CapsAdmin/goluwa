---
tagline: base class for button-like controls
---

## `require'winapi.basebuttonclass'`

This module implements the `BaseButton` class which is the base class
for buttons and button-like controls. `BaseButton` is for subclassing,
not for instantiation. Nevertheless, it contains properties and methods
that are common to all buttons and button-like controls which are
documented here.

## BaseButton

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* BaseButton

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
tabstop						irw		focus on tab										true				WS_TABSTOP
halign						irw		horiz. align: 'left', 'right', 'center'						BS_LEFT,...
valign 						irw		vert. align: 'top', 'bottom', 'center'							BS_TOP,...
word_wrap					irw		word wrapping															BS_MULTILINE
flat							irw		flat appearance														BS_FLAT
double_clicks				irw		enable double-click events											BS_NOTIFY
image_list					irw		see below (*)															BCM_SETIMAGELIST
icon							irw		icon																		BM_SETIMAGE
bitmap						irw		bitmap																	BM_SETIMAGE
----------------------- -------- ----------------------------------------- -------------- ---------------------

(*) the `image_list` property is a table with the fields:

	* `image_list`: a `HIMAGELIST`
	* `align`: 'left', 'right', 'top', 'bottom', 'center'
	* `margin`: the margin around the image

</div>

### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_click()								clicked													BN_CLICKED
on_double_click()						double clicked											BN_DOUBLECLICKED
on_focus()								focused													BN_SETFOCUS
on_blur()								unfocused												BN_KILLFOCUS
--------------------------------	-------------------------------------------- ---------------------
</div>
