---
tagline: custom-painted child windows
---

## `require'winapi.panelclass'`

This module implements the `Panel` class which is the base class for
custom-painted child windows. `Panel` is useful for both subclassing
and for instantiation.

## Panel

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* Panel

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__appearance__				__irw__	__description__									__default__		__reference__
dropshadow					irw		drop shadow											false				CS_DROPSHADOW
transparent					irw		make transparent									false				WS_EX_TRANSPARENT
__behavior__				__irw__	__description__									__default__		__reference__
own_dc						irw		keep the same HDC									false				CS_OWNDC
receive_double_clicks	irw		receive double click messages					true				CS_DBLCLKS
tabstop						irw		focus on tab										false				WS_TABSTOP
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>
