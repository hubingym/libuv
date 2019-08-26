module main

import libuv

const (
    DEFAULT_PORT = 7000
    DEFAULT_BACKLOG = 128
)

fn on_write(req mut libuv.WriteRequest, status int) {
    req.buf.free() // (write)释放buffer
    if status != 0 {
        panic('Write error ${req.uv.strerror(status)}')
    } else {
        mut client := *libuv.TcpHandle(req.get_handle())
        client.tcp_close(0) // 回调函数可以为null
    }
}

fn alloc_buffer(handle mut libuv.TcpHandle, suggested_size int, read_buf mut libuv.UvBuf) {
    read_buf.modify_buf(suggested_size) // (read)申请buffer
}

fn on_read(client mut libuv.TcpHandle, nread int, read_buf mut libuv.UvBuf) {
    if nread > 0 { // 把读取的内容写给客户端
        s := read_buf.get_str(nread)
        println('Recieved: $s')
        write_buf := client.uv.new_buf_str('Echo: ' + s) // (write)申请buffer
        mut write_req := client.uv.new_write_request(write_buf)
        client.tcp_write(mut write_req, on_write)
    } else { // 读取完毕 or 读取出错了
        if nread != C.UV_EOF {
            eprintln('Read error ${client.uv.err_name(nread)}')
        }
        client.tcp_close(0) // 回调函数可以为null
    }
    read_buf.free() // (read)释放buffer
}

fn on_new_connection(server mut libuv.TcpHandle, status int) {
    if status < 0 {
        panic('New connection error ${server.uv.strerror(status)}')
    }

    mut client := server.uv.new_tcp_handle()
    r := server.tcp_accept(mut client)
    if r == 0 {
        client.tcp_read_start(alloc_buffer, on_read)
    } else {
        client.tcp_close(0) // 回调函数可以为null
    }
}

fn main() {
    mut uv := libuv.new_uv(0)

    ip := '0.0.0.0'
    addr := C.sockaddr_in{}
    C.uv_ip4_addr(ip.str, DEFAULT_PORT, &addr)

    mut server := uv.new_tcp_handle()
    server.tcp_bind(&addr, u32(0))
    r := server.tcp_listen(DEFAULT_BACKLOG, on_new_connection)
    if r != 0 {
        panic('Listen error ${uv.strerror(r)}')
    }
    println('Listening...')

    uv.run_loop()
}
