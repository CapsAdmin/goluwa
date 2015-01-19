---
project: winapi
tagline: how it came about
---

Here's how the process of binding a subset of winapi for the purpose of
writing a humble Win32 GUI could lead you to write this library in the end.

So you are on Windows and you want to write a GUI. With just the ffi,
the headers from the Windows SDK and the good old MSDN you could bind enough
of winapi to get by. So you start binding and transcribing to Lua the
necessary functions, macros and constants for windows and controls and
messages and all that's needed to get the app off the ground.

Soon you realize some facts about winapi that draw more and more attention
to the binding than to the actual application that you want to write.

Most functions can result in an error but there's different ways in which
they report that (some by a zero result, others with null, others with -1
and so on). When that happens you have to call `GetLastResult` and
`FormatMessageA` every time if you want to get a clue of what happened.
And so you start wrapping the calls.

Windows and most controls must be initialized with good defaults even if
you don't care for them, or your controls will refuse to get created or
you'll get strange display bugs.

You can set multiple properties of existing controls at once via "setinfo"
commands, but you have to specify which properties you want to set values
for using a bitmask field - another artifact of a statically-typed language
and old times when RAM was scarce.

The various "state" fields are bit fields and so they too have a bitmask
that you have to set according to which bits you want to set.

Also some structs have a "cbSize" field that you have to set to the sizeof
the struct every time you create a new one. Other times there's a "version"
field for similar purpose. If you forget this, nothing will be set and you
won't even get an error.

You want to feed the GUI unicode strings. To use string constants from your
source file (which is probably in utf8) you have to bind `MultiByteToWideChar`
and call it on all your string constants and other utf8 strings coming from
different places.

Winapi, like most C APIs counts from 0 so you always have to adjust for that
in your loops which leads to off-by-one bugs.

To set callbacks on individual controls to respond to events you have to
subclass the controls. Then you have to dispatch them by hand, typecasting
for the various different meanings of `wParam` and `lParam`.
It soon becomes clear that for an app with more than a handful of windows
and controls, some sort dispatching system must be devised to allow event
handlers to be set for individual windows, controls and/or event types.
Message decoders must also be written for each event type.

To change the state or behavior of controls after creation you have to
awkwardly send messages to them via `SendMessage`, jamming your values and
structs into `wParam` and `lParam` with lots of typecasting and bit shuffling.
There are macros for these that you can transcribe to Lua, but it's a lot of
grunt work.

In winapi, the objects you create you have to destroy yourself. But when
assigned as children or properties to other objects, the parent takes the
responsibility of destroying them when it is itself destroyed. You want to
prevent memory leaks so you assign the objects a finalizer tied to the
garbage collector, but you are careful to unassign it when the object gets
owned by another object, and assign it back again when it gets disowned.

Now you have windows and controls on the screen and you can respond to
events. But writing GUIs procedural style is tedious to say the least. So you
now have to devise an object system to encapsulate the controls creation,
setting and getting of properties and assigning event handlers. It needs to
have inheritance because you want to reuse the many properties and methods
of similar controls like buttons and checkboxes. Virtual properties that are
read and written to by way of getters and setters would also be nice,
considering the sheer number of those.

Finally, you may remember how Delphi had a simple yet very effective
layouting system based on anchors. Windows doesn't come with that, so you
write that too.

This is more/less where the winapi binding is right now, and this is the
process that got it here. There are still a lot of missing pieces of this
huge API, but there's an infrastructure of utilities and conventions and code
organization in place (which is outlined in the [dev doc]) that makes further
work on the library relatively painless and opens it up for collaboration.

[dev doc]: winapi_binding.html
