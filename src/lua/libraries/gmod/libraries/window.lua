function gine.env.system.HasFocus()
	return window.IsFocused()
end

function gine.env.system.IsWindowed()
	return true
end

function gine.env.SetClipboardText(str)
	window.SetClipboard(str)
end
