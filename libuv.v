module libuv

#flag -I @VMOD/libuv/static/include
#include "uv.h"
#flag windows @VMOD/libuv/static/libuv_win.a
#flag linux @VMOD/libuv/static/libuv_a.a
#flag darwin @VMOD/libuv/static/libuv_a.a

import const (
    UV_RUN_DEFAULT
)

struct C.uv_loop_t {
}

struct C.uv_timer_t {
}

struct C.uv_idle_t {
}

struct C.uv_buf_t {
    base byteptr
    len int
}

struct C.uv_fs_t {
    result int
}

struct C.uv_work_t {
}

struct C.uv_req_t {
}

// loop
fn C.uv_default_loop() *C.uv_loop_t
fn C.uv_run(*C.uv_loop_t, int) int
fn C.uv_stop(*C.uv_loop_t)

// timer
fn C.uv_timer_init(*C.uv_loop_t, *C.uv_timer_t) int
fn C.uv_timer_start(*C.uv_timer_t, voidptr, int, int) int
fn C.uv_timer_stop(*C.uv_timer_t) int

// idle
fn C.uv_idle_init(*C.uv_loop_t, *C.uv_idle_t) int
fn C.uv_idle_start(*C.uv_idle_t, voidptr) int
fn C.uv_idle_stop(*C.uv_idle_t) int

// uv buffer
fn C.uv_buf_init(base byteptr, len int) C.uv_buf_t

// err
fn C.uv_strerror(err int) byteptr
fn C.uv_err_name(err int) byteptr

// filesystem
fn C.uv_fs_req_cleanup(*C.uv_fs_t)
fn C.uv_fs_open(loop *C.uv_loop_t, req *C.uv_fs_t, filename byteptr, flags int, mode int, cb voidptr) int
fn C.uv_fs_close(loop *C.uv_loop_t, req *C.uv_fs_t, fd int, cb voidptr) int
fn C.uv_fs_read(loop *C.uv_loop_t, req *C.uv_fs_t, fd int, bufs *C.uv_buf_t, nbufs int, offset int, cb voidptr) int
fn C.uv_fs_write(loop *C.uv_loop_t, req *C.uv_fs_t, fd int, bufs *C.uv_buf_t, nbufs int, offset int, cb voidptr) int

// queue work
fn C.uv_queue_work(loop *C.uv_loop_t, req *C.uv_work_t, cb voidptr, after_cb voidptr) int

// request
fn C.uv_cancel(req *C.uv_req_t) int

fn todo_remove(){}

struct Uv {
    magic string
    loop *C.uv_loop_t
pub:
    extra voidptr // v没有全局变量,此处额外数据功能等同全局变量
}

pub fn new_uv(extra voidptr) *Uv {
    mut uv := &Uv{
        magic: 'libuv'
        loop: C.uv_default_loop()
        extra: extra
    }
    return uv
}

pub fn (uv mut Uv) run_loop() {
    C.uv_run(uv.loop, UV_RUN_DEFAULT)
}

pub fn (uv mut Uv) stop() {
    C.uv_stop(uv.loop)
}

struct Timer {
    _timer C.uv_timer_t
    cb voidptr
pub:
    uv *Uv
}

pub fn (uv mut Uv) new_timer(cb voidptr) *Timer {
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
    _idle C.uv_idle_t
    cb voidptr
pub:
    uv *Uv
}

pub fn (uv mut Uv) new_idle(cb voidptr) *Idle {
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
    _buf C.uv_buf_t // uv_buf_t仅有base和len两个字段
}

// 返回一个自定义缓冲区,需要调用free释放内存
pub fn (uv mut Uv) new_buf(len int) UvBuf {
    mut buf := UvBuf{
    }
    p := calloc(len)
    buf._buf = C.uv_buf_init(p, len)
    return buf
}

// 返回一个临时缓冲区,不需要释放内存
pub fn (buf UvBuf) get_temp_buf(len int) UvBuf {
    return UvBuf{
        _buf: C.uv_buf_init(buf._buf.base, len)
    }
}

pub fn (buf UvBuf) free() {
    free(buf._buf.base)
}

struct FileRequset {
    _req C.uv_fs_t
pub:
    uv *Uv
}

pub fn (uv mut Uv) new_file_request() *FileRequset {
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

pub fn (req mut FileRequset) strerror() string {
    err := req.get_result()
    s := C.uv_strerror(err)
    return tos_clone(s)
}

pub fn (req mut FileRequset) err_name() string {
    err := req.get_result()
    s := C.uv_err_name(err)
    return tos_clone(s)
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
    _req C.uv_work_t
pub:
    uv *Uv
    data voidptr // 存放用户数据
}

pub fn (uv mut Uv) new_work_request(data voidptr) *WorkRequest {
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
