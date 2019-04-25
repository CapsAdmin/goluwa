
--oo/controls/label: standard label control
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.controlclass'
require'winapi.static'

Label = subclass({
	__style_bitmask = bitmask{
		align = {
			left = SS_LEFT,
			center = SS_CENTER,
			right = SS_RIGHT,
			simple = SS_SIMPLE,
			left_nowrap = SS_LEFTNOWORDWRAP,
		},
		accelerator_prefix = negate(SS_NOPREFIX), --don't do "&" character translation
		events = SS_NOTIFY, --send notifications
		owner_draw = SS_OWNERDRAW,
		simulate_edit = SS_EDITCONTROL,
		ellipsis = {
			[false] = 0,
			char = SS_ENDELLIPSIS,
			path = SS_PATHELLIPSIS,
			word = SS_WORDELLIPSIS,
		},
	},
	__defaults = {
		text = 'Text',
		w = 100, h = 21,
		events = true,
		accelerator_prefix = true,
	},
	__init_properties = {},
	__wm_command_handler_names = index{
		on_click = STN_CLICKED,
		on_double_click = STN_DBLCLK,
		on_enable = STN_ENABLE,
		on_disable = STN_DISABLE,
	},
}, Control)

function Label:__before_create(info, args)
	Label.__index.__before_create(self, info, args)
	args.text = info.text
	args.class = WC_STATIC
end

--showcase

if not ... then
	require'winapi.showcase'
	local window = ShowcaseWindow{w=300,h=200}
	local s1 = Label{
		parent = window,
		x = 10, y = 10, w = 100, h = 60,
		text = 'Hi there my sweet lemon drops!',
		align = 'right',
	}
	function s1:on_click()
		print'clicked'
	end
	MessageLoop()
end

