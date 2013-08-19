ffi.cdef([[
typedef enum
{
  GTK_WINDOW_TOPLEVEL,
  GTK_WINDOW_POPUP
} GtkWindowType;

typedef int gboolean;

typedef struct GtkWidget GtkWidget;
void gtk_init (int *argc, char ***argv);
void gtk_widget_show (GtkWidget *widget); 
GtkWidget* gtk_window_new (GtkWindowType type);
gboolean gtk_main_iteration_do(gboolean blocking);  
]]) 
 
local m = ffi.load("libgtk-win32-2.0-0.dll")
local GTK_WINDOW_TOPLEVEL = 0 
 
m.gtk_init(nil, nil)
local window = m.gtk_window_new(GTK_WINDOW_TOPLEVEL)
m.gtk_widget_show(window) 

event.AddListener("OnUpdate", "hello gtk", function(dt)
	m.gtk_main_iteration_do(0)
end) 

do return end 
  
lfs.chdir(path)

print(gtk)
do return end

local window = glw.OpenWindow(1280, 720)

event.AddListener("OnDraw", "hello gtk", function(dt)
	render.Start(window)			
		render.Start2D()		
		
		
		
	render.End() 
end) 
