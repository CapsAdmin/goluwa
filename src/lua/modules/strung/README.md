#strung.lua

Version `1.0.0-rc1`.

a rewrite of the Lua string pattern matching functions in Lua + FFI, for LuaJIT.

`strung.find`, `strung.match`, `strung.gmatch` and `strung.gsub` are implemented according to the Lua manual, and pass the full official test suite.

For the null byte in patterns, `strung` suports both `"%z"`, like Lua 5.1 and `"\0"`, like Lua 5.2. You can capture up to 200 values, if that's your thing.

Like Lua 5.1, and unlike Lua 5.2 and LuaJIT 2.0+, `strung` character classes (`%l`, `%u`, etc.) are locale sensitive.

----

**Contents:** [Usage](#usage) — [Performance](#performance) — [Locales](#locales) — [Undefined Behavior](#undefined-behavior) — [TODO](#todo) — [License](#license) — [Notes](#notes)

----

## Usage

You can use the `strung.lua` file alone, the dependencies are optional, and only useful for development.

```Lua
local strung = require"strung"

strung.find("foobar", "b(%l*)") --> 4, 6, "ar"
```

... etc. for `match`, `gmatch` and `gsub`.

Alternativley, you can `.install()` the library, and have it replace the original functions completely.

```Lua
strung.install()

print(string.find == strung.find) --> true

S = "foo"

S:match"[^f]*" --> "oo", using `strung.match` rather than `string.match`
```

You can replace the methods selectively by passing method names as string to `install()`.

```Lua
strung.install("match", "gmatch")
```

## Performance

### tl;dr

Provided you reuse patterns often:

* For LuaJIT 2.1: `strung` is faster except for `find` with plain strings (which is much slower) and `gsub`.
* For LuaJIT 2.0: `strung` may or may not be competitive, depending on the phase of the moon, except for `gsub`, which is slower. The exact performace is not predictable.

### details

With LuaJIT 2.1, `strung.find`, `.match` and `.gmatch` are consistently faster in my micro benchmarks (except `find()`ing plain strings, see below). `strung.gsub` takes about twice as much time.

With LuaJIT 2.0, depending on the kind of pattern, and on some luck regarding the JIT compiler heuristics [0], matching can be up to three times faster than the original. In other circumstances, for the same pattern, it can be up to three times slower. It is often on par, except for `strung.gsub` which is much slower.

As of 2014-05-09, LuaJIT 2.1 is able to compile calls to `string.find` when the string is not a pattern or when the [`plain` argument](http://www.lua.org/manual/5.1/manual.html#pdf-string.find) is set to `true`. For that use case, the native method is 500-1000 times faster than `strung`, at least for short strings. LuaJIT 2.0 doesn't compile `string.find`, and in that case, `strung` is competitive.

The rest of the string matching functions use the Lua API, and, as such, cause the compiler to abbort if they are in the way. Their `strung` counterpart can be compiled, and included in traces if they are in a hot path.

You have'll to benchmark your peculiar use case to determine if `strung` improves the global performance of your program.

*/!\*: `strung` translates patterns to Lua functions, and caches the result. As a consequence, if you generate a lot of patterns dynamically, and seldom use them, `strung` will be much, much slower than the original. On the other hand, once a pattern has been compiled, matching only depends on the target string, whereas the reference functions have to dispatch on both the pattern and the target string. This allows LuaJIT to compile the matchers optimally.

Plain string search are not compiled

## Locales

`strung` compiles character classes (`"%u"`) and character sets (`"[a-z]"`), and caches the result for each pattern the first time they match. These sets don't update if you change the locale after the fact. You must call `strung.reset()` in order to clear the caches for the locale change to take effect. `strung.setlocale()` is a drop in replacement for `os.setlocale()` that resets `strung`. If you `.install()` the library, `os.setlocale()` will be replaced automatically.

## Undefined behavior

### Bad patterns

`strung` validates the patterns before attempting a match, whereas Lua validates them on the go.

For example:

```Lua
string.find("ab", "^b(") --> nil, the parenthese is never reached.
string.find("ba", "^b(") --> error: unfinished capture
```

`strung` will reject the pattern in both cases.

### Invalid ranges

The interaction between character classes (`%d`) and character ranges (`a-z`) inside character sets (e.g. `[%d-z]`) is documented as undefined in the Lua manual, and `strung` may handle them differently.

Specifically with `strung`:

* When placed before the dash,
  * if `%x` is a character class (e.g. `%l` for lower case letters) `[%l-k]` is a character set containing digits (`%d`), `-` and `k`.
  * If %x is not a character class, the `%x` works as an escape sequence , and thus `[%%-x]` is the character range between `%` and `x`. `[%0-\127]` will match all ASCII characters.
* When the `%` occurs at the end of a character class, it is treated as itself. `[x-%d]` contains the character range between `x` and `%`, and the letter `d`. `[x--]` and `[x-]]` are accepted as ranges ending in `-` and `]`, respectively.

## TODO

* Boyer Moore for the simple string search?

## License

MIT

## Notes

[0]: In the current benchmark suite, the order of the benchmarks influences the results. for example at some point, testing `gmatch("abcdabcdabcd", "((a)(b)c)()(d)")` alone, strung was taking 1.1 times the time of string.gmatch.

```
-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
Test:   gmatch  abcdabcdabcd    ((a)(b)c)()(d)
strung/string:  1.1065842049995
```

If you benchmarked `string.find` before `gmatch`, with the same pattern, the result was completely different.

```
-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
Test:   find    abcdabcdabcd    ((a)(b)c)()(d)
strung/string:  3.1869296949683
-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
Test:   gmatch  abcdabcdabcd    ((a)(b)c)()(d)
strung/string:  0.29895569825517
```
