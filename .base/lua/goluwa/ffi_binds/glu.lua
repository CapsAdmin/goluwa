local header = [[
void gluOrtho2D ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
void gluPerspective ( GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);
void gluPickMatrix ( GLdouble x, GLdouble y, GLdouble width, GLdouble height, GLint viewport[4]);
void gluLookAt ( GLdouble eyex, GLdouble eyey, GLdouble eyez, GLdouble centerx, GLdouble centery, GLdouble centerz, GLdouble upx, GLdouble upy, GLdouble upz);
int gluProject ( GLdouble objx, GLdouble objy, GLdouble objz, const GLdouble modelMatrix[16], const GLdouble projMatrix[16], const GLint viewport[4], GLdouble *winx, GLdouble *winy, GLdouble *winz);
int gluUnProject ( GLdouble winx, GLdouble winy, GLdouble winz, const GLdouble modelMatrix[16], const GLdouble projMatrix[16], const GLint viewport[4], GLdouble *objx, GLdouble *objy, GLdouble *objz);
int gluScaleImage ( GLenum format, GLint widthin, GLint heightin, GLenum typein, const void *datain, GLint widthout, GLint heightout, GLenum typeout, void *dataout);
int gluBuild1DMipmaps ( GLenum target, GLint components, GLint width, GLenum format, GLenum type, const void *data);
int gluBuild2DMipmaps ( GLenum target, GLint components, GLint width, GLint height, GLenum format, GLenum type, const void *data);
GLUquadric* gluNewQuadric (void);
void gluDeleteQuadric ( GLUquadric *state);
void gluQuadricNormals ( GLUquadric *quadObject, GLenum normals);
void gluQuadricTexture ( GLUquadric *quadObject, GLboolean textureCoords);
void gluQuadricOrientation ( GLUquadric *quadObject, GLenum orientation);
void gluQuadricDrawStyle ( GLUquadric *quadObject, GLenum drawStyle);
void gluCylinder ( GLUquadric *qobj, GLdouble baseRadius, GLdouble topRadius, GLdouble height, GLint slices, GLint stacks);
void gluDisk ( GLUquadric *qobj, GLdouble innerRadius, GLdouble outerRadius, GLint slices, GLint loops);
void gluPartialDisk ( GLUquadric *qobj, GLdouble innerRadius, GLdouble outerRadius, GLint slices, GLint loops, GLdouble startAngle, GLdouble sweepAngle);
void gluSphere ( GLUquadric *qobj, GLdouble radius, GLint slices, GLint stacks);
void gluQuadricCallback ( GLUquadric *qobj, GLenum which, void (__stdcall* fn)());
GLUtesselator* gluNewTess( void );
void gluDeleteTess( GLUtesselator *tess );
void gluTessBeginPolygon( GLUtesselator *tess, void *polygon_data );
void gluTessBeginContour( GLUtesselator *tess );
void gluTessVertex( GLUtesselator *tess, GLdouble coords[3], void *data );
void gluTessEndContour( GLUtesselator *tess );
void gluTessEndPolygon( GLUtesselator *tess );
void gluTessProperty( GLUtesselator *tess, GLenum which, GLdouble value );
void gluTessNormal( GLUtesselator *tess, GLdouble x, GLdouble y, GLdouble z );
void gluTessCallback( GLUtesselator *tess, GLenum which, void (*fn)());
void gluGetTessProperty( GLUtesselator *tess, GLenum which, GLdouble *value );
GLUnurbs* gluNewNurbsRenderer (void);
void gluDeleteNurbsRenderer ( GLUnurbs *nobj);
void gluBeginSurface ( GLUnurbs *nobj);
void gluBeginCurve ( GLUnurbs *nobj);
void gluEndCurve ( GLUnurbs *nobj);
void gluEndSurface ( GLUnurbs *nobj);
void gluBeginTrim ( GLUnurbs *nobj);
void gluEndTrim ( GLUnurbs *nobj);
void gluPwlCurve ( GLUnurbs *nobj, GLint count, GLfloat *array, GLint stride, GLenum type);
void gluNurbsCurve ( GLUnurbs *nobj, GLint nknots, GLfloat *knot, GLint stride, GLfloat *ctlarray, GLint order, GLenum type);
void gluNurbsSurface( GLUnurbs *nobj, GLint sknot_count, float *sknot, GLint tknot_count, GLfloat *tknot, GLint s_stride, GLint t_stride, GLfloat *ctlarray, GLint sorder, GLint torder, GLenum type);
void gluLoadSamplingMatrices ( GLUnurbs *nobj, const GLfloat modelMatrix[16], const GLfloat projMatrix[16], const GLint viewport[4] );
void gluNurbsProperty ( GLUnurbs *nobj, GLenum property, GLfloat value );
void gluGetNurbsProperty ( GLUnurbs *nobj, GLenum property, GLfloat *value );
void gluNurbsCallback ( GLUnurbs *nobj, GLenum which, void (__stdcall* fn)() );
void gluBeginPolygon( GLUtesselator *tess );
void gluNextContour( GLUtesselator *tess, GLenum type );
void gluEndPolygon( GLUtesselator *tess );

const wchar_t* gluErrorUnicodeStringEXT ( GLenum errCode);
const GLubyte* gluErrorString ( GLenum errCode);
const GLubyte* gluGetString ( GLenum name);]]

ffi.cdef(header)

local library = 
{
	["OSX"] = "OpenGL.framework/GLU",
	["Windows"] = "glu32.dll",
	["Linux"] = "libGLU.so",
	["BSD"] = "libGLU.so",
	["POSIX"] = "libGLU.so",
	["Other"] = "libGLU.so",
}

local library = ffi.load(library[jit.os])

local glu = {}

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (glu%u.-) %(")
	if func_name then
		glu[func_name:sub(4)] = function(...) 
			return library[func_name](...)
		end
	end
end

function glu.GetLastError()	
	return ffi.string(glu.ErrorString(gl.GetError()))
end

return glu