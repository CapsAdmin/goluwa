local ffi = require 'ffi'
local type = type
local tonumber = tonumber
local lib = ffi.load("iconv")
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local ffi_gc = ffi.gc
local ffi_string = ffi.string
local ffi_typeof = ffi.typeof
local ffi_errno = ffi.errno
ffi.cdef[[
    typedef void *iconv_t;
    iconv_t libiconv_open (const char *__tocode, const char *__fromcode);
    size_t libiconv (
        iconv_t __cd,
        char ** __inbuf, size_t * __inbytesleft,
        char ** __outbuf, size_t * __outbytesleft
    );
    int libiconv_close (iconv_t __cd);
]]

local maxsize = 4096
local char_ptr = ffi_typeof('char *')
local char_ptr_ptr = ffi_typeof('char *[1]')
local sizet_ptr = ffi_typeof('size_t[1]')
local iconv_open_err = ffi_cast('iconv_t', ffi_new('int', -1))

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 8)
_M._VERSION = '0.2.0'

local mt = { __index = _M }

function _M.new(self, to, from, _maxsize)
    if not to or 'string' ~= type(to) or 1 > #to then
        return nil, 'dst charset required'
    end
    if not from or 'string' ~= type(from) or 1 > #from then
        return nil, 'src charset required'
    end
    _maxsize = tonumber(_maxsize) or maxsize
    local ctx = lib.libiconv_open(to, from)
    if ctx == iconv_open_err then
        lib.libiconv_close(ctx)
        return nil, ('conversion from %s to %s is not supported'):format(from, to)
    else
        ctx = ffi_gc(ctx, lib.libiconv_close)
        local buffer = ffi_new('char[' .. _maxsize .. ']')
        return setmetatable({
            ctx = ctx,
            buffer = buffer,
            maxsize = _maxsize,
        }, mt)
    end
end


function _M.convert(self, text)
    local ctx = self.ctx
    if not ctx then
        return nil, 'not initialized'
    end
    if not text or 'string' ~= type(text) or 1 > #text then
        return nil, 'text required'
    end
    local maxsize = self.maxsize
    local buffer = self.buffer

    local dst_len = ffi_new(sizet_ptr, maxsize)
    local dst_buff = ffi_new(char_ptr_ptr, ffi_cast(char_ptr, buffer))

    local src_len = ffi_new(sizet_ptr, #text)
    local src_buff = ffi_new(char_ptr_ptr)
    src_buff[0] = ffi_new('char['.. #text .. ']', text)

    local ok = lib.libiconv(ctx, src_buff, src_len, dst_buff, dst_len)
    if 0 <= ok then
        local len = maxsize - dst_len[0]
        local dst = ffi_string(buffer, len)
        return dst, tonumber(ok)
    else
        local err = ffi_errno()
        return nil, 'failed to convert, errno ' .. err
    end
end

function _M.finish(self)
    local ctx = self.ctx
    if not ctx then
        return nil, 'not initialized'
    end
    return lib.libiconv_close(ffi_gc(ctx, nil))
end

return _M