---
tagline: push-buttons
---

## `require'winapi.buttonclass'`

This module implements the `Button` class for creating buttons.

## Button

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [BaseButton][winapi.basebuttonclass]
					* Button

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
text							irw		button's label										'&OK'				Get/SetWindowText
w, h							irw		size													100, 24
text_margin					irw		margins that go with `autosize`				{20,5}			BCM_GET/SETTEXTMARGIN
autosize						irw		set size based on text							false
pushed						irw		pushed state															BM_GET/SETSTATE
ideal_size					r			get ideal size for text (`{w=, h=}`)							BCM_GETIDEALSIZE
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>
