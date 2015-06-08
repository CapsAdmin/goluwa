-- luainspect.html - Convert AST to HTML using LuaInspect info embedded.
--
-- (c) 2010 David Manura, MIT License.

--! require 'luainspect.typecheck' (context)

local M = {}

local LI = require "luainspect.init"

-- FIX!!! improve: should be registered utility function
local function escape_html(s)
  return s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;')
end

local function annotate_source(src, ast, tokenlist, emit)
  local start = 1
  local fmt_srcs = {}
  for _,token in ipairs(tokenlist) do
    local fchar, lchar = token.fpos, token.lpos
    if fchar > start then
      table.insert(fmt_srcs, emit(src:sub(start, fchar-1)))
    end
    table.insert(fmt_srcs, emit(src:sub(fchar, lchar), token))
    start = lchar + 1
  end
  if start <= #src then
    table.insert(fmt_srcs, emit(src:sub(start)))
  end
  return table.concat(fmt_srcs)
end

function M.ast_to_html(ast, src, tokenlist, options)
  local src_html = annotate_source(src, ast, tokenlist, function(snip_src, token)
  local snip_html = escape_html(snip_src)
  if token then
    local ast = token.ast
    if token.tag == 'Id' or ast.isfield then
      local class = 'id '
      class = class .. table.concat(LI.get_var_attributes(ast), " ")
      if ast.id then class = class.." id"..ast.id end
      local desc_html = escape_html(LI.get_value_details(ast, tokenlist, src))
      if ast.lineinfo then
        local linenum = ast.lineinfo.first[1]
        desc_html = desc_html .. '\nused-line:' .. linenum
      end
      return "<span class='"..class.."'>"..snip_html.."</span><span class='info'>"..desc_html.."</span>"
    elseif token.tag == 'Comment' then
      return "<span class='comment'>"..snip_html.."</span>"
    elseif token.tag == 'String' then -- note: excludes ast.isfield
      return "<span class='string'>"..snip_html.."</span>"
    elseif token.tag == 'Keyword' then
      local id = token.keywordid and 'idk'..tostring(token.keywordid) or ''
      return "<span class='keyword "..id.."'>"..snip_html.."</span>"
    end
  end
  return snip_html
 end)

 
 local function get_line_numbers_html(src)
  local out_htmls = {}
  local linenum = 1
  for line in src:gmatch("[^\n]*\n?") do
    if line == "" then break end
    table.insert(out_htmls, string.format('<span id="L%d">%d:</span>\n', linenum, linenum))
    linenum = linenum + 1
  end
  return table.concat(out_htmls)
 end
 
 local line_numbers_html = get_line_numbers_html(src)

 options = options or {}
 local libpath = options.libpath or '.'
 
  src_html = [[
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title></title>
  <script src="]]..libpath..[[/jquery-1.4.2.min.js" type="text/javascript"></script>
  <script src="]]..libpath..[[/luainspect.js" type="text/javascript"></script>
  <link rel="stylesheet" type="text/css" href="]]..libpath..[[/luainspect.css">
</head>
<body>

<div class="lua-source">
<pre class="lua-source-linenums">]] .. line_numbers_html .. [[</pre>
<pre class="lua-source-content"><code>]] .. src_html .. [[</code></pre>
<div class="lua-source-clear"></div>
</div>

</body></html>]]

 return src_html
end

return M
