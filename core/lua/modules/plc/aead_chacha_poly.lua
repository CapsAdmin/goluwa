-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file
------------------------------------------------------------
--[[

aead_chacha_poly

Authenticated Encryption with Associated Data (AEAD) [1], based
on Chacha20 stream encryption and Poly1305 MAC, as defined
in RFC 7539 [2].

[1] https://en.wikipedia.org/wiki/Authenticated_encryption
[2] http://www.rfc-editor.org/rfc/rfc7539.txt

This file uses chacha20.lua and poly1305 for the encryption
and MAC primitives.

]]

local chacha20 = require "plc.chacha20"
local poly1305 = require "plc.poly1305"

------------------------------------------------------------
-- poly1305 key generation

local poly_keygen = function(key, nonce)
	local counter = 0
	local m = string.rep('\0', 64)
	local e = chacha20.encrypt(key, counter, nonce, m)
	-- keep only first the 256 bits (32 bytes)
	return e:sub(1, 32)
end

local pad16 = function(s)
	-- return null bytes to add to s so that #s is a multiple of 16
	return (#s % 16 == 0) and "" or ('\0'):rep(16 - (#s % 16))
end

local app = table.insert

local encrypt = function(aad, key, iv, constant, plain)
	-- aad: additional authenticated data - arbitrary length
	-- key: 32-byte string
	-- iv, constant: concatenated to form the nonce (12 bytes)
	--   (why not one 12-byte param? --maybe because IPsec uses
	--   an 8-byte nonce)
	-- implementation: RFC 7539 sect 2.8.1
	-- (memory inefficient - encr text is copied in mac_data)
	local mt = {} -- mac_data table
	local nonce = constant .. iv
	local otk = poly_keygen(key, nonce)
	local encr = chacha20.encrypt(key, 1, nonce, plain)
	app(mt, aad)
	app(mt, pad16(aad))
	app(mt, encr)
	app(mt, pad16(encr))
	-- aad and encrypted text length must be encoded as
	-- little endian _u64_ (and not u32) -- see errata at
	-- https://www.rfc-editor.org/errata_search.php?rfc=7539
	app(mt, string.pack('<I8', #aad))
	app(mt, string.pack('<I8', #encr))
	local mac_data = table.concat(mt)
--~ 	p16('mac', mac_data)
	local tag = poly1305.auth(mac_data, otk)
	return encr, tag
end --chacha20_aead_encrypt()

local function decrypt(aad, key, iv, constant, encr, tag)
	-- (memory inefficient - encr text is copied in mac_data)
	-- (structure similar to aead_encrypt => what could be factored?)
	local mt = {} -- mac_data table
	local nonce = constant .. iv
	local otk = poly_keygen(key, nonce)
	app(mt, aad)
	app(mt, pad16(aad))
	app(mt, encr)
	app(mt, pad16(encr))
	app(mt, string.pack('<I8', #aad))
	app(mt, string.pack('<I8', #encr))
	local mac_data = table.concat(mt)
	local mac = poly1305.auth(mac_data, otk)
	if mac == tag then
		local plain = chacha20.encrypt(key, 1, nonce, encr)
		return plain
	else
		return nil, "auth failed"
	end
end --chacha20_aead_decrypt()


------------------------------------------------------------
-- return aead_chacha_poly module

return {
	poly_keygen = poly_keygen,
	encrypt = encrypt,
	decrypt = decrypt,
	}
