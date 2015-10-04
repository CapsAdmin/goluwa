---
tagline: checkboxes
---

## `require'winapi.checkboxclass'`

This module implements the `CheckBox` class for creating checkboxes.

## Button

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [BaseButton][winapi.basebuttonclass]
					* CheckBox

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

checked						irw		true, false, 'indeterminate'					false							BST_UNCHECKED,
																																	BST_CHECKED,
																																	BST_INDETERMINATE

type							irw		'twostate', 'threestate',						'twostate_autocheck'		BS_CHECKBOX,
											'twostate_autocheck', 															BS_3STATE,
											'threestate_autocheck'															BS_AUTOCHECKBOX,
																																	BS_AUTO3STATE
----------------------- -------- ----------------------------------------- ----------------------- ---------------------
</div>
