---
tagline: base class for controls
---

## `require'winapi.controlclass'`

This module implements the `Control` class which is the base class for
controls. `Control` is for subclassing, not for instantiation.
Nevertheless, it contains properties that are common to all controls
which are documented here.

## Control

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* Control

### Initial fields and properties

<div class=small>

__NOTE:__ in the table below `i` means initial field, `r` means property
which can be read, `w` means property which can be set.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
anchors						irw		anchors												see below
anc							ire		anchors (string form)							see below
parent						irw		control's parent														Get/SetParent
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>

### Anchors

Anchors are a simple but very powerful way of doing layouting.
This is how they work: there's four possible anchors,
one for each side of a control.
Setting an anchor on one side fixates the distance between that side
and the same side of the parent control, so that when the parent is
moved/resized, the child is also moved/resized in order to preserve
the initial distance. With anchors alone you can define pretty much
every elastic layout that you see in typical desktop apps and you can
do that without having to be explicit about the relationships
between controls or having to specify percentages.

The default value of `anchors` is `{left = true, top = true}`.

Anchors can also be set and read in short form using the `anc` property:
each anchored side is represented by one of the letters 'ltrb'
(the default value of `anc` is thus 'lt': `anc` always reflects
the value of `anchors`).
