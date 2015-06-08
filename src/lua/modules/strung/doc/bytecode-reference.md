# Bytecode reference:

Instructions take 16 bits with the exception of {string} (variable, up to 33 bytes) and {long %f} (24 bits)

The 26 opcodes are encoded on the five least significant bits [4-0].

```
0 = >15: bitwise:
[3-2]: (0, 1, 2) = (any, char, set)
    [1-0]: (0, 1, 2, 3) = (1, *, -, ?)
        [5]: if set : +/- else n/a
        [6-7]: n/a
        [8-15]: char/charset
[3-2]: 3 = {string}
    [7-5 .. 1-0]: nchars
    [8-n]: chars


16 = {open capture}
    [8-15]: ref
17 = {close capture}
    [8-15]: ref
18 = {%f short version }
    [5-7]: offset
    [8-15]: char
19 = {%f long (two opcodes) }
    [8-15]: bound1
    [16-23]: bound2
20 = {capture reference}
    [5-16]: ref
21 = {%b}
    [5]: +/-
    [8-15]: charset
22 = {position capture}
23 = {$}
24 = {no anchor}
25 = {anchor}
```

    ... and then more strings?