
--oo/controls/listbox: standard listbox control
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.controlclass'
require'winapi.itemlist'
require'winapi.listbox'

LBItemList = class(ItemList)

function LBItemList:add(i,s) --returns index
	if not s then i,s = nil,i end
	if i then
		return ListBox_InsertString(self.hwnd, i, s)
	else
		return ListBox_AddString(self.hwnd, s)
	end
end

function LBItemList:remove(i) --returns count
	return ListBox_DeleteString(self.hwnd, i)
end

local function setitem(hwnd, i, s)
	ListBox_InsertString(hwnd, i, s)
	ListBox_DeleteString(hwnd, i+1)
end
function LBItemList:set(i,s) --there's no ListBox_SetString so we have to improvize
	self.window:batch_update(setitem, self.hwnd, i, s)
end

function LBItemList:get(i)
	return ListBox_GetString(self.hwnd, i)
end

function LBItemList:get_count()
	return ListBox_GetCount(self.hwnd)
end

function LBItemList:select(i) ListBox_SetCurSel(self.hwnd, i) end
function LBItemList:get_selected_index() return ListBox_GetCurSel(self.hwnd) end
function LBItemList:get_selected()
	local si = self:get_selected_index()
	return si and self:get(si)
end

--for ownerdraw lists only
function LBItemList:set_height(i, h) ListBox_SetItemHeight(self.hwnd, i, h) end
function LBItemList:get_height(i) return ListBox_GetItemHeight(self.hwnd, i) end


ListBox = subclass({
	__style_bitmask = bitmask{
		border = WS_BORDER,
		sort = LBS_SORT,
		select = {
			single = 0,
			multiple = LBS_MULTIPLESEL,
			extended = LBS_EXTENDEDSEL,
		},
		tabstops = LBS_USETABSTOPS,
		free_height = LBS_NOINTEGRALHEIGHT,
		multicolumn = LBS_MULTICOLUMN,
		vscroll = WS_VSCROLL,
		hscroll = WS_HSCROLL,
		always_show_scrollbars = LBS_DISABLENOSCROLL,
		allow_select = negate(LBS_NOSEL),
	},
	__style_ex_bitmask = bitmask{
		client_edge = WS_EX_CLIENTEDGE,
	},
	__defaults = {
		client_edge = true,
		free_height = true,
		vscroll = true,
		hscroll = true,
		always_show_scrollbars = true, --if disabled, either vscroll or hscroll must be disabled too!
		--window properties
		w = 100, h = 100,
	},
	__init_properties = {'sort', 'hextent'}, --LBS_SORT is not set initially. why?
	__wm_command_handler_names = index{
		on_memory_error = LBN_ERRSPACE,
		on_select = LBN_SELCHANGE,
		on_double_click = LBN_DBLCLK,
		on_cancel = LBN_SELCANCEL,
		on_focus = LBN_SETFOCUS,
		on_blur = LBN_KILLFOCUS,
	},
}, Control)

function ListBox:__before_create(info, args)
	ListBox.__index.__before_create(self, info, args)
	args.class = WC_LISTBOX
	args.style = bit.bor(args.style, LBS_NOTIFY, LBS_HASSTRINGS, LBS_WANTKEYBOARDINPUT)
	args.text = info.text
end

function ListBox:__init(info)
	ListBox.__index.__init(self, info)
	self.items = LBItemList(self)
end

function ListBox:get_hextent()
	return ListBox_GetHorizontalExtent(self.hwnd)
end

function ListBox:set_hextent(width)
	ListBox_SetHorizontalExtent(self.hwnd, width)
end


if not ... then
	require'winapi.showcase'
	local window = ShowcaseWindow{w=300,h=200}
	local lb = ListBox{parent = window, x = 10, y = 10, hextent = 120}
	for i = 1,100 do
		lb.items:add('xxxxxxxxxx test '..i)
	end
	MessageLoop()
end
