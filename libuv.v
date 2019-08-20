module libuv

#flag -I @VMOD/libuv/static/include
#include "uv.h"
#flag windows @VMOD/libuv/static/libuv_win.a
#flag linux @VMOD/libuv/static/libuv_a.a
#flag darwin @VMOD/libuv/static/libuv_a.a
