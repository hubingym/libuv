module libuv

#flag -I @VMOD/libuv/static/include
#include "uv.h"
#flag windows @VMOD/libuv/static/libuv_win.a
#flag linux @VMOD/libuv/static/libuv_a.a
#flag darwin @VMOD/libuv/static/libuv_a.a

[typedef]
struct C.uv_buf_t {
mut:
    base byteptr
    len int
}
struct C.sockaddr_in {
}
struct C.sockaddr_in6 {
}
struct C.sockaddr {
}

/* Handle types. */
[typedef]
struct C.uv_loop_t {
}
[typedef]
struct C.uv_handle_t {
}
[typedef]
struct C.uv_stream_t {
}
[typedef]
struct C.uv_tcp_t {
}
[typedef]
struct C.uv_udp_t {
}
[typedef]
struct C.uv_pipe_t {
}
[typedef]
struct C.uv_tty_t {
}
[typedef]
struct C.uv_timer_t {
}
[typedef]
struct C.uv_idle_t {
}
[typedef]
struct C.uv_signal_t {
}

/* Request types. */
[typedef]
struct C.uv_req_t {
}
[typedef]
struct C.uv_write_t {
    handle byteptr
}
[typedef]
struct C.uv_connect_t {
    handle byteptr
}
[typedef]
struct C.uv_udp_send_t {
}
[typedef]
struct C.uv_fs_t {
    result int
}
[typedef]
struct C.uv_work_t {
}

// loop
fn C.uv_default_loop() *uv_loop_t
fn C.uv_run(*uv_loop_t, int) int
fn C.uv_stop(*uv_loop_t)

// timer
fn C.uv_timer_init(*uv_loop_t, *uv_timer_t) int
fn C.uv_timer_start(*uv_timer_t, voidptr, int, int) int
fn C.uv_timer_stop(*uv_timer_t) int

// idle
fn C.uv_idle_init(*uv_loop_t, *uv_idle_t) int
fn C.uv_idle_start(*uv_idle_t, voidptr) int
fn C.uv_idle_stop(*uv_idle_t) int

// uv buffer
fn C.uv_buf_init(base byteptr, len int) uv_buf_t

// err
fn C.uv_strerror(err int) byteptr
fn C.uv_err_name(err int) byteptr

// filesystem
fn C.uv_fs_req_cleanup(*uv_fs_t)
fn C.uv_fs_open(loop *uv_loop_t, req *uv_fs_t, filename byteptr, flags int, mode int, cb voidptr) int
fn C.uv_fs_close(loop *uv_loop_t, req *uv_fs_t, fd int, cb voidptr) int
fn C.uv_fs_read(loop *uv_loop_t, req *uv_fs_t, fd int, bufs *uv_buf_t, nbufs int, offset int, cb voidptr) int
fn C.uv_fs_write(loop *uv_loop_t, req *uv_fs_t, fd int, bufs *uv_buf_t, nbufs int, offset int, cb voidptr) int

// queue work
fn C.uv_queue_work(loop *uv_loop_t, req *uv_work_t, cb voidptr, after_cb voidptr) int

// request
fn C.uv_cancel(req *uv_req_t) int

// networking
fn C.uv_ip4_addr(ip byteptr, port int, addr *sockaddr_in) int
fn C.uv_ip6_addr(ip byteptr, port int, addr *sockaddr_in6) int

fn C.uv_close(handle *uv_handle_t, cb voidptr)
fn C.uv_tcp_init(loop *uv_loop_t, handle *uv_tcp_t) int
fn C.uv_tcp_bind(handle *uv_tcp_t, addr *sockaddr, flags u32) int
fn C.uv_listen(server *uv_stream_t, backlog int, cb voidptr) int
fn C.uv_accept(server *uv_stream_t, client *uv_stream_t) int
fn C.uv_read_start(handle *uv_stream_t, alloc_cb voidptr, read_cb voidptr) int
fn C.uv_read_stop(handle *uv_stream_t) int
fn C.uv_write(req *uv_write_t, handle *uv_stream_t, bufs *uv_buf_t, nbufs int, cb voidptr) int
fn C.uv_tcp_connect(req *uv_connect_t, handle *uv_stream_t, addr *sockaddr, cb voidptr) int

