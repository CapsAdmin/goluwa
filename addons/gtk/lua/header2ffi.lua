local data = utilities.ParseHeader("gtk/gtk.h", {
	"X:/gtk/gtk+/", 
	"X:/gtk/atk/", 
	"X:/gtk/glib/glib/", 
	"X:/gtk/glib/", 
	"X:/gtk/pango/", 
	"X:/gtk/gdk-pixbuf/"
})

vfs.Write("x:/LOL.h", data.header)

print("done!") 