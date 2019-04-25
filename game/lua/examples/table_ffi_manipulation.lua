local ffi = require("ffi")
local tbl = {1337,888,444,-1}

local ptr = ffi.cast("void *", loadstring("return " .. string.format("%p", tbl) .. "ULL")())

print("guessed location:")
local guess = ffi.cast("double *", ptr) + 8
for i = 1, #tbl do
    print("\t" .. i .. ": " .. guess[i])
end

ffi.cdef([[
    struct MRef {
        uint64_t gcptr32;	/* Pseudo 32 bit pointer. */
    };

    struct GCTab {
        struct MRef nextgc;
        uint8_t marked;
        uint8_t gct;
        uint8_t nomm;		/* Negative cache for fast metamethods. */
        int8_t colo;		/* Array colocation. */
        struct MRef array;		/* Array part. */
        struct MRef gclist;
        struct MRef metatable;	/* Must be at same offset in GCudata. */
        struct MRef node;		/* Hash part. */
        uint32_t asize;	/* Size of array part (keys [0, asize-1]). */
        uint32_t hmask;	/* Hash part mask (size of hash part - 1). */
        struct MRef freetop;		/* Hash part. */
      };
]])

print("proper location:")
local gctab = ffi.cast("struct GCTab *", ptr)
local array = ffi.cast("double *", ffi.cast("struct GCTab *", ptr).array.gcptr32)

for i = 1, gctab.asize - 1 do
    print("\t" .. i .. ": " .. array[i])

    array[i] = 1337
end

table.print(tbl)