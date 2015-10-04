---
tagline: group boxes
---

## `require'winapi.groupboxclass'`

This module implements the `GroupBox` class for creating group boxes.

## GroupBox

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [BaseButton][winapi.basebuttonclass]
					* GroupBox

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- ----------------------- ---------------------
__field/property__		__irw__	__description__									__default__					__reference__
text							irw		group box's title									'Group'						Get/SetWindowText
w, h							irw		size													200, 100
tabstop						irw		focus on tab										false							WS_TABSTOP
align							irw		'left', 'right', 'center'						'left'						BS_LEFT/RIGHT/CENTER
flat							irw		flat appearance									false							BS_FLAT
----------------------- -------- ----------------------------------------- ----------------------- ---------------------
</div>
