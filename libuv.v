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

pub fn (t mut Timer) set_timeout(millisec int) {
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
