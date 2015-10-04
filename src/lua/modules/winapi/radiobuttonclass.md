---
tagline: radio buttons
---

## `require'winapi.radiobuttonclass'`

This module implements the `RadioButton` class for creating radio buttons.

## RadioButton

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [BaseButton][winapi.basebuttonclass]
					* RadioButton

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- ----------------------- ---------------------
__field/property__		__irw__	__description__									__default__					__reference__
text							irw		checkbox's label									'Option'						Get/SetWindowText
w, h							irw		size													100, 24
box_align					irw		'left', 'right'									'left'						BS_LEFTTEXT
pushlike						irw		push-like appearance								false							BS_PUSHLIKE
checked						irw		true, false											false							BST_(UN)CHECKED
autocheck					irw		automatic checking based on group			true							BS_(AUTO)RADIOBUTTON
dontclick					w			make not clickable (Vista+)													BM_SETDONTCLICK
----------------------- -------- ----------------------------------------- ----------------------- ---------------------
</div>
