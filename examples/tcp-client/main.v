module main

import libuv

const (
    DEFAULT_PORT = 7000
)

fn alloc_buffer(handle mut libuv.TcpHandle, suggested_size int, read_buf mut libuv.UvBuf) {
    read_buf.modify_buf(suggested_size) // (read)申请buffer
}

fn on_read(handle mut libuv.TcpHandle, nread int, read_buf mut libuv.UvBuf) {
    if nread > 0 { // 把读取的内容显示出来
        s := tos(read_buf.get_base(), nread)
        println('$s')
    } else { // 读取完毕 or 读取出错了
        if nread != C.UV_EOF {
            eprintln('Read error ${handle.uv.err_name(nread)}')
        }
        handle.tcp_close(0) // 回调函数可以为null
    }
    read_buf.free() // (read)释放buffer
}

fn on_write(req mut libuv.WriteRequest, status int) {
    req.buf.free() // 释放buffer
    if status != 0 {
        panic('Write error ${req.uv.strerror(status)}')
    } else {
        mut handle := *libuv.TcpHandle(req.get_handle())
        handle.tcp_read(alloc_buffer, on_read)
    }
}

fn on_connect(req mut libuv.ConnectRequest, status int) {
    if status < 0 {
        panic('connect failed error ${req.uv.err_name(status)}')
    } else {
        buf := req.uv.new_buf_str('client: hello') // 申请buffer
        mut write_req := req.uv.new_write_request(buf)
        mut handle := *libuv.TcpHandle(req.get_handle())
        handle.tcp_write(mut write_req, on_write)
    }
 }

fn main() {
    mut uv := libuv.new_uv(0)

    mut handle := uv.new_tcp_handle()
    mut req := uv.new_connect_request()
    handle.tcp_connect(mut req, '127.0.0.1', DEFAULT_PORT, on_connect)

    uv.run_loop()
}
