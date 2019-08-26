module main

import libuv
import time

fn fib_(n i64) i64 {
    if n <= 0 {
        return 0
    } else if n == 1 {
        return 1
    } else {
        return fib_(n - 1) + fib_(n - 2)
    }
}

fn fib(req mut libuv.WorkRequest) {
    time.sleep(3)
    data := *i64(req.data)
    n := *data
    res := fib_(n)
    println('ibonacci is $res')
}

fn after_fib(req mut libuv.WorkRequest, status int) {
    println('Done calculating fibonacci')
}

fn main() {
    mut uv := libuv.new_uv(0)

    data := i64(10)
    mut req1 := uv.new_work_request(&data)
    uv.queue_work(mut req1, fib, after_fib)

    uv.run_loop()
}
