---
tagline: edit boxes
---

## `require'winapi.editclass'`

This module implements the `Edit` class for creating edit boxes.

## Edit

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* Edit

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
text							irw		text to edit										''					Get/SetWindowText
w, h							irw		size													100, 21
tabstop						irw		focus on tab										true				WS_TABSTOP
border						irw		TODO													false				WS_BORDER
readonly						irw		TODO													false				ES_READONLY
multiline					irw		TODO													false				ES_MULTILINE
password						irw		TODO													false				ES_PASSWORD
autovscroll					irw		TODO													false				ES_AUTOVSCROLL
autohscroll					irw		TODO													false				ES_AUTOHSCROLL
number						irw		TODO													false				ES_NUMBER
dont_hide_selection		irw		TODO													false				ES_NOHIDESEL
want_return					irw		TODO													false				ES_WANTRETURN
align							irw		'left', 'right', 'center'						'left'			ES_LEFT/RIGHT/CENTER
case							irw		'normal', 'uppwer', 'lower'					'normal'			ES_UPPER/LOWERCASE
client_edge					irw		double-border										true				WS_EX_CLIENTEDGE
limit							irw		TODO
password_char							TODO
tabstops									TODO
margins									TODO
cue										TODO
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>


### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_setfocus()							TODO														EN_SETFOCUS
on_killfocus()							TODO														EN_KILLFOCUS
on_change()								TODO														EN_CHANGE
on_update()								TODO														EN_UPDATE
on_errspace()							TODO														EN_ERRSPACE
on_maxtext()							TODO														EN_MAXTEXT
on_hscroll()							TODO														EN_HSCROLL
on_vscroll()							TODO														EN_VSCROLL
on_align_ltr_ec()						TODO														EN_ALIGN_LTR_EC
on_align_rtl_ec()						TODO														EN_ALIGN_RTL_EC
--------------------------------	-------------------------------------------- ---------------------
</div>

