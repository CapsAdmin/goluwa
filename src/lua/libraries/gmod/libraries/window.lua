function gmod.env.system.HasFocus()
	return window.IsFocused()
end

function gmod.env.system.IsWindowed()
	return true
end

function gmod.env.SetClipboardText(str)
	window.SetClipboard(str)
end