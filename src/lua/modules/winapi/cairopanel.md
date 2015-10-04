---
tagline: cairo panels
---

## `require'winapi.cairopanel'`

This module implements the `CairoPanel` class which allows drawing
on the panel's surface using [cairo].

## CairoPanel

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [Panel][winapi.panelclass]
					* [BitmapPanel][winapi.bitmappanel]
						* CairoPanel

### Events

<div class=small>
-------------------------------------------- -------------------------------------- -------------------------
__painting__											__description__								__reference__
on_cairo_create_surface(surface)					cairo surface was created
on_cairo_free_surface(surface)					cairo surface will be freed
on_cairo_paint(context)								panel needs repainting						WM_PAINT
-------------------------------------------- -------------------------------------- -------------------------
</div>
