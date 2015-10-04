---
tagline: text labels
---

## `require'winapi.labelclass'`

This module implements the `Label` class for creating text labels.

## Label

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* Label

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__

align							irw		'left', 'center', 'right', 					'left'			SS_LEFT, SS_CENTER,
											'simple', 'left_nowrap' 											SS_RIGHT, SS_SIMPLE,
																														SS_LEFTNOWORDWRAP

accelerator_prefix		irw		don't do "&" character translation			true				SS_NOPREFIX

events						irw		enable events										true				SS_NOTIFY

owner_draw					irw		owner drawn											false				SS_OWNERDRAW

simulate_edit				irw		display text like an edit would				false				SS_EDITCONTROL

ellipsis									false, 'char', 'path', 'word'					false				SS_ENDELLIPSIS,
																														SS_PATHELLIPSIS,
																														SS_WORDELLIPSIS


text							irw		the text to display								'Text'			Get/SetWindowText

w, h							irw		size													100, 21
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>

### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_click()								clicked													STN_CLICKED
on_double_click()						double-clicked											STN_DBLCLK
on_enable()								was enabled												STN_ENABLE
on_disable()							was disabled											STN_DISABLE
--------------------------------	-------------------------------------------- ---------------------
</div>