fn todo_remove(){}

struct Uv {
    loop &uv_loop_t
pub:
    extra voidptr // v没有全局变量,此处额外数据功能等同全局变量
}

pub fn new_uv(extra voidptr) &Uv {
    mut uv := &Uv{
        loop: C.uv_default_loop()
        extra: extra
    }
    return uv
}

pub fn (uv mut Uv) run_loop() {
    C.uv_run(uv.loop, C.UV_RUN_DEFAULT)
}

pub fn (uv mut Uv) stop() {
    C.uv_stop(uv.loop)
}

pub fn (uv mut Uv) strerror(err int) string {
    s := C.uv_strerror(err)
    return tos_clone(s)
}

pub fn (uv mut Uv) err_name(err int) string {
    s := C.uv_err_name(err)
    return tos_clone(s)
}

struct Timer {
    _timer uv_timer_t
    cb voidptr
pub:
    uv &Uv
}

pub fn (uv mut Uv) new_timer(cb voidptr) &Timer {
    mut t := &Timer{
        cb: cb
        uv: uv
    }
    C.uv_timer_init(uv.loop, &t._timer)
    return t
}

pub fn (t mut Timer) start(millisec int) {
    C.uv_timer_start(&t._timer, t.cb, millisec, millisec)
}

pub fn (t mut Timer) stop() {
    C.uv_timer_stop(&t._timer)
}

struct Idle {
    _idle uv_idle_t
    cb voidptr
pub:
    uv &Uv
}

pub fn (uv mut Uv) new_idle(cb voidptr) &Idle {
    mut idle := &Idle{
        uv: uv
        cb: cb
    }
    C.uv_idle_init(uv.loop, &idle._idle)
    return idle
}

pub fn (idle mut Idle) start() {
    C.uv_idle_start(&idle._idle, idle.cb)
}

pub fn (idle mut Idle) stop() {
    C.uv_idle_stop(&idle._idle)
}

struct UvBuf {
mut:
    _buf uv_buf_t // uv_buf_t仅有base和len两个字段
}

pub fn (uv mut Uv) new_buf_str(s string) UvBuf {
    buf := uv.new_buf(s.len)
    C.memcpy(buf._buf.base, s.str, s.len)
    return buf
}

// 返回一个自定义缓冲区,需要调用free释放内存
pub fn (uv mut Uv) new_buf(len int) UvBuf {
    p := calloc(len)
    buf := UvBuf{
        _buf: C.uv_buf_init(p, len)
    }
    return buf
}

pub fn (buf mut UvBuf) modify_buf(len int) {
    buf._buf.base = calloc(len)
    buf._buf.len = len
}

// 返回一个临时缓冲区,不需要释放内存
pub fn (buf UvBuf) get_temp_buf(len int) UvBuf {
    return UvBuf{
        _buf: C.uv_buf_init(buf._buf.base, len)
    }
}

pub fn (buf UvBuf) get_base() byteptr {
    return buf._buf.base
}

pub fn (buf UvBuf) free() {
    free(buf._buf.base)
}

struct FileRequset {
    _req uv_fs_t
pub:
    uv &Uv
}

pub fn (uv mut Uv) new_file_request() &FileRequset {
    mut req := &FileRequset{
        uv: uv
    }
    return req
}

pub fn (req mut FileRequset) get_result() int {
    return req._req.result
}

pub fn (req mut FileRequset) cleanup() {
    // The uv_fs_req_cleanup() function must always be called on filesystem requests to free internal memory allocations in libuv
    C.uv_fs_req_cleanup(&req._req)
}

pub fn (uv mut Uv) fs_open(req mut FileRequset, path string, flags int, mod int, cb voidptr) {
    C.uv_fs_open(uv.loop, &req._req, path.str, flags, mod, cb)
}

