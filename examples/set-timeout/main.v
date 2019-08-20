module main

import libuv

struct GloablData {
mut:
    counter i64
    timer1 *libuv.Timer
    timer2 *libuv.Timer
}

fn timer1_callback(timer mut libuv.Timer) {
    println('timer_callback')
    // timer.stop()
}

fn timer2_callback(timer mut libuv.Timer) {
    mut extra := *GloablData(timer.uv.extra)
    println('timer2_callback')
    timer.stop()
    extra.timer1.stop()
}

fn main() {
    mut extra := &GloablData{}
    mut uv := libuv.new_uv(extra)

    mut timer1 := uv.new_timer(timer1_callback)
    timer1.set_timeout(2000)
    extra.timer1 = timer1

    mut timer2 := uv.new_timer(timer2_callback)
    timer2.set_timeout(5000)
    extra.timer2 = timer2

    uv.run_loop()
}
