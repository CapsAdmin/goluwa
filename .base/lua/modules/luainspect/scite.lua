--[[
 luainspect.scite - SciTE text editor plugin
 (c) 2010 David Manura, MIT License.

 == Background Comments ==

 The interaction between SciTE add-ons like lexers and extensions,
 including various Lua and C++ formulations of these, may be confusing
 at first, so here's a summary.

 SciTE has an "extension interface" [1], which allows you to write C++
 modules that hook into SciTE events on a global level.  SciTE comes
 with two built-in extensions.  The multiplexing extension
 (MultiplexExtension.cxx) allows you to plug-in more than one
 extension.  The Lua extension (LuaExtension.cxx) allows you to write
 an extension with Lua scripts [2] rather than C++. Extensions in Lua
 and C++ are fairly similar, but there is an "extension.<filepattern>"
 property that "is part of the generic SciTE Extension Interface but
 is currently only used by the Lua Scripting Extension" [3] and that
 allows an extension script to be applied only when the active buffer
 is of a specific file type or directory (rather than globally).
 These are called "Lua extension scripts" in contrast to (global) "Lua
 startup scripts" ("ext.lua.startup.script" property).  Handler
 functions in the Lua extension scripts override global handlers in
 the Lua startup script.  Lua extension scripts supposedly provide a
 standard and user-configurable way to apply extensions to specific
 languages.

 Scintilla (not just SciTE) also supports lexers [4-5], which are
 traditionally implemented in C++ (e.g. LexLua.cxx) and can be enabled
 by the user for specific file types (rather than globally) via the
 "lexer.<filepattern>" property.  Lexers can also be written in Lua
 scripts [6] (i.e. OnStyle handler), via the Lua extension interface,
 apparently either as Lua startup scripts or Lua extension scripts.
 This differs from C++ lexers, which are not loaded via the extension
 interface.  Lexers are a Scintilla concept. Extensions are a SciTE
 concept.

 LuaInspect is both a lexer and an extension.  It does both
 syntax highlighting (lexer) as well as event handling (extension) to
 support intelligent behavior and analysis.  LuaInspect also applies
 only to Lua files (not globally) and it is implemented in Lua (not
 C++).  These characteristics entail that LuaInspect be a Lua extension
 script.  There is one exception though mentioned in the comments above
 the scite.lua M.install() function in that certain initialization
 actions are best handled early via a Lua startup script, so scite.lua
 is called both as a startup script and extension script to do different
 actions (although the mechanism is a bit awkward).  You could have
 LuaInspect operate entirely as a Lua startup script, but that
 could interfere when editing non-Lua files.

 The fact that SciTE reloads extensions scripts on buffer swaps
 is probably unnecessary but outside of our control.  In any case,
 overhead should be low.  Note that the AST and token lists are cached
 in the buffer object, which persists across buffer swaps, so the
 really expensive parsing is avoided on buffer swaps.

 There is also SciTE ExtMan [7], which is normally (always?) loaded
 as a Lua startup script.  This provides various global utility
 functions, as well as a mechanism to multiplex multiple Lua startup
 scripts.  LuaInspect does not use the latter, implementing instead
 it's own install_handler mechanism, because LuaInspect is involved
 in Lua extension scripts rather than Lua startup scripts.
 install_handler is careful though to ensure that global handlers
 in any Lua startup script (including ExtMan handlers) are still called.

 [1] http://www.scintilla.org/SciTEExtension.html
 [2] http://www.scintilla.org/SciTELua.html
 [3] http://www.scintilla.org/SciTEDoc.html
 [4] http://www.scintilla.org/SciTELexer.html
 [5] http://www.scintilla.org/ScintillaDoc.html#LexerObjects
 [6] http://www.scintilla.org/ScriptLexer.html
 [7] http://lua-users.org/wiki/SciteExtMan
]]


-- Whether to update the AST on every edit (true) or only when the selection
-- is moved to a different line (false).  false can be more efficient for large files.
local UPDATE_ALWAYS = scite_GetProp('luainspect.update.always', '1') == '1'

-- Styling will be delayed for DELAY_COUNT styling events following user typing.
-- However it will be immediately triggered on a cursor or line change.
-- 0 implies always style.  Increase to improve performance but delay display update.
local UPDATE_DELAY = math.max(1, tonumber(scite_GetProp('luainspect.update.delay', '5')))

-- When user edits code, recompile only the portion of code that is edited.
-- This can improve performance and normally should be true unless you find problems.
local INCREMENTAL_COMPILATION = scite_GetProp('luainspect.incremental.compilation', '1') == '1'

-- Whether to run timing tests (for internal development purposes).
local PERFORMANCE_TESTS = scite_GetProp('luainspect.performance.tests', '0') == '1'

-- Experimental feature: display types/values of all known locals as annotations.
-- Allows Lua to be used like a Mathcad worksheet.
local ANNOTATE_ALL_LOCALS = scite_GetProp('luainspect.annotate.all.locals', '0') == '1'

-- WARNING: experimental and currently buggy.
-- Auto-completes variables.
local AUTOCOMPLETE_VARS = scite_GetProp('luainspect.autocomplete.vars', '0') == '1'

-- WARNING: experimental and currently buggy.
-- Auto-completes syntax.  Like http://lua-users.org/wiki/SciteAutoExpansion .
local AUTOCOMPLETE_SYNTAX = scite_GetProp('luainspect.autocomplete.syntax', '0') == '1'

-- Paths to append to package.path and package.cpath.
local PATH_APPEND = scite_GetProp('luainspect.path.append', '')
local CPATH_APPEND = scite_GetProp('luainspect.cpath.append', '')

-- Whether SciTE folding is applied.  Normally true.
local ENABLE_FOLDING = false -- disabled since still occasionally triggers OnStyle recursion problem.

-- Base color scheme.
-- sciteGetProp('style.script_lua.scheme')   'dark' or 'light' (same as '')

local LI = require "luainspect.init"
local LA = require "luainspect.ast"
local LD = require "luainspect.dump"
local T = require "luainspect.types"

local M = {}

--! require 'luainspect.typecheck' (context)

-- variables stored in `buffer`:
-- ast -- last successfully compiled AST
-- src  -- source text corresponding to `ast`
-- lastsrc  -- last attempted `src` (might not be successfully compiled)
-- tokenlist  -- tokenlist corresponding to `ast`
-- lastline - number of last line in OnUpdateUI (only if not UPDATE_ALWAYS)


