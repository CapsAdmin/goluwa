
--oo/controls/radiobutton: radio button control
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.basebuttonclass'

RadioButton = subclass({
	__style_bitmask = bitmask{
		box_align = {
			left = 0,
			right = BS_LEFTTEXT,
		},
		pushlike = BS_PUSHLIKE,
		autocheck = {
			[false] = BS_RADIOBUTTON,
			[true] = BS_AUTORADIOBUTTON,
		},
	},
	__defaults = {
		autocheck = true,
		text = 'Option',
		w = 100, h = 24,
	},
	__init_properties = {
		'checked'
	},
}, BaseButton)

function RadioButton:set_dontclick(dontclick) --Vista+
	Button_SetDontClick(self.hwnd, dontclick)
end

local button_states = {
	[false] = BST_UNCHECKED,
	[true] = BST_CHECKED,
}
local button_state_names = index(button_states)
function RadioButton:set_checked(checked)
	Button_SetCheck(self.hwnd, button_states[checked])
end
function RadioButton:get_checked()
	return button_state_names[bit.band(Button_GetCheck(self.hwnd), 3)]
end

--showcase

if not ... then
require'winapi.showcase'
local window = ShowcaseWindow{w=300,h=200}
local cb1 = RadioButton{parent = window, w = 200, text = 'I am The Ocean', checked = true,
							box_align = 'right', align = 'left', halign = 'center', flat = true,
							image_list = {image_list = ShowcaseImageList()}}
function cb1:on_click() print'b1 clicked' end

local cb2 = RadioButton{parent = window, y = 30, pushlike = true}

local cb3 = RadioButton{parent = window, y = 60, w = 150, h = 50,
							word_wrap = true, valign = 'top', double_clicks = true,
							text = "I'm a radioobutton and I'm ok. I sleep all night and I work all day."}
function cb3:on_double_click() print 'b3 dbl-clicked' end

MessageLoop()
end

