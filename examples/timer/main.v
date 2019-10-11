module main

import libuv

struct GloablData {
mut:
    timer1 &libuv.Timer
    timer2 &libuv.Timer
}

fn timer1_callback(timer1 &libuv.Timer) {
    // mut extra := &GloablData(timer1.uv.extra)
    // extra.timer2.start(5000)
    println('timer1_callback')
    // timer1.stop()
}

fn timer2_callback(timer2 mut libuv.Timer) {
    mut extra := &GloablData(timer2.uv.extra)
    println('timer2_callback')
    timer2.stop()
    extra.timer1.stop()
}

fn main() {
    mut extra := &GloablData{}
    mut uv := libuv.new_uv(extra)

    mut timer1 := uv.new_timer(timer1_callback)
    timer1.start(2000)
    extra.timer1 = timer1

    mut timer2 := uv.new_timer(timer2_callback)
    timer2.start(5000)
    extra.timer2 = timer2

    uv.run_loop()
}
