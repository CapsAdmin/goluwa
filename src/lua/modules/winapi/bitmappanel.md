---
tagline: RGBA bitmap panels
---

## `require'winapi.bitmappanel'`

This module implements the `BitmapPanel` class which allows
accessing a panel's pixels as an bgra8-type [bitmap] with
pre-multiplied alpha.

## BitmapPanel

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [Panel][winapi.panelclass]
					* BitmapPanel

### Events

<div class=small>
-------------------------------------------- -------------------------------------- -------------------------
__painting__											__description__								__reference__
on_bitmap_create(bitmap)							bitmap was created
on_bitmap_free(bitmap)								bitmap will be freed
on_bitmap_paint(bitmap)								panel needs repainting						WM_PAINT
-------------------------------------------- -------------------------------------- -------------------------
</div>
