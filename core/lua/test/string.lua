test(string.escape, "adw\a\b\f\n\r\t\vawd", 1).expect([[adw\a\b\f\n\r\t\vawd]])
test(string.indent, "foo\nbar\na", 1).expect("\tfoo\n\tbar\n\ta")
test(string.indent, "foo\nbar\na", 2).expect("\t\tfoo\n\t\tbar\n\t\ta")
test(string.buildclass, "%p", "%s", function(char)
	if char == "_" then return false end
end).expect("\t\n\v\f\r !\"#$%&'()*+,-./:;<=>?@[\\]^`{|}~")