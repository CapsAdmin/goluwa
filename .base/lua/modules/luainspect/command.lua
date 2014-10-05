#!/usr/bin/env lua

-- luainspect.command - LuaInspect command-line interface.
-- This file can be invoked from the command line

package.path = package.path .. ';metalualib/?.lua'
package.path = package.path .. ';lib/?.lua'


local LA = require "luainspect.ast"
local LI = require "luainspect.init"

local function loadfile(filename)
  local fh = assert(io.open(filename, 'r'))
  local data = fh:read'*a'
  fh:close()
  return data
end

local function writefile(filename, output)
  local fh = assert(io.open(filename, 'wb'))
  fh:write(output)
  fh:close()
end

local function fail(err)
  io.stderr:write(err, '\n')
  os.exit(1)
end

-- Warning/status reporting function.
-- CATEGORY: reporting + AST
local function report(s) io.stderr:write(s, "\n") end

-- parse flags
local function getopt(c)
  if arg[1] then
    local x = arg[1]:match('^%-'..c..'(.*)')
    if x then table.remove(arg, 1)
      if x == '' and arg[1] then x = arg[1]; table.remove(arg, 1) end
      return x
    end
  end
end
local fmt = getopt 'f' or 'delimited'
local ast_to_text =
  (fmt == 'delimited') and require 'luainspect.delimited'.ast_to_delimited or
  (fmt == 'html') and require 'luainspect.html'.ast_to_html or
  fail('invalid format specified, -f'..fmt)
local libpath = getopt 'l' or '.'
local outpath = getopt 'o' or '-'

local path = unpack(arg)
if not path then
  fail[[
inspect.lua [options] <path.lua>
  -f {delimited|html} - output format
  -l path   path to library sources (e.g. luainspect.css/js), for html only
  -o path   output path (defaults to standard output (-)
]]
end

local src = loadfile(path)
local ast, err, linenum, colnum, linenum2 = LA.ast_from_string(src, path)

--require "metalua.table2"; table.print(ast, 'hash', 50)
if ast then
  local tokenlist = LA.ast_to_tokenlist(ast, src)
  LI.inspect(ast, tokenlist, src, report)
  LI.mark_related_keywords(ast, tokenlist, src)

  local output = ast_to_text(ast, src, tokenlist, {libpath=libpath})

  if outpath == '-' then
    io.stdout:write(output)
  else
    writefile(outpath, output)
  end
else
  io.stderr:write("syntax error: ", err)
  os.exit(1)
end



