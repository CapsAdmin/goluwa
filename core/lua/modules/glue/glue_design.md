---
title:    design of glue
project:  glue
tagline:  how and why
---

## Scope

A small, highly useful bag of tricks.

This API must be _compact, not complete_. This is the one API that should fit comfortably in someone's head. Adding rarely used or too specialized functions is thus harmful.

_Every_ function should come with compelling real-world examples in its defense. In fact, the library should only be permitted to grow from real-world examples which should be used to document and justify the inclusions.

## Naming

The idea is to find the most popular, familiar and _short_ names for _each and every_ function (no underscores and no capitals). Python gets this right, so does UNIX. A function with an unheard of name or alien semantics will be avoided. People rather recall known names/semantics rather than learn unfamiliar new names/semantics.

For non-obvious O(n) operations, use verbs to emphasize the process rather than the result, eg. `scan(t,e)` not `indexof(e,t)`, `count(t)` not `size(t)`.

## Semantics

They follow the general [api-design] rules.

### Objects vs glue

Don't provide data structures like list and set in a glue library, or a way to do OOP. Instead just provide the mechanisms as functions working on bare tables. Don't do both either: if your list type gets widely adopted, your programs will now be a mixture of bare tables (this is inevitable) and lists so now you have to decide which of your lists has a `sort()` method and which need to be wrapped first. A global `glue.sort(t)` spares you the trouble.

### Write in Lua

String lambdas, callable strings, list comprehensions are all fun, but even the simplest DSLs have a learning curve, complex semantics and performance corner cases, and become a barrier to reading other people's code. I remember loathing having to use Lua's unfamiliar regex language with non-linear performance to do all of my string chores.

Adding DSLs make reading code frustrating. Why not give them _an identity of their own_ and ship them as individual libraries and see if they can claim the required learning time from programmers by themselves.

### Sugar

Don't add shortcut functions except when calling the shortcut function makes the code more readable than the equivalent Lua code.

If something is an [tricks idiom], don't add a function for it, use it directly. Chances are its syntax will be more popular than its name. Eg. it's harder to recall and trust semantic equivalence of `isnan(x)` to the odd looking but mnemonic idiom `x ~= x`. That doesn't mean `a < b and a or b` is an idiom for `min` though, `min` itself is the idiom as we know it from math (wish there were a `sign()` function too).

Functional programming sugars like `compose` and `bind` makes code harder to read because brains are slow to switch between abstraction levels unless it's a self-contained DSL with radically different syntax and semantics than the surrounding code. Eg. it's relatively easy to read a Lua string pattern or an embedded SQL string more than it is reading expressions involving `bind` and `compose` which force you to simulate the equivalent Lua syntax in your head.

Sugars like "message %s" % arg are the good ones: % is odd enough to put after a string constant that it has an idiomatic quality, and its semantics is self-evident by reading the format string literal, even for someone who never heard of python's `%` operator. Also, a prefix notation is generally more readable than a function call.

## Implementation

Keep the code readable (didactically when possible) and compact. Code changes that compromise these qualities for optimization should come with a benchmark to justify them.

Document the limits of the algorithms involved with respect to input, like when does it have non-linear performance and how it is stack bound. Performance characteristics are not an implementation detail.
