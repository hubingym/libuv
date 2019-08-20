module main

import libuv

struct GloablData {
mut:
    counter i64
}

fn wait_for_a_while(idle mut libuv.Idle) {
    mut extra := *GloablData(idle.uv.extra)
    extra.counter++
    if extra.counter > 1000000 {
        idle.stop()
    }
}

fn main() {
    extra := &GloablData{}
    mut uv := libuv.new_uv(extra)

    mut idle := uv.new_idle(wait_for_a_while)
    idle.start()

    println('Idling...')
    uv.run_loop()
}