pub fn (uv mut Uv) fs_read(req mut FileRequset, fd int, buf UvBuf, cb voidptr) {
    C.uv_fs_read(uv.loop, &req._req, fd, &buf._buf, 1, -1, cb)
}

pub fn (uv mut Uv) fs_write(req mut FileRequset, fd int, buf UvBuf, cb voidptr) {
    C.uv_fs_write(uv.loop, &req._req, fd, &buf._buf, 1, -1, cb)
}

pub fn (uv mut Uv) fs_close(req mut FileRequset, fd int, cb voidptr) {
    C.uv_fs_close(uv.loop, &req._req, fd, cb)
}

struct WorkRequest {
    _req uv_work_t
pub:
    uv &Uv
    data voidptr // 存放用户数据
}

pub fn (uv mut Uv) new_work_request(data voidptr) &WorkRequest {
    mut req := &WorkRequest{
        uv: uv
        data: data
    }
    return req
}

pub fn (req mut WorkRequest) cancel() {
    C.uv_cancel(&req._req)
}

pub fn (uv mut Uv) queue_work(req mut WorkRequest, cb voidptr, after_cb voidptr) {
    C.uv_queue_work(uv.loop, &req._req, cb, after_cb)
}

// struct SockaddrIn {
//     _addr sockaddr_in
// }

// pub fn (uv mut Uv) get_sockaddr_in(ip string, port int) SockaddrIn {
//     addr := SockaddrIn{}
//     C.uv_ip4_addr(ip.str, port, &addr._addr)
//     return addr
// }

struct ConnectRequest {
    _req uv_connect_t
pub:
    uv &Uv
}

pub fn (uv mut Uv) new_connect_request() &ConnectRequest {
    mut req := &ConnectRequest{
        uv: uv
    }
    return req
}

pub fn (req mut ConnectRequest) get_handle() byteptr {
    return req._req.handle
}

struct WriteRequest {
    _req uv_write_t
pub:
    uv &Uv
    buf UvBuf
}

pub fn (uv mut Uv) new_write_request(buf UvBuf) &WriteRequest {
    mut req := &WriteRequest{
        uv: uv
        buf: buf
    }
    return req
}

pub fn (req mut WriteRequest) get_handle() byteptr {
    return req._req.handle
}

struct TcpHandle {
    _handle uv_tcp_t
pub:
    uv &Uv
}

pub fn (uv mut Uv) new_tcp_handle() &TcpHandle {
    mut handle := &TcpHandle{
        uv: uv
    }
    C.uv_tcp_init(uv.loop, &handle._handle)
    return handle
}

pub fn (handle mut TcpHandle) tcp_bind(ip string, port int, flags u32) {
    // TODO: 目前sockaddr_in无法正常编译,暂时使用ip+port
    addr := C.sockaddr_in{}
    C.uv_ip4_addr(ip.str, port, &addr)
    C.uv_tcp_bind(&handle._handle, &addr, flags)
}

pub fn (handle mut TcpHandle) tcp_listen(backlog int, cb voidptr) int {
    return C.uv_listen(&handle._handle, backlog, cb)
}

pub fn (handle mut TcpHandle) tcp_accept(client mut TcpHandle) int {
    return C.uv_accept(&handle._handle, &client._handle)
}

pub fn (handle mut TcpHandle) tcp_close(cb voidptr) {
    C.uv_close(&handle._handle, cb)
}

pub fn (handle mut TcpHandle) tcp_read(alloc_buffer voidptr, cb voidptr) {
    C.uv_read_start(&handle._handle, alloc_buffer, cb)
}

pub fn (handle mut TcpHandle) tcp_write(req mut WriteRequest, cb voidptr) {
    C.uv_write(&req._req, &handle._handle, &req.buf._buf, 1, cb)
}

pub fn (handle mut TcpHandle) tcp_connect(req mut ConnectRequest, ip string, port int, cb voidptr) {
    // TODO: 目前sockaddr_in无法正常编译,暂时使用ip+port
    addr := C.sockaddr_in{}
    C.uv_ip4_addr(ip.str, port, &addr)
    C.uv_tcp_connect(&req._req, &handle._handle, &addr, cb)
}