-- Performance test utilities.  Enabled only for PERFORMANCE_TESTS.
local perf_names = {}
local perf_times = {os.clock()}
local nilfunc = function(name_) end
local clock = PERFORMANCE_TESTS and function(name)
  perf_times[#perf_times+1] = os.clock()
  perf_names[#perf_names+1] = name
end or nilfunc
local clockbegin = PERFORMANCE_TESTS and function(name)
  perf_names = {}
  perf_times = {}
  clock(name)
end or nilfunc
local clockend = PERFORMANCE_TESTS and function(name)
  clock(name)
  for i=1,#perf_times do
    print('DEBUG:clock:', perf_names[i], perf_times[i] - perf_times[1])
  end
end or nilfunc


-- Shorten string by replacing any long middle section with "..."
-- CATEGORY: dump
local _pat
local function debug_shorten(s)
  local keep_pat = ("."):rep(100)
  _pat = _pat or "^(" .. keep_pat .. ").*(" .. keep_pat .. ")$"
  return s:gsub(_pat, "%1\n<...>\n%2")
end

-- CATEGORY: debug
local function DEBUG(...)
  if LUAINSPECT_DEBUG then
    print('DEBUG:', ...)
  end
end


-- Style IDs - correspond to style properties
local S_DEFAULT = 0
local S_LOCAL = 1
local S_LOCAL_MUTATE = 6
local S_LOCAL_UNUSED = 7
local S_LOCAL_PARAM = 8
local S_LOCAL_PARAM_MUTATE = 16
local S_UPVALUE = 10
local S_UPVALUE_MUTATE = 15
local S_GLOBAL_RECOGNIZED = 2   --Q:rename recognized->known?
local S_GLOBAL_UNRECOGNIZED = 3
local S_FIELD = 11
local S_FIELD_RECOGNIZED = 12
local S_COMMENT = 4
local S_STRING = 5
local S_TAB = 13
local S_KEYWORD = 14
local S_COMPILER_ERROR = 9
local STYLES = {}
STYLES.default = S_DEFAULT
STYLES['local'] = S_LOCAL
STYLES.local_mutate = S_LOCAL_MUTATE
STYLES.local_unused = S_LOCAL_UNUSED
STYLES.local_param = S_LOCAL_PARAM
STYLES.local_param_mutate = S_LOCAL_PARAM_MUTATE
STYLES.upvalue = S_UPVALUE
STYLES.upvalue_mutate = S_UPVALUE_MUTATE
STYLES.global_recognized = S_GLOBAL_RECOGNIZED
STYLES.global_unrecognized = S_GLOBAL_UNRECOGNIZED
STYLES.field = S_FIELD
STYLES.field_recognized = S_FIELD_RECOGNIZED
STYLES.comment = S_COMMENT
STYLES.string = S_STRING
STYLES.tab = S_TAB
STYLES.keyword = S_KEYWORD
STYLES.compiler_error = S_COMPILER_ERROR
STYLES.indic_fore = 'indic_fore'
STYLES.indic_style = 'indic_style'


-- Marker for range of lines with invalidated code that doesn't parse.
local MARKER_ERROR = 0
-- Markers for lines of variable scope or block.
local MARKER_SCOPEBEGIN = 8
local MARKER_SCOPEMIDDLE = 2
local MARKER_SCOPEEND = 3
-- Marker for specific line with parser error.
local MARKER_ERRORLINE = 4
-- Marker displayed to alter user that syntax highlighting has been delayed
-- during user typing.
local MARKER_WAIT = 5
-- Marker displayed next to local definition that is masked by selected local definition.
local MARKER_MASKED = 6
-- Marker displayed next to local definition masking another local defintion.
local MARKER_MASKING = 7
-- note: marker 1 used for bookmarks

-- Indicator for syntax or other errors
local INDICATOR_ERROR = 0
-- Indicator for variable instances in scope.
local INDICATOR_SCOPE = 1
-- Indicator for related keywords in block.
local INDICATOR_KEYWORD = 2
-- Indicator or locals masking other locals (name conflict).
local INDICATOR_MASKING = 3
-- Indicator for autocomplete characters (typing over them is ignored).
local INDICATOR_AUTOCOMPLETE = 4
-- Indicator or locals masked by other locals (name conflict).
local INDICATOR_MASKED = 5
-- Indicator for warnings.
local INDICATOR_WARNING = 6
-- Indicator for dead-code
local INDICATOR_DEADCODE = 7

-- Display annotations.
-- Used for ANNOTATE_ALL_LOCALS feature.
-- CATEGORY: SciTE GUI + AST
local function annotate_all_locals()
  -- Build list of annotations.
  local annotations = {}
  for i=1,#buffer.tokenlist do
    local token = buffer.tokenlist[i]
    if token.ast.localdefinition == token.ast then
      local info = LI.get_value_details(token.ast, buffer.tokenlist, buffer.src)
      local linenum0 = editor:LineFromPosition(token.lpos-1)
      annotations[linenum0] = (annotations[linenum0] or "") .. "detail: " .. info
    end
  end
  -- Apply annotations.
  editor.AnnotationVisible = ANNOTATION_BOXED
  for linenum0=0,table.maxn(annotations) do
    if annotations[linenum0] then
      editor.AnnotationStyle[linenum0] = S_DEFAULT
      editor:AnnotationSetText(linenum0, annotations[linenum0])
    end
  end
end


-- Warning/status reporting function.
-- CATEGORY: SciTE GUI + reporting + AST
local report = print


-- Attempts to update AST from editor text and apply decorations.
-- CATEGORY: SciTE GUI + AST
local function update_ast()
  -- Skip update if text unchanged.
  local newsrc = editor:GetText()
  if newsrc == buffer.lastsrc then
    return false
  end
  buffer.lastsrc = newsrc
  clockbegin 't1'

  local err, linenum, colnum, linenum2

  -- Update AST.
  local errfpos0, errlpos0
  if newsrc == buffer.src then -- returned to previous good version
    -- note: nothing to do besides display
  else
   -- note: loadstring and metalua don't parse shebang
   local newmsrc = LA.remove_shebang(newsrc)

   -- Quick syntax check.
   -- loadstring is much faster than Metalua, so try that first.
   -- Furthermore, Metalua accepts a superset of the Lua grammar.
   local f; f, err, linenum, colnum, linenum2 = LA.loadstring(newmsrc)

   -- Analyze code using LuaInspect, and apply decorations
   if f then
    -- Select code to compile.
    local isincremental = INCREMENTAL_COMPILATION and buffer.ast
    local pos1f, pos1l, pos2f, pos2l, old_ast, old_type, compilesrc
    if isincremental then
      pos1f, pos1l, pos2f, pos2l, old_ast, old_type =
          LA.invalidated_code(buffer.ast, buffer.tokenlist, LA.remove_shebang(buffer.src), newmsrc)
      compilesrc = newmsrc:sub(pos2f,pos2l)
      DEBUG('inc', pos1f, pos1l, pos2f, pos2l, old_ast, old_type )
      DEBUG('inc-compile:[' .. debug_shorten(compilesrc)  .. ']', old_ast and (old_ast.tag or 'notag'), old_type, pos1f and (pos2l - pos1l), pos1l, pos2f)
    else
      compilesrc = newmsrc
    end
    clock 't2'

    -- Generate AST.
    local ast
    if old_type ~= 'whitespace' then
      --currently not needed: compilesrc = compilesrc .. '\n' --FIX:Workaround:Metalua:comments not postfixed by '\n' ignored.
      ast, err, linenum, colnum, linenum2 = LA.ast_from_string(compilesrc, props.FilePath)
      --DEBUG(table.tostring(ast, 20))
    end
    clock 't3'

    if err then
      print "warning: metalua failed to compile code that compiles with loadstring.  error in metalua?"
    else
      local tokenlist = ast and LA.ast_to_tokenlist(ast, compilesrc)
        -- note: ast nil if whitespace
      --print(LA.dump_tokenlist(tokenlist))


      buffer.src = newsrc
      if isincremental and old_type ~= 'full' then
        -- Adjust line numbers.
        local delta = pos2l - pos1l
        LA.adjust_lineinfo(buffer.tokenlist, pos1l, delta)
        if ast then
          LA.adjust_lineinfo(tokenlist, 1, pos2f-1)
        end

        -- Inject AST
        if old_type == 'whitespace' then
          -- nothing
        elseif old_type == 'comment' then
          assert(#tokenlist == 1 and tokenlist[1].tag == 'Comment') -- replacing with comment
          local newcommenttoken = tokenlist[1]
          local token = old_ast
          token.fpos, token.lpos, token[1], token[4] =
              newcommenttoken.fpos, newcommenttoken.lpos, newcommenttoken[1], newcommenttoken[4]
        else assert(old_type == 'statblock')
          LA.replace_statements(buffer.ast, buffer.tokenlist, old_ast, ast, tokenlist)
        end

        if not(old_type == 'comment' or old_type == 'whitespace') then
          LI.uninspect(buffer.ast)
          LI.inspect(buffer.ast, buffer.tokenlist, buffer.src, report) --IMPROVE: don't do full inspection
        end
      else --full
        -- old(FIX-REMOVE?): careful: if `buffer.tokenlist` variable exists in `newsrc`, then
        --   `LI.inspect` may attach its previous value into the newly created
        --   `buffer.tokenlist`, eventually leading to memory overflow.

        buffer.tokenlist = tokenlist
        buffer.ast = ast
        LI.inspect(buffer.ast, buffer.tokenlist, buffer.src, report)
      end
      if LUAINSPECT_DEBUG then
        DEBUG(LA.dump_tokenlist(buffer.tokenlist))
        DEBUG(LD.dumpstring(buffer.ast))
        --DEBUG(table.tostring(buffer.ast, 20))
      end
    end
   else
     -- Locate position range causing error.
     if buffer.ast then
       local pos1f, pos1l, pos2f, pos2l, old_ast, old_type =
          LA.invalidated_code(buffer.ast, buffer.tokenlist, LA.remove_shebang(buffer.src), newmsrc, true)
       errfpos0, errlpos0 = pos2f-1, pos2l-1
     end
   end
  end
  clockend 't4'

  -- Apply styling
  if err then
     local pos = linenum and editor:PositionFromLine(linenum-1) + colnum - 1
     --old: editor:CallTipShow(pos, err)
     --old: editor:BraceHighlight(pos,pos) -- highlight position of error (hack: using brace highlight)
     editor.IndicatorCurrent = INDICATOR_ERROR
     editor:IndicatorClearRange(0, editor.Length)
     editor:IndicatorFillRange(pos, 1) --IMPROVE:mark entire token?
     editor:MarkerDeleteAll(MARKER_ERRORLINE)
     editor:MarkerAdd(linenum-1, MARKER_ERRORLINE)
     editor:AnnotationClearAll()
     editor.AnnotationVisible = ANNOTATION_BOXED
     local errlinenum0 = errfpos0 and editor:LineFromPosition(errlpos0+1) or linenum-1
        -- note: +1 to avoid error message moving above cursor on pressing Enter.
     editor.AnnotationStyle[errlinenum0] = S_COMPILER_ERROR
     editor:AnnotationSetText(errlinenum0, "error " .. err)
     if linenum2 then -- display error in two locations
       --old:editor.AnnotationStyle[linenum2-1] = S_COMPILER_ERROR
       --     editor:AnnotationSetText(linenum2-1, "error " .. err)
       editor:MarkerAdd(linenum2-1, MARKER_ERRORLINE)
     end

     -- Indicator over invalidated position range causing error.
     if errfpos0 then
       --unused: editor.IndicatorCurrent = INDICATOR_INVALIDATED
       --  editor:IndicatorClearRange(INDICATOR_INVALIDATED, editor.Length)
       --  editor:IndicatorFillRange(errfpos0, errlpos0-errfpos0+1)
       for line0=editor:LineFromPosition(errfpos0), editor:LineFromPosition(errlpos0) do
         editor:MarkerAdd(line0, MARKER_ERROR)
       end
     end
  else

    --old: editor:CallTipCancel()
    editor.IndicatorCurrent = INDICATOR_ERROR
    editor:IndicatorClearRange(0, editor.Length)
    editor:MarkerDeleteAll(MARKER_ERRORLINE)
    editor:AnnotationClearAll()
    --unused: editor.IndicatorCurrent = INDICATOR_INVALIDATED
    -- editor:IndicatorClearRange(0, editor.Length)
    editor:MarkerDeleteAll(MARKER_ERROR)

    if ANNOTATE_ALL_LOCALS then annotate_all_locals() end
  end

  -- Do auto-completion.
  -- WARNING:FIX:the implementations here are currently rough.
  if AUTOCOMPLETE_SYNTAX and errfpos0 then
    editor.IndicatorCurrent = INDICATOR_AUTOCOMPLETE
    --DEBUG(buffer.lastsrc)
    local ssrc = buffer.lastsrc:sub(errfpos0+1, errlpos0+1)

    if ssrc == "if " then
      local more = " then end"
      editor:InsertText(errlpos0+1, more)
      editor:IndicatorFillRange(errlpos0+1, #more)
    end
    if ssrc:match'^[^"]*"[^"]*$' then
      local more = '"'
      editor:InsertText(errlpos0+1, more)
      editor:IndicatorFillRange(errlpos0+1, #more)
    end
    if ssrc:match'%{[^%}]*$' then
      more = '}'
      editor:InsertText(errlpos0+1, more)
      editor:IndicatorFillRange(errlpos0+1, #more)
    end
    if ssrc:match'%([^%)]*$' then
      more = ')'
      editor:InsertText(errlpos0+1, more)
      editor:IndicatorFillRange(errlpos0+1, #more)
    end
  end
end


-- Gets token assocated with currently selected variable (if any).
-- CATEGORY: SciTE GUI + AST
local function getselectedvariable()
  if buffer.src ~= editor:GetText() then return end  -- skip if AST not up-to-date
  local selectedtoken
  local id
  local pos = editor.Anchor+1
  for i,token in ipairs(buffer.tokenlist) do
    if pos >= token.fpos and pos <= token.lpos then
      if token.ast.id then
        selectedtoken = token
        id = token.ast.id
      end
      break
    end
  end
  return selectedtoken, id
end


-- Marks in margin range of 0-indexed lines.
-- CATEGORY: SciTE GUI
local function scope_lines(firstline0, lastline0)
  if firstline0 ~= lastline0 then -- multiline
    --TODO: not rendering exactly as desired.  TCORNERCURVE should
    -- preferrably be an upside-down LCORNERCURVE; plus the color on TCORNERCURVE is off.
    editor:MarkerAdd(firstline0, MARKER_SCOPEBEGIN)
    for n=firstline0+1,lastline0-1 do
      editor:MarkerAdd(n, MARKER_SCOPEMIDDLE)
    end
    editor:MarkerAdd(lastline0, MARKER_SCOPEEND)
  else -- single line
    editor:MarkerAdd(firstline0, MARKER_SCOPEMIDDLE)
  end
end


-- Marks in margin range of 0-indexed positions.
-- CATEGORY: SciTE GUI
local function scope_positions(fpos0, lpos0)
  local firstline0 = editor:LineFromPosition(fpos0)
  local lastline0 = editor:LineFromPosition(lpos0)
  scope_lines(firstline0, lastline0)
end


-- Responds to UI updates.  This includes moving the cursor.
-- CATEGORY: SciTE event handler
function M.OnUpdateUI()
  -- Disable any autocomplete indicators if cursor moved away.
  if AUTOCOMPLETE_SYNTAX then
    if editor:IndicatorValueAt(INDICATOR_AUTOCOMPLETE, editor.CurrentPos) ~= 1 then
      editor.IndicatorCurrent = INDICATOR_AUTOCOMPLETE
      editor:IndicatorClearRange(0, editor.Length)
    end
  end

  -- This updates the AST when the selection is moved to a different line.
  if not UPDATE_ALWAYS then
    local currentline = editor:LineFromPosition(editor.Anchor)
    if currentline ~= buffer.lastline then
      update_ast()
      buffer.lastline = currentline
    end
  end

  if buffer.src ~= editor:GetText() then return end -- skip if AST is not up-to-date

  -- check if selection if currently on identifier
  local selectedtoken, id = getselectedvariable()

  --test: adding items to context menu upon variable selection
  --if id then
  --  props['user.context.menu'] = selectednote.ast[1] .. '|1101'
  --  --Q: how to reliably remove this upon a buffer switch?
  --end

  -- Highlight all instances of that identifier.
  editor:MarkerDeleteAll(MARKER_SCOPEBEGIN)
  editor:MarkerDeleteAll(MARKER_SCOPEMIDDLE)
  editor:MarkerDeleteAll(MARKER_SCOPEEND)
  editor:MarkerDeleteAll(MARKER_MASKED)
  editor:MarkerDeleteAll(MARKER_MASKING)
  editor.IndicatorCurrent = INDICATOR_SCOPE
  editor:IndicatorClearRange(0, editor.Length)
  editor.IndicatorCurrent = INDICATOR_MASKED
  editor:IndicatorClearRange(0, editor.Length)
  if id then

    -- Indicate uses of variable.
    editor.IndicatorCurrent = INDICATOR_SCOPE
    local ftoken, ltoken -- first and last occurances
    for _,token in ipairs(buffer.tokenlist) do
      if token.ast.id == id then
        ltoken = token
        if not ftoken then ftoken = token end
        editor:IndicatorFillRange(token.fpos-1, token.lpos-token.fpos+1)
      end
    end

    scope_positions(ftoken.fpos-1, ltoken.lpos-1)

    -- identify any local definition masked by any selected local definition.
    local ast = selectedtoken -- cast: `Id tokens are AST nodes.
    if ast.localmasking and not ast.isignore then
      local fpos, lpos = LA.ast_pos_range(ast.localmasking, buffer.tokenlist)
      if fpos then
        local maskedlinenum0 = editor:LineFromPosition(fpos-1)
        local maskinglinenum0 = editor:LineFromPosition(selectedtoken.fpos-1)
        editor:MarkerAdd(maskedlinenum0, MARKER_MASKED)
        editor:MarkerAdd(maskinglinenum0, MARKER_MASKING)
        editor.IndicatorCurrent = INDICATOR_MASKED
        editor:IndicatorFillRange(fpos-1, lpos-fpos+1)
      end
    end
  end

  -- Highlight related keywords.
  do
    editor.IndicatorCurrent = INDICATOR_KEYWORD
    editor:IndicatorClearRange(0, editor.Length)

    -- Check for selection over statement or expression.
    local fpos, lpos = editor.Anchor, editor.CurrentPos
    if lpos < fpos then fpos, lpos = lpos, fpos end -- swap
    fpos, lpos = fpos + 1, lpos + 1 - 1
    local match1_ast, match1_comment, iswhitespace =
      LA.smallest_ast_containing_range(buffer.ast, buffer.tokenlist, fpos, lpos)
    -- DEBUG('m', match1_ast and match1_ast.tag, match1_comment, iswhitespace)

    -- Find and highlight.
    local keywords; keywords, match1_ast = LI.related_keywords(match1_ast, buffer.ast, buffer.tokenlist, buffer.src)
    if keywords then
      for i=1,#keywords do
        local fpos, lpos = keywords[i].fpos, keywords[i].lpos
        editor:IndicatorFillRange(fpos-1, lpos-fpos+1)
      end
    end

    -- Mark range of lines covered by item on selection.
    if not id then
      local fpos, lpos = LA.ast_pos_range(match1_ast, buffer.tokenlist)
      if fpos then scope_positions(fpos-1, lpos-1) end
    end
  end


  --[[
  -- Display callinfo help on function.
  if selectednote and selectednote.ast.resolvedname and LS.global_signatures[selectednote.ast.resolvedname] then
    local name = selectednote.ast.resolvedname
    editor:CallTipShow(editor.Anchor, LS.global_signatures[name])
  else
    --editor:CallTipCancel()
  end
  ]]
end


-- Responds to requests for restyling.
-- Note: if StartStyling is not applied over the entire requested range, than this function is quickly recalled
--   (which possibly can be useful for incremental updates)
-- CATEGORY: SciTE event handler
local style_delay_count = 0
local isblock = {Function=true}
local debug_recursion = 0
function M.OnStyle(styler)
  assert(styler.language == "script_lua")

  -- Optionally delay styling.
  --print('DEBUG:style-count', style_delay_count)
  if style_delay_count > 0 then
    -- Dislpay wait marker if not displayed and new text parsing not yet attempted.
    if not buffer.wait_marker_line and editor:GetText() ~= buffer.lastsrc then
      buffer.wait_marker_line = editor:LineFromPosition(editor.CurrentPos)
      editor:MarkerDeleteAll(MARKER_WAIT)
      editor:MarkerAdd(buffer.wait_marker_line, MARKER_WAIT)
      style_delay_count = style_delay_count + 1
        -- +1 is hack to work around warning described below.
    end
    style_delay_count = style_delay_count - 1
    return
  elseif style_delay_count == 0 then
    if buffer.wait_marker_line then
      editor:MarkerDeleteAll(MARKER_WAIT)
      buffer.wait_marker_line = nil
    end
  end
  style_delay_count = UPDATE_DELAY
  -- WARNING: updating marker causes another style event to be called immediately.
  -- Therefore, we take care to only update marker when marker state needs changed
  -- and correct the count when we do.

  --IMPROVE: could metalua libraries parse text across multiple calls to
  --`OnStyle` to reduce long pauses with big files?  Maybe use coroutines.

  --DEBUG("style",styler.language, styler.startPos, styler.lengthDoc, styler.initStyle)

  -- update AST if needed
  if UPDATE_ALWAYS then
    update_ast()
  elseif not buffer.lastsrc then
    -- this ensures that AST compiling is attempted when file is first loaded since OnUpdateUI
    -- is not called on load.
    update_ast()
  end

  --DEBUG('OnStyle', editor:LineFromPosition(styler.startPos), editor:LineFromPosition(styler.startPos+styler.lengthDoc), styler.initStyle)
  if buffer.src ~= editor:GetText() then return end  -- skip if AST not up-to-date
  -- WARNING: SciTE will repeatedly call OnStyle until StartStyling is performed.
  -- However, StartStyling/Forward/EndStyling clears styles in the given range,
  -- but we prefer to leave the styles as is.

  debug_recursion = debug_recursion + 1
  if debug_recursion ~= 1 then print('warning: OnStyle recursion', debug_recursion) end
      -- folding previously triggered recursion leading to odd effects; make sure this is gone

  -- Apply SciTE styling
  editor.StyleHotSpot[S_LOCAL] = true
  editor.StyleHotSpot[S_LOCAL_MUTATE] = true
  editor.StyleHotSpot[S_LOCAL_UNUSED] = true
  editor.StyleHotSpot[S_LOCAL_PARAM] = true
  editor.StyleHotSpot[S_LOCAL_PARAM_MUTATE] = true
  editor.StyleHotSpot[S_UPVALUE] = true
  editor.StyleHotSpot[S_UPVALUE_MUTATE] = true
  editor.StyleHotSpot[S_GLOBAL_RECOGNIZED] = true
  editor.StyleHotSpot[S_GLOBAL_UNRECOGNIZED] = true
  editor.StyleHotSpot[S_FIELD] = true
  editor.StyleHotSpot[S_FIELD_RECOGNIZED] = true
  -- note: SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK currently aren't
  -- implemented by SciTE, although it has been proposed.

  local startpos0, endpos0 = 0, editor.Length -1
  styler:StartStyling(startpos0, endpos0 - startpos0 + 1, 0)
  -- local startpos0 = styler.startPos
  --styler:StartStyling(styler.startPos, styler.lengthDoc, styler.initStyle)
  --   a partial range like this doesn't work right since variables outside of edited range
  --   may need styling adjusted (e.g. a local variable definition that becomes unused)

  local i=startpos0+1
  local tokenidx = 1
  local token = buffer.tokenlist[tokenidx]
  local function nexttoken() tokenidx = tokenidx+1; token = buffer.tokenlist[tokenidx] end
  while styler:More() do
    while token and i > token.lpos do
      nexttoken()
    end

    if token and i >= token.fpos and i <= token.lpos then
      local ast = token.ast
      if token.tag == 'Id' then
        if ast.localdefinition then -- local
          if not ast.localdefinition.isused and not ast.isignore then
            styler:SetState(S_LOCAL_UNUSED)
          elseif ast.localdefinition.functionlevel  < ast.functionlevel then  -- upvalue
            if ast.localdefinition.isset then
              styler:SetState(S_UPVALUE_MUTATE)
            else
              styler:SetState(S_UPVALUE)
            end
          elseif ast.localdefinition.isparam then
            if ast.localdefinition.isset then
              styler:SetState(S_LOCAL_PARAM_MUTATE)
            else
              styler:SetState(S_LOCAL_PARAM)
            end
          else
            if ast.localdefinition.isset then
              styler:SetState(S_LOCAL_MUTATE)
            else
              styler:SetState(S_LOCAL)
            end
          end
        else -- global
          if ast.definedglobal then
            styler:SetState(S_GLOBAL_RECOGNIZED)
          else
            styler:SetState(S_GLOBAL_UNRECOGNIZED)
          end
        end
      elseif ast.isfield then -- implies token.tag == 'String'
        local val = ast.seevalue.value
        if ast.definedglobal or val ~= T.universal and not T.iserror[val] and val ~= nil then
          styler:SetState(S_FIELD_RECOGNIZED)
        else
          styler:SetState(S_FIELD)
        end
      elseif token.tag == 'Comment' then
        styler:SetState(S_COMMENT)
      elseif token.tag == 'String' then -- note: excludes ast.isfield
        styler:SetState(S_STRING)
      elseif token.tag == 'Keyword' then
        styler:SetState(S_KEYWORD)
      else
        styler:SetState(S_DEFAULT)
      end
    elseif styler:Current() == '\t' then
      styler:SetState(S_TAB)
    else
      styler:SetState(S_DEFAULT)
    end
    styler:Forward()
    i = i + #styler:Current()  -- support Unicode
  end
  styler:EndStyling()

  -- Apply indicators in token list.
  -- Mark masking local variables and warnings.
  editor.IndicatorCurrent = INDICATOR_MASKING
  editor:IndicatorClearRange(0, editor.Length)
  editor.IndicatorCurrent = INDICATOR_WARNING
  editor:IndicatorClearRange(0, editor.Length)
  editor.IndicatorCurrent = INDICATOR_DEADCODE
  editor:IndicatorClearRange(0, editor.Length)
  local tokenlist = buffer.tokenlist
  for idx=1,#tokenlist do
    local token = tokenlist[idx]
    local ast = token.ast
    if ast and ast.localmasking and not ast.isignore then
      editor.IndicatorCurrent = INDICATOR_MASKING
      editor:IndicatorFillRange(token.fpos-1, token.lpos - token.fpos + 1)
    end
    if ast and (ast.seevalue or ast).note then
      local hast = ast.seevalue or ast
      if hast.tag == 'Call' then hast = hast[1] elseif hast.tag == 'Invoke' then hast = hast[2] end
        -- note: for calls only highlight function name
      local fpos, lpos = LA.ast_pos_range(hast, buffer.tokenlist)
      editor.IndicatorCurrent = INDICATOR_WARNING
      editor:IndicatorFillRange(fpos-1, lpos-fpos+1)
    end
    if ast and ast.isdead then
      local fpos, lpos = LA.ast_pos_range(ast, buffer.tokenlist)
      editor.IndicatorCurrent = INDICATOR_DEADCODE
      editor:IndicatorFillRange(fpos-1, lpos-fpos+1)
    end
  end

  -- Apply folding.
  if ENABLE_FOLDING then
    clockbegin 'f1'
    local fsline1 = editor:LineFromPosition(startpos0)+1
    local lsline1 = editor:LineFromPosition(endpos0)+1
    --print('DEBUG:+', linea0,lineb0) -- test for recursion
    -- IMPROVE: This might be done only over styler.startPos, styler.lengthDoc.
    --   Does that improve performance?
    local level = 0
    local levels = {}
    local plinenum1 = 1
    local firstseen = {}
    for _, token in ipairs(buffer.tokenlist) do
      -- Fill line numbers up to and including this token.
      local llinenum1 = editor:LineFromPosition(token.lpos-1)+1
          -- note: much faster than non-caching LA.pos_to_linecol.
      for linenum1=plinenum1,llinenum1 do levels[linenum1] = levels[linenum1] or level end

      -- Monitor level changes and set any header flags.
      if token.ast and token.ast.tag == 'Function' then
        if not firstseen[token.ast] then
           level = level + 1
           firstseen[token.ast] = llinenum1
        elseif token[1] == 'end' then
          level = level -1
          local beginlinenum1 = firstseen[token.ast]
          if llinenum1 > beginlinenum1 then
            local old_value = levels[beginlinenum1]
            if old_value < SC_FOLDLEVELHEADERFLAG then
             levels[beginlinenum1] = old_value + SC_FOLDLEVELHEADERFLAG
            end
          end
        end
      end -- careful: in Metalua, `function` is not always part of the `Function node.

      plinenum1 = llinenum1 + 1
    end
    for line1=plinenum1,editor.LineCount do levels[line1] = level end -- fill remaining
    --for line1=1,#levels do print('DEBUG:', line1, levels[line1]) end
    for line1=1,#levels do -- apply
    --for line1=fsline1,lsline1 do -- apply
      styler:SetLevelAt(line1-1, levels[line1])
        --Q:why does this seem to sometimes trigger recursive OnStyle calls? (see below).
    end
    clockend 'f2'
    -- Caution: careful folding if StartStyling is performed over a range larger
    --   than suggested by startPos/lengthDoc.
    -- Note: Folding sometimes tend to trigger OnStyle recursion, leading to odd problems.  This
    --   seems reduced now but not gone (e.g. load types.lua).
    --   The following old comments are left here:
    -- #  Changing a flag on a line more than once triggers heavy recursion, even stack overflow:
    -- #     styler:SetLevelAt(0,1)
    -- #     styler:SetLevelAt(0,1 + SC_FOLDLEVELHEADERFLAG)
    -- #  Setting levels only on lines being styled may reduce though not eliminate recursion.
    -- #  Iterating in reverse may reduce though not eliminate recursion.
    -- #  Disabling folding completely eliminates recursion.
    --print'DEBUG:-'  -- test for recursion
  end

  debug_recursion = debug_recursion - 1
end


-- CATEGORY: SciTE event handler
function M.OnDoubleClick()
  if buffer.src ~= editor:GetText() then return end -- skip if AST is not up-to-date

  -- check if selection if currently on identifier
  local token = getselectedvariable()
  if token and token.ast then
    local info  = LI.get_value_details(token.ast, buffer.tokenlist, buffer.src)
    editor:CallTipShow(token.fpos-1, info)
  end
end


--TODO:ExtMan: add to extman?  Currently extman includes scite_UserListShow wrapping UserListShow
--CAREFUL: must be properly sorted (toupper if AutoCIgnoreCase)
-- CATEGORY: utility, GUI
local function mycshow(list, len)
  editor.AutoCSeparator = 1
  editor.AutoCIgnoreCase = true
  editor:AutoCShow(len or 0, table.concat(list, '\1'))
end


-- Converts object to string (no nesting).
-- CATEGORY: utility function, string
local function dump_shallow(o)
  return type(o) == 'string' and string.format('%q', o) or tostring(o)
end

-- Converts table key to string (no nesting)
-- utility function
local iskeyword_ = {
  ['and']=true, ['break']=true, ['do']=true, ['else']=true, ['elseif']=true,
  ['end']=true, ['false']=true, ['for']=true, ['function']=true, ['if']=true,
  ['in']=true, ['local']=true, ['nil']=true, ['not']=true, ['or']=true,
  ['repeat']=true, ['return']=true, ['then']=true, ['true']=true, ['until']=true, ['while']=true
}
local function dump_key_shallow(o)
  return type(o) == 'string' and o:match'^[%a_][%w_]*$' and not iskeyword_[o] and o
           or "[" .. dump_shallow(o) .. "]"
end

-- Finds index i such that t[i] == e, else returns nil
-- CATEGORY: utility function, tables
local function tfind(t, e)
  for i=1,#t do
    if t[i] == e then return i end
  end
  return nil
end


-- Gets array of identifier names in prefix expression preceeding pos0.
-- Attempts even if AST is not up-to-date.
-- warning: very rough, only recognizes simplest cases.  A better solution is
-- probably to have the parser return an incomplete AST on failure and use that.
-- CATEGORY: helper, SciTE buffer
local function get_prefixexp(pos0)
  local ids = {}
  repeat
    local fpos0 = editor:WordStartPosition(pos0, true)
    local word = editor:textrange(fpos0,pos0)
    table.insert(ids, 1, word)
    local c = editor:textrange(fpos0-1, fpos0)
    pos0 = fpos0-1
  until c ~= '.' and c ~= ':'
  return ids
end


-- Command to autocomplete current variable or function arguments.
-- CATEGORY: SciTE command and (dual use) helper
function M.autocomplete_variable(_, minchars)
  local lpos0 = editor.CurrentPos
  local c = editor:textrange(lpos0-1, lpos0)
  if c == '(' then -- function arguments
    local ids = get_prefixexp(lpos0-1)
    if ids[1] ~= '' then
      local scope = LI.get_scope(lpos0-1, buffer.ast, buffer.tokenlist)
      local o, err = LI.resolve_prefixexp(ids, scope, buffer.ast.valueglobals, _G)
      if not err then
        local sig = LI.get_signature_of_value(o)
        if sig then
          editor:CallTipShow(lpos0, sig)
        end
      end
    end
  else -- variable
    local fpos0 = editor:WordStartPosition(lpos0, true)
    if lpos0 - fpos0 >= (minchars or 0) then
      local ids = get_prefixexp(editor.CurrentPos)
      table.remove(ids)
      local names = LI.names_in_prefixexp(ids, lpos0, buffer.ast, buffer.tokenlist)
      for i,name in ipairs(names) do names[i] = dump_key_shallow(name) end
          --IMPROVE: remove '.' if key must uses square brackets on indexing.
          --IMPROVE: For method calls ':', square bracket key isn't support in Lua, so prevent that.
      table.sort(names, function(a,b) return a:upper() < b:upper() end)
      if #names > 0 then -- display
        mycshow(names, lpos0-fpos0)
      end
    end
  end
end


-- CATEGORY: SciTE event handler
function M.OnChar(c)
  -- FIX: how do we make this event only occur for Lua buffers?
  -- Hack below probably won't work with multiple Lua-based lexers.
  if editor.Lexer ~= 0 then return end

  -- Auto-complete variable names.
  -- note: test ./: not effective
  if AUTOCOMPLETE_VARS and
    buffer.ast and (not editor:AutoCActive() or c == '.' or c == ':'  or c == '(')
  then
    M.autocomplete_variable(nil, 1)
  end

  -- Ignore character typed over autocompleted text.
  -- Q: is this the best way to ignore/delete current char?
  if AUTOCOMPLETE_SYNTAX and editor:IndicatorValueAt(INDICATOR_AUTOCOMPLETE, editor.CurrentPos) == 1 then
    if editor.CharAt[editor.CurrentPos] == editor.CharAt[editor.CurrentPos-1] then
      editor.TargetStart = editor.CurrentPos
      editor.TargetEnd = editor.CurrentPos+1
      editor:ReplaceTarget("")
    else
      -- chars typed should not be have autocomplete indicators on them.
      editor.IndicatorCurrent = INDICATOR_AUTOCOMPLETE
      editor:IndicatorClearRange(editor.CurrentPos-1,1)
    end
  end
end


-- key codes
local KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER
if scite_GetProp('PLAT_GTK') then
  KEY_UP = 65365
  KEY_DOWN = 65364
  KEY_LEFT = 65361
  KEY_RIGHT = 65363
  KEY_ENTER = 65293
else -- Windows
  KEY_UP = 38
  KEY_DOWN = 40
  KEY_LEFT = 37
  KEY_RIGHT = 39
  KEY_ENTER = 13
end


-- CATEGORY: SciTE event handler
function M.OnKey(key)
  -- Adjusting styling delays due to user typing.
  if key == KEY_UP or key == KEY_DOWN or
     key == KEY_LEFT or key == KEY_RIGHT or key == KEY_ENTER
  then -- trigger on line/cursor change
    style_delay_count = 0
  else  -- delay for all other user typing
    style_delay_count = UPDATE_DELAY
  end
  --print('DEBUG:key', key)
end


-- CATEGORY: SciTE event handler
function M.OnOpen()
  -- Trigger styling immediately on new file open
  -- Note: only happens in current buffer; therefore, also do this in OnSwitchFile.
  style_delay_count = 0
end


-- CATEGORY: SciTE event handler
function M.OnBeforeSave()
  -- Trigger styling immediately before save.
  style_delay_count = 0
end


-- CATEGORY: SciTE event handler
function M.OnSwitchFile()
  -- Trigger styling immediately on switch buffer so that styling immediately displays.
  style_delay_count = 0
end


-- Command for replacing all occurances of selected variable (if any) with given text `newname`
-- Usage in SciTE properties file:
-- CATEGORY: SciTE command
function M.rename_selected_variable(newname)
  local selectedtoken = getselectedvariable()

  if selectedtoken and selectedtoken.ast then
    local id = selectedtoken.ast.id
    editor:BeginUndoAction()
    local lasttoken
    for i=#buffer.tokenlist,1,-1 do
      local token = buffer.tokenlist[i]
      local ast = token.ast
      if ast and ast.id == id then
        editor:SetSel(token.fpos-1, token.lpos)
        editor:ReplaceSel(newname)
        lasttoken = token
      end
    end
    if lasttoken then
      editor:SetSel(lasttoken.fpos-1, lasttoken.fpos + newname:len())
      editor.Anchor = lasttoken.fpos-1
    end
    editor:EndUndoAction()
  end
end
-- IMPROVE: prevent rename to conflicting existing variable.


-- Jumps to 0-indexed line in file path.
-- Preferrably jump to exact position if given, else 0-indexed line.
-- CATEGORY: SciTE helper, navigation
local function goto_file_line_pos(path, line0, pos0)
  scite.Open(path)
  if pos0 then
    editor:GotoPos(pos0)
  else
    editor:GotoLine(line0)
  end
end


-- Command for going to definition of selected variable.
-- TODO: currently only works for locals in the same file.
-- CATEGORY: SciTE command
function M.goto_definition()
  local selectedtoken = getselectedvariable()
  if selectedtoken then
    local fpos, fline, path = LI.ast_to_definition_position(selectedtoken.ast, buffer.tokenlist)
    if not fline and fpos then
      fline = editor:LineFromPosition(fpos-1)+1
    end
    if fline then
      if set_mark then set_mark() end -- if ctagsdx.lua available
      goto_file_line_pos(path, fline and fline-1, fpos and fpos-1)
    end
  end
end


local inspect_queued

-- Displays value in drop-down list for user inspection of contents.
-- User can navigate in and out of tables, in a stack-like manner.
-- CATEGORY: GUI inspection helper
local function inspect_value(o, prevmenu)
  if type(o) == 'table' and (T.istabletype[o] or not T.istype[o]) then
    local data = {}
    local ok, err = pcall(function()
      for k,v in pairs(o) do
        local ks = dump_key_shallow(k); if ks:len() > 50 then ks = ks:sub(1,50)..'...' end
        local vs = dump_shallow(v); if vs:len() > 50 then vs = vs:sub(1,50)..'...' end
        data[#data+1] = {ks .. "=" .. vs, v}
      end
    end)
    local list = {}
    if ok then
      table.sort(data, function(a,b) return a[1]:upper() < b[1]:upper() end)
        -- note: data must be sorted this way under editor.AutoCIgnoreCase==true;
        -- otherwise, AutoCSelect will not work properly.
      for i=1,#data do list[i] = data[i][1] end
    else
      data = {}
      list[#list+1] = '\tError: Could not read table: ' .. tostring(err)
    end
    table.insert(list, 1, "\t{" .. (prevmenu and ' (navigate back)' or ''))
    table.insert(list, "}")
      -- note: \t ensure list is remains sorted.
    local selectidx
    local function menu()
      editor.AutoCIgnoreCase = true
      scite_UserListShow(list, 1, function(text)
        selectidx = tfind(list, text)
        if selectidx then
          if text:match'^[%[%"%a_]' then
            local val = data[selectidx-1][2]
            if type(val) == 'table' then
              -- This doesn't work.  scite:UserListShow from inside OnUserListSelection
              -- has no effect. Q:Why?
              --inspect_value(val)
              -- workaround:
              inspect_queued = function() inspect_value(val, menu) end
              scite_MenuCommand('Inspect table contents')
            end
          else -- go back
            if prevmenu then
              inspect_queued = prevmenu
              scite_MenuCommand('Inspect table contents')
            end
          end
        end
      end)
      if selectidx then editor.AutoCAutoHide=false; editor:AutoCSelect(list[selectidx]) end
    end
    menu()
  else
    scite_UserListShow({dump_shallow(o)})
  end
end


-- Command for inspecting fields of selected table variable.
-- CATEGORY: SciTE command
function M.inspect_variable_contents()
  if inspect_queued then
    local f = inspect_queued; inspect_queued = nil; f()
    return
  end
  local token = getselectedvariable()
  if not token or not token.ast then return end
  local ast = token.ast

  local iast = ast.seevalue or ast

  if T.istype[iast.value] and not T.istabletype[iast.value] then
    scite_UserListShow({"value " .. tostring(iast.value)})
  else
    inspect_value(iast.value)
  end
  -- unfortunately, userdata is not inspectable without 5.2 __pairs.
end

-- Command to show all uses of selected variable
-- CATEGORY: SciTE command
function M.show_all_variable_uses()
  local stoken = getselectedvariable()
  if not stoken or not stoken.ast then return end

  local pos0of = {}

  editor.AutoCSeparator = 1
  local infos = {}
  for _,token in ipairs(buffer.tokenlist) do
    if token.ast and token.ast.id == stoken.ast.id then
      local pos0 = token.fpos-1
      local linenum0 = editor:LineFromPosition(pos0)
      local linenum1 = linenum0 + 1
      if not pos0of[linenum1] then
        pos0of[linenum1] = pos0
        infos[#infos+1] = linenum1 .. ": " .. editor:GetLine(linenum0):gsub("[\r\n]+$", "")
      end
    end
  end
  --editor:UserListShow(1, table.concat(infos, "\1"))
  scite_UserListShow(infos, 1, function(text)
    local linenum1 = tonumber(text:match("^%d+"))
    if set_mark then set_mark() end -- if ctagsdx.lua available
    editor:GotoPos(pos0of[linenum1])
  end)
end


-- Command for forcing redoing of inspection.  Note: reloads modules imported via require.
-- CATEGORY: SciTE command
function M.force_reinspect()
  if buffer.ast then
    LI.uninspect(buffer.ast)
    LI.clear_cache()
    collectgarbage() -- note package.loaded was given weak keys.
    LI.inspect(buffer.ast, buffer.tokenlist, buffer.src, report)
  end
end
--IMPROVE? possibly should reparse AST as well in case AST got corrupted.


-- Command to list erorrs and warnings.
-- CATEGORY: SciTE command
function M.list_warnings()
  if not buffer.ast then return end

  local warnings = LI.list_warnings(buffer.tokenlist, buffer.src)

  if #warnings > 0 then
    for i,err in ipairs(warnings) do
      print(err)
    end
    print("To loop through warnings, press F4.")
    --scite_UserListShow(errors)
  end
end


-- Command to select smallest statement (or comment) containing selection.
-- Executing multiple times selects larger statements containing current statement.
-- CATEGORY: SciTE command
function M.select_statementblockcomment()
  if buffer.src ~= editor:GetText() then return end  -- skip if AST not up-to-date

  -- Get selected position range.
  -- caution: SciTE appears to have an odd behavior where if SetSel
  --   is performed with CurrentPos at the start of a new line,
  --   then Anchor and CurrentPos get reversed.  Similar behavior is observed
  --   when holding down the shift key and pressing the right arrow key
  --   until the cursor advances to the next line.
  --   In any case, we want to handle reversed ranges.
  local fpos, lpos = editor.Anchor, editor.CurrentPos
  if lpos < fpos then fpos, lpos = lpos, fpos end -- swap
  fpos, lpos = fpos + 1, lpos + 1 - 1
  local fpos, lpos = LA.select_statementblockcomment(buffer.ast, buffer.tokenlist, fpos, lpos, true)
  editor:SetSel(fpos-1, lpos-1 + 1)
end


-- Command to jump to beginning or end of previous statement (whichever is closer).
-- CATEGORY: SciTE command
function M.goto_previous_statement()
  local pos1 = editor.CurrentPos+1
  if pos1 == 1 then return end
  pos1 = pos1 - 1 -- ensures repeated calls advance back
  local mast, isafter = LA.current_statementblock(buffer.ast, buffer.tokenlist, pos1)
  local fpos, lpos = LA.ast_pos_range(mast, buffer.tokenlist)
  if (editor.CurrentPos+1) > lpos + 1 then
    editor:GotoPos(lpos+1-1)
  else
    editor:GotoPos(fpos-1)
  end
end

-- Lua module searcher function that attemps to retrieve module from
-- same file path as current file.
-- CATEGORY: SciTE + file loading
local function mysearcher(name)
  local tries = ""
  local dir = props.FileDir
  repeat
    for i=1,2 do
      local path = dir .. '/' .. name:gsub("%.", "/") ..
        (i==1 and ".lua" or "/init.lua")
      --DEBUG(path)
      local f, err = loadfile(path)
      if f then return f end
      tries = tries .. "\tno file " .. path .. "\n"
    end
    dir = dir:gsub("[\\/]?[^\\/]+$", "")
  until dir == ''
  return tries
end


-- Installs properties and other global changes during startup.
-- This function should be called via something like
--
--   local LUAINSPECT_PATH = "c:/lua-inspect"
--   package.path = package.path .. ";" .. LUAINSPECT_PATH .. "/metalualib/?.lua"
--   package.path = package.path .. ";" .. LUAINSPECT_PATH .. "/lib/?.lua"
--   require "luainspect.scite".install()
--
-- from the SciTE Lua startup script, i.e. the file identified in the
-- `ext.lua.startup.script` property.
-- If the Lua startup script is ExtMan, you may optionally instead call
-- this from an ExtMan script (i.e. Lua file inside the ExtMan "scite_lua" folder.
-- This function does not work correctly if called from a Lua extension script,
-- i.e. the file identified in the `extension.*.lua` property, because by the
-- time the extension script has been loaded SciTE has already applied
-- styles from the properties so customizations here will be ignored until a
-- buffer switch.
--
-- CATEGORY: initialization
function M.install()

  -- apply styles if not overridden in properties file.

  if props['extension.*.lua'] == '' then
    local thisfilepath = assert(assert(debug.getinfo(1).source):gsub('^@', ''))
    print(thisfilepath)
    props['extension.*.lua'] = thisfilepath
      -- Q: is there a cleaner way?
  end

  local light_styles = [[
# This can be customized in your properties file.
lexer.*.lua=script_lua
style.script_lua.default=fore:#000000
style.script_lua.local=fore:#000080
style.script_lua.local_mutate=fore:#000080,italics
style.script_lua.local_unused=fore:#ffffff,back:#000080
style.script_lua.local_param=fore:#000040
style.script_lua.local_param_mutate=fore:#000040,italics
style.script_lua.upvalue=fore:#0000ff
style.script_lua.upvalue_mutate=fore:#0000ff,italics
style.script_lua.global_recognized=fore:#600000
style.script_lua.global_unrecognized=fore:#ffffff,back:#ff0000,bold
style.script_lua.field_recognized=fore:#600000
style.script_lua.field=fore:#c00000
style.script_lua.comment=fore:#008000
style.script_lua.string=fore:#00c000
style.script_lua.tab=back:#f0f0f0
style.script_lua.keyword=fore:#505050,bold
style.script_lua.compiler_error=fore:#800000,back:#ffffc0

# From SciTE docs:
# As well as the styles generated by the lexer, there are other numbered styles used.
# Style 32 is the default style and its features will be inherited by all other styles unless overridden.
# Style 33 is used to display line numbers in the margin.
# Styles 34 and 35 are used to display matching and non-matching braces respectively.
# Style 36 is used for displaying control characters. This is not a full style as the foreground and background colours for control characters are determined by their lexical state rather than this style.
# Style 37 is used for displaying indentation guides. Only the fore and back are used.
# A * can be used instead of a lexer to indicate a global style setting.
#style.script_lua.32=back:#000000
#style.script_lua.33=
#style.script_lua.33=
#style.script_lua.34=
#style.script_lua.36=
#style.script_lua.37=

# warning: these changes are global for all file types:
caret.line.back=#ffff00
caret.line.back.alpha=20
]]

  -- or dark background style
  local dark_styles = [[
lexer.*.lua=script_lua
style.script_lua.32=back:#000000
style.script_lua.default=fore:#ffffff
style.script_lua.local=fore:#c0c0ff
style.script_lua.local_mutate=fore:#c0c0ff,italics
style.script_lua.local_unused=fore:#ffffff,back:#000080
style.script_lua.local_param=fore:#8080ff
style.script_lua.local_param_mutate=fore:#8080ff,italics
style.script_lua.upvalue=fore:#e8e8ff
style.script_lua.upvalue_mutate=fore:#e8e8ff,italics
style.script_lua.global_recognized=fore:#ffc080
style.script_lua.global_unrecognized=fore:#ffffff,back:#ff0000,bold
style.script_lua.field_recognized=fore:#ffc080
style.script_lua.field=fore:#ff0000
style.script_lua.comment=fore:#009000
style.script_lua.string=fore:#80c080
style.script_lua.tab=back:#303030
style.script_lua.keyword=fore:#a0a080,bold
style.script_lua.compiler_error=fore:#800000,back:#ffffc0
style.script_lua.indic_style=6
style.script_lua.indic_fore=#808080
# warning: these changes are global for all file types.  Avoid #ffffff in case those
# are light styles
style.script_lua.caret.fore=#c0c0c0
style.script_lua.caret.line.back=#ffff00
style.script_lua.caret.line.back.alpha=20
style.script_lua.selection.alpha=128
style.script_lua.selection.back=#808080
]]

  local styles = (props['style.script_lua.scheme'] == 'dark') and dark_styles or light_styles

  for style in styles:gmatch("[^\n]+") do
    if not (style:match("^%s*#") or style:match("^%s*$")) then
        local name, value = style:match("^([^=]+)=(.*)"); assert(name, style)
        local realname =string.gsub(name, '^(style%.script_lua%.)(.+)$', function(first, last)
          return STYLES[last] and first .. STYLES[last] or
                    last:match'^%d+$' and name or last
        end) -- convert to real style name
        if props[name] ~= '' then value = props[name] end -- override by user
        --DEBUG(realname .. '=' .. value)
        props[realname] = value
    end
  end
  -- DESIGN:SciTE: The above technique does not work ideally.  A property like `selection.back`
  -- may be pre-defined by SciTE, and then we'd want this script to override that default, and
  -- finally we'd want to allow the user to override that in property files.  However, this script
  -- is run after property files are applied and doesn't know whether a property
  -- has been re-defined in a property file unless the property was left blank by SciTE and the
  -- user property file changed it to a non-blank value.  This is the reason why the above
  -- dark_styles uses style.script_lua.selection.back (which is undefined by SciTE) rather
  -- than selection.back (which SciTE may predefine to a non-blank value).  It would be
  -- preferrable if SciTE would allow this script to define default properties before properties
  -- are read from property files.

  scite_Command("Rename all instances of selected variable|*luainspect_rename_selected_variable $(1)|*.lua|Ctrl+Alt+R")
  scite_Command("Go to definition of selected variable|luainspect_goto_definition|*.lua|Ctrl+Alt+D")
  scite_Command("Show all variable uses|luainspect_show_all_variable_uses|*.lua|Ctrl+Alt+U")
  scite_Command("Inspect table contents|luainspect_inspect_variable_contents|*.lua|Ctrl+Alt+B")
  scite_Command("Select current statement, block or comment|luainspect_select_statementblockcomment|*.lua|Ctrl+Alt+S")
  scite_Command("Force full reinspection of all code|luainspect_force_reinspect|*.lua|Ctrl+Alt+Z")
  scite_Command("Goto previous statement|luainspect_goto_previous_statement|*.lua|Ctrl+Alt+Up")
  scite_Command("Autocomplete variable|luainspect_autocomplete_variable|*.lua|Ctrl+Alt+C")
  scite_Command("List all errors/warnings|luainspect_list_warnings|*.lua|Ctrl+Alt+E")
  --FIX: user.context.menu=Rename all instances of selected variable|1102 or props['user.contextmenu']
  _G.luainspect_rename_selected_variable = M.rename_selected_variable
  _G.luainspect_goto_definition = M.goto_definition
  _G.luainspect_inspect_variable_contents = M.inspect_variable_contents
  _G.luainspect_show_all_variable_uses = M.show_all_variable_uses
  _G.luainspect_select_statementblockcomment = M.select_statementblockcomment
  _G.luainspect_force_reinspect = M.force_reinspect
  _G.luainspect_goto_previous_statement = M.goto_previous_statement
  _G.luainspect_autocomplete_variable = M.autocomplete_variable
  _G.luainspect_list_warnings = M.list_warnings


  -- Allow finding modules.
  table.insert(package.loaders, mysearcher)
  if PATH_APPEND ~= '' then
    package.path = package.path .. ';' .. PATH_APPEND
  end
  if CPATH_APPEND ~= '' then
    package.cpath = package.cpath .. ';' .. CPATH_APPEND
  end

  -- Make package.loaded have weak values.  This makes modules more readilly get unloaded,
  -- such as when doing force_reinspect.
  -- WARNING: Global change to Lua.
  local oldmt = getmetatable(package.loaded)
  local mt = oldmt  or {}
  if not mt.__mode then mt.__mode = 'v' end
  if not oldmt then setmetatable(package.loaded, mt) end

  _G.luainspect_installed = true
end


-- Installs a SciTE event handler locally for the current buffer.
-- If an existing global handler exists (this includes ExtMan handlers),
-- ensure that is still called also.
-- CATEGORY: initialization.
local function install_handler(name)
  local local_handler = M[name]
  local global_handler = _G[name]
  _G[name] = function(...)
    local_handler(...)
    if global_handler then global_handler(...) end
  end
end


-- Installs extension interface.
-- This function should be called via
--
--    require "luainspect.scite".install_extension()
--
-- from your Lua extension script
-- (the file identified in your `extension.*.lua` property) or by
-- setting your `extension.*.lua` property to this file
-- (NOTE: the `install` function automatically does
-- this for you).  Do not call this from your SciTE Lua startup script
-- (the file identified in your `ext.lua.startup.script` property) because
-- that would activate these events for non-Lua files as well.
--
-- CATEGORY: initialization
function M.install_extension()
  if not _G.luainspect_installed then
    error([[
ERROR: Please add `require "luainspect.scite".setup_install()` (but
without ``) to your SciTE Lua startup script (i.e. the file identified in your
`ext.lua.startup.script` property (i.e. ]] .. props['ext.lua.startup.script'] ..').', 0)
  end

  -- Install event handlers for this buffer.
  install_handler'OnStyle'
  install_handler'OnUpdateUI'
  install_handler'OnDoubleClick'
  if AUTOCOMPLETE_VARS or AUTOCOMPLETE_SYNTAX then
    install_handler'OnChar'
  end
  install_handler'OnKey'
  install_handler'OnOpen'
  install_handler'OnBeforeSave'
  install_handler'OnSwitchFile'

  -- Define markers and indicators.
  editor:MarkerDefine(MARKER_ERRORLINE, SC_MARK_CHARACTER+33) -- '!'
  editor:MarkerSetFore(MARKER_ERRORLINE, 0xffffff)
  editor:MarkerSetBack(MARKER_ERRORLINE, 0x0000ff)
  editor:MarkerDefine(MARKER_ERROR, SC_MARK_FULLRECT)
  editor:MarkerSetBack(MARKER_ERROR, 0x000080)
  editor:MarkerSetAlpha(MARKER_ERROR, 10)
  editor:MarkerDefine(MARKER_SCOPEBEGIN, SC_MARK_TCORNERCURVE)
  editor:MarkerDefine(MARKER_SCOPEMIDDLE, SC_MARK_VLINE)
  editor:MarkerDefine(MARKER_SCOPEEND, SC_MARK_LCORNERCURVE)
  editor:MarkerSetFore(MARKER_SCOPEBEGIN, 0x0000ff)
  editor:MarkerSetFore(MARKER_SCOPEMIDDLE, 0x0000ff)
  editor:MarkerSetFore(MARKER_SCOPEEND, 0x0000ff)
  editor:MarkerDefine(MARKER_MASKED, SC_MARK_CHARACTER+77) -- 'M'
  editor:MarkerSetFore(MARKER_MASKED, 0xffffff)
  editor:MarkerSetBack(MARKER_MASKED, 0x000080)
  editor:MarkerDefine(MARKER_MASKING, SC_MARK_CHARACTER+77) -- 'M'
  editor:MarkerSetFore(MARKER_MASKING, 0xffffff)
  editor:MarkerSetBack(MARKER_MASKING, 0x0000ff)
  editor:MarkerDefine(MARKER_WAIT, SC_MARK_CHARACTER+43) -- '+'
  editor:MarkerSetFore(MARKER_WAIT, 0xffffff)
  editor:MarkerSetBack(MARKER_WAIT, 0xff0000)
  editor.IndicStyle[INDICATOR_AUTOCOMPLETE] = INDIC_BOX
  editor.IndicFore[INDICATOR_AUTOCOMPLETE] = 0xff0000
  local indic_style = props["style.script_lua.indic_style"]
  local indic_fore = props["style.script_lua.indic_fore"]
  editor.IndicStyle[INDICATOR_SCOPE] =
    indic_style == '' and INDIC_ROUNDBOX or indic_style
  editor.IndicStyle[INDICATOR_KEYWORD] = INDIC_PLAIN
  if indic_fore ~= '' then
    local color = tonumber(indic_fore:sub(2), 16)
    editor.IndicFore[INDICATOR_SCOPE] = color
    editor.IndicFore[INDICATOR_KEYWORD] = color
  end
  editor.IndicStyle[INDICATOR_MASKED] = INDIC_STRIKE
  editor.IndicFore[INDICATOR_MASKED] = 0x0000ff
  editor.IndicStyle[INDICATOR_MASKING] = INDIC_SQUIGGLE
  editor.IndicFore[INDICATOR_MASKING] = 0x0000ff
  editor.IndicStyle[INDICATOR_WARNING] = INDIC_SQUIGGLE  -- IMPROVE: combine with above?
  editor.IndicFore[INDICATOR_WARNING] = 0x008080
  editor.IndicStyle[INDICATOR_DEADCODE] = INDIC_ROUNDBOX
  editor.IndicFore[INDICATOR_DEADCODE] = 0x808080
  editor.IndicAlpha[INDICATOR_DEADCODE] = 0x80
  --  editor.IndicStyle[INDICATOR_INVALIDATED] = INDIC_SQUIGGLE
  --  editor.IndicFore[INDICATOR_INVALIDATED] = 0x0000ff


end


-- If this module was not loaded via require, then assume it is being loaded
-- as a SciTE Lua extension script, i.e. `extension.*.lua` property.
if ... == nil then
  M.install_extension()
end


-- COMMENT:SciTE: when Lua code fails, SciTE by default doesn't display a
--   full stack traceback (debug.traceback) to assist debugging.
--   Presumably the undocumented ext.lua.debug.traceback=1 enables this,
--   but it works oddly, installing `print` rather than `debug.traceback` as
--   the error handling function.  Although one can set print to debug.traceback,
--   that breaks print.


return M
