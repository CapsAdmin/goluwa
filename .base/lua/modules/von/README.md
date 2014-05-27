# vON

vON is a [serialization](http://s.vercas.com/definitionserialization) library for Lua, turning tables into strings and the other way around.

The purpose of vON is to facilitate persistent storage of Lua data as strings (in a file, in a database, etc.).

Initially, I made it as an alternative to GLON ( **G**arry’s Mod **L**ua **O**bject **N**otation ), which was slow, the code was terrible, it used unprintable characters (which aren’t ideal for absolutely everything), and it was eventually removed from the game.

The main target of vON is flexibility and speed.

## License

The license is specified in the code file. The terms of usage are pretty simple. Just read them.

## Specifications

As in Lua, the main data structure is the table. But, unlike Lua tables, they are visibly separated in two parts: the numeric (array) component and the key-value pairs (dictionary) component.  
Tables start with *{* and end with *}*, and the two components are separated by a *~* (tilda) character, which may be absent if the table is a pure array.  
In case recursion-checking is enabled, tables which are found to recurse have a reference ID at their beginning. The ID is a number surrounded by *#* characters.  
**Examples**: Format: **{#id# … ~ … }** and data: **{#1#'lol”'mao”~'lol”:'mao”'recursion":$1}**, which would be **tab = {“lol”,”mao”,lol=”mao”}; tab.recursion = tab** in Lua.  

It must be mentioned that keys have no type restrictions. They can be booleans and even tables (or a Garry’s Mod-specific type).  

The first table in the data, the chunk, has no initial and final characters (they are useless). This allows concatenating some vON code together and keeping it valid; sort of like using table.insert.  
**Example**: **#1#'lol”'mao”~'lol”:'mao”'recursion":$1;**, which means the same thing as the example above enclosed in *{ }*.  

Also, for the sake of parsing speed, some types (such as boolean and numbers) are prefixed with a character. If no valid prefix character is found, the last type will be automatically used.  
Inside tables, spaces, tabs and newlines are simply ignored when deserializing.  

Numbers are currently declared like this: **n…** (… represents the value in base 10). They either end in *;*, *}*, *:* or *~*. (At least one must be present).  
**Example**: **n1;2;3~4:4;** and **{n1;2;'intruder!”n4}**.  

Booleans are prefixed by **b** and are represented either by a **1** *(true)* or **0** *(false)*. They are represented by a single character so they don’t have a delimiter.  
Boolean sequences usually look like this: **b101101001**.  

Strings start with single quotes (*'*). Double quotes inside strings are escaped with a \\. Only they are escaped now.
The strings end in unescaped double quotes (*"*) - which are usually less common.  

## Example

```lua
{
    1, -1337, -99.99, 2, 3, 100, 101, 121, 143, 144, "ma\"ra", "are", "mere",
    {
        500,600,700,800,900,9001,
        [true] = false,
        [false] = "lol?",
        pere = true,
        [1997] = "vasile",
        [{ [true] = false, [false] = true }] = { [true] = "true", ["false"] = false }
    },
    true, false, false, true, false, true, true, false, true,
    [1337] = 1338,
    mara = "are",
    mere = false,
    [true] = false,
    [{ [true] = false, [false] = true }] = { [true] = "true", ["false"] = false }
}
```

… becomes …  

    n1;-1337;-99.99;2;3;100;101;121;143;144;'ma\"ra"'are"'mere"{n500;600;700;800;900;9001~b1:0{~b0:11:0}:{~b1:'true"'false":b0}'pere":b1n1997:'vasile"b0:'lol?"}b100101101~1:0{~b0:11:0}:{~b1:'true"'false":b0}n1337:1338;'mara":'are"'mere":b0

That’s pretty.
