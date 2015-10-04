
--oo/controls/toolbar: standard toolbar control
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.controlclass'
require'winapi.itemlist'
require'winapi.toolbar'

TBItemList = class(ItemList)

function TBItemList:add(i, item)
	if not item then i,item = nil,i end --i is optional
	if i then
		Toolbar_InsertButton(self.hwnd, i, item)
	else
		Toolbar_AddButton(self.hwnd, item)
	end
end

function TBItemList:remove(i)
	return Tooldbar_DeleteButton(self.hwnd, i)
end

function TBItemList:set(i, item)
	Toolbar_SetButtonInfo(self.hwnd, i, item)
end

function TBItemList:get(i)
	return Toolbar_GetButtonInfo(self.hwnd, i)
end

function TBItemList:get_count()
	return Toolbar_GetButtonCount(self.hwnd)
end

function TBItemList:get_text(i)
	return Toolbar_GetButtonText(self.hwnd, i)
end

Toolbar = subclass({
	__style_bitmask = bitmask{
		align = {
			top = CCS_TOP,
			bottom = CCS_BOTTOM,
		},
		customizable = CCS_ADJUSTABLE,
		tooltips = TBSTYLE_TOOLTIPS,
		multiline = TBSTYLE_WRAPABLE,
		alt_drag = TBSTYLE_ALTDRAG, --only if customizable
		flat = TBSTYLE_FLAT,
		list = TBSTYLE_LIST,  --not resettable
		custom_erase_background = TBSTYLE_CUSTOMERASE,
		is_drop_target = TBSTYLE_REGISTERDROP,
		transparent = TBSTYLE_TRANSPARENT, --not resettable
		no_divider = CCS_NODIVIDER,
		no_align = CCS_NOPARENTALIGN,
	},
	__style_ex_bitmask = bitmask{
		mixed_buttons = TBSTYLE_EX_MIXEDBUTTONS,
		hide_clipped_buttons = TBSTYLE_EX_HIDECLIPPEDBUTTONS,
		draw_drop_down_arrows = TBSTYLE_EX_DRAWDDARROWS, --requires window_edge!
		double_buffer = TBSTYLE_EX_DOUBLEBUFFER,
		window_edge = WS_EX_WINDOWEDGE, --false by default
	},
	__defaults = {
		w = 400, h = 48,
		align = 'top',
		accelerator_prefix = true,
	},
	__init_properties = {
		'image_list',
	},
	__wm_command_handler_names = index{
	},
	__wm_notify_handler_names = index{
		on_get_button_info = TBN_GETBUTTONINFOA,
		on_begin_drag = TBN_BEGINDRAG,
		on_end_drag = TBN_ENDDRAG,
		on_begin_adjust = TBN_BEGINADJUST,
		on_end_adjust = TBN_ENDADJUST,
		on_reset = TBN_RESET,
		on_inserting = TBN_QUERYINSERT,
		on_deleting = TBN_QUERYDELETE,
		on_change = TBN_TOOLBARCHANGE,
		on_help = TBN_CUSTHELP,
		on_dropdown = TBN_DROPDOWN,
		on_get_object = TBN_GETOBJECT,
	},
}, Control)

function Toolbar:__before_create(info, args)
	Toolbar.__index.__before_create(self, info, args)
	args.class = TOOLBARCLASSNAME
end

function Toolbar:__init(info)
	Toolbar.__index.__init(self, info)
	self.items = TBItemList(self, info.items)
end

function Toolbar:set_image_list(iml)
	Toolbar_SetImageList(self.hwnd, iml.himl)
end

function Toolbar:get_image_list(iml)
	ImageLists:find(Toolbar_GetImageList(self.hwnd))
end

function Toolbar:load_images(which)
	Toolbar_LoadImages(self.hwnd, which)
end

--showcase

if not ... then
	require'winapi.showcase'
	local win = ShowcaseWindow()

	local tb = Toolbar{
		parent = win,
		image_list = ImageList{w = 16, h = 16, masked = true, colors = '32bit'},
		items = {
			--NOTE: using `iBitmap` instead of `i` because `i` counts from 1
			{iBitmap = STD_FILENEW,  text = 'New'},
			{iBitmap = STD_FILEOPEN, text = 'Open', style = {toggle = true}},
			{iBitmap = STD_FILESAVE, text = 'Save', style = {type = 'dropdown'}},
		},
		anchors = {left = true, right = true},
	}
	tb:load_images(IDB_STD_SMALL_COLOR)

	function tb:on_dropdown(info)
		print('dropdown', info.button.iBitmap, info.rect.x, info.rect.y)
	end

	--TODO: this gives "The handle is invalid."
	--local item = tb.items:get(3)
	--print(require'pp'.format(item.state))

	MessageLoop()
end
