bit=bit or require "bit"

-- represents braille character that has 8 subpixel, values are used as offsets for the calculations.
local pixel_map = {{0x01, 0x08},
                   {0x02, 0x10},
                   {0x04, 0x20},
                   {0x40, 0x80}}

-- contains RGBA values, braille char retresentaion value and a UTF8 String that may be more than one char.
local Pixel = {}
Pixel.new = function(str, braille_rep, r, g, b, a)
	return {str = str or " ",
    braille_rep = braille_rep or 0,
    r = r or 255,
    g = g or 255,
    b = b or 255,
    a = a or 255}
end

-- braille unicode characters starts at 0x2800
local braille_char_offset = 0x2800

-- Creat new canvas with default values.
local Canvas = {}
Canvas.__index = Canvas
function Canvas.new()
    local self = setmetatable({}, Canvas)
    self.clear(self)
    -- This applies to waht Canvas.frame() will return.
    self.alpha_threshold = 10 -- Pixels with a alpha value below are printed as a space.
    self.esccodes = false -- Turn ecsape codes off (false) to use only your Terminal Standard Color.
    return self
end

-- Clears the canvas and all pixels.
function Canvas.clear(self)
    self.pixel_matrix = {}
    self.minrow = 0; self.mincol = 0;
    self.maxrow = 0; self.maxcol = 0;
    self.width = 0
    self.height = 0
end

-- Set a pixel on the canvas, if no RGB or A values are givven it defaults to white.
function Canvas.set(self, x, y, r, g, b, a)
    local row = math.floor(y / 4)
    local col = math.floor(x / 2)
    if self.pixel_matrix[row] == nil then
        self.pixel_matrix[row] = {}
    end
    if self.pixel_matrix[row][col] == nil then
        self.pixel_matrix[row][col] = Pixel.new(nil, nil,r,g,b,a)
    end
    local pixel = self.pixel_matrix[row][col]
    pixel.braille_rep = bit.bor(pixel.braille_rep, pixel_map[(y % 4) + 1][(x % 2) + 1])
    local char = braille_char_offset + pixel.braille_rep
    local outstr = ""
    outstr=outstr..string.char(128+64+32+bit.band(15, bit.rshift(char, 12)))
    outstr=outstr..string.char(bit.bor(128, bit.band(63, bit.rshift(char, 6))))
    outstr=outstr..string.char(bit.bor(128, bit.band(char, 63)))
    pixel.str = outstr
    self.pixel_matrix[row][col] = pixel
    -- Set min,max size of canvas
    if (row < self.minrow) then self.minrow = row end;
    if (row > self.maxrow) then self.maxrow = row end;
    if (col < self.mincol) then self.mincol = col end;
    if (col > self.maxcol) then self.maxcol = col end;
    self.width = -self.minrow+self.maxrow
    self.height = -self.mincol+self.maxcol
end

-- Returns a string of the Frame.
function Canvas.frame(self)
    local outstr=""
        for row=self.minrow, self.maxrow do
            for col=self.mincol, self.maxcol do
                -- check the pixels alpha threshold and add space if value is less.
                if self.pixel_matrix[row][col] and self.pixel_matrix[row][col].a > self.alpha_threshold then
                    local pixel = self.pixel_matrix[row][col]
                    if self.esccodes then
                        outstr=outstr..set_string_RGBColor(pixel.str,pixel.r,pixel.g,pixel.b)
                    else
                        outstr=outstr..pixel.str
                    end
                else
                    outstr=outstr.." "
                end
            end
            outstr=outstr.."\n"
        end
    return outstr
end

-- convenience method for use with curses
-- Prints the frame in curses Standard Screen.
function Canvas.cframe(self, curses, wnd)
	wnd = wnd or curses.stdscr()

    if curses  then
        for row=self.minrow, self.maxrow do
            for col=self.mincol, self.maxcol do
                -- check the pixels alpha threshold and print space if value is less.
                if self.pixel_matrix[row][col] and self.pixel_matrix[row][col].a > self.alpha_threshold then
                    local pixel = self.pixel_matrix[row][col]
                    local term256color = nearest_term256_color_index(pixel.r, pixel.g, pixel.b)
                    local cp = curses.color_pair(term256color)
                    wnd:attron(cp)
                    wnd:addstr(pixel.str)
                    wnd:attroff(cp)
                else
                    wnd:addstr(" ")
                end
            end
            wnd:addstr("\n")
        end
    else
        error("no stdscr or curses given")
    end
end

-- some functions to convert RGB values to a xterm-256colors index
-- ACKNOWLEDGMENT http://stackoverflow.com/questions/38045839/lua-xterm-256-colors-gradient-scripting
local abs, min, max, floor = math.abs, math.min, math.max, math.floor
local levels = {[0] = 0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff}

local function index_0_5(value) -- value = color component 0..255
   return floor(max((value - 35) / 40, value / 58))
end

local function nearest_16_231(r, g, b)   -- r, g, b = 0..255
   -- returns color_index_from_16_to_231, appr_r, appr_g, appr_b
   r, g, b = index_0_5(r), index_0_5(g), index_0_5(b)
   return 16 + 36 * r + 6 * g + b, levels[r], levels[g], levels[b]
end

local function nearest_232_255(r, g, b)  -- r, g, b = 0..255
   local gray = (3 * r + 10 * g + b) / 14
   -- this is a rational approximation for well-known formula
   -- gray = 0.2126 * r + 0.7152 * g + 0.0722 * b
   local index = min(23, max(0, floor((gray - 3) / 10)))
   gray = 8 + index * 10
   return 232 + index, gray, gray, gray
end

local function color_distance(r1, g1, b1, r2, g2, b2)
   return abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
end

function nearest_term256_color_index(r, g, b)   -- r, g, b = 0..255
   local idx1, r1, g1, b1 = nearest_16_231(r, g, b)
   local idx2, r2, g2, b2 = nearest_232_255(r, g, b)
   local dist1 = color_distance(r, g, b, r1, g1, b1)
   local dist2 = color_distance(r, g, b, r2, g2, b2)
   return dist1 < dist2 and idx1 or idx2
end

local unpack, tonumber = table.unpack or unpack, tonumber

local function convert_color_to_table(rrggbb)
   if type(rrggbb) == "string" then
      local r, g, b = rrggbb:match"(%x%x)(%x%x)(%x%x)"
      return {tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)}
   else
      return rrggbb
   end
end

-- Takes special formated string with xterm256 color index, prints string with the color EscCode.
local function print_with_colors(str)
   print(
      str:gsub("@x(%d%d%d)",
         function(color_idx)
            return "\27[38;5;"..color_idx.."m"
         end)
      .."\27[0m"
   )
end

-- Takes special formated string with xterm256 color index, returns string with the color EscCode.
local function string_with_colors(str)
return str:gsub("@x(%d%d%d)",
         function(color_idx)
            return "\27[38;5;"..color_idx.."m"
         end)
      .."\27[0m"
end

-- Takes string and RGB values, returns string with nearest xterm256 color EscCode.
function set_string_RGBColor(str,r,g,b)
    local colorstr = ("@x%03d"):format(nearest_term256_color_index(r,g,b))
    return string_with_colors(colorstr..str)
end

return Canvas