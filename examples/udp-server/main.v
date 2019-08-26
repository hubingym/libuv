module main

import libuv

fn on_send(req mut libuv.UdpSendRequest, status int) {
    req.buf.free() // (send)释放buffer
    if status != 0 {
        panic('Send error ${req.uv.strerror(status)}')
    }
}

fn alloc_buffer(handle mut libuv.UdpHandle, suggested_size int, recv_buf mut libuv.UvBuf) {
    recv_buf.modify_buf(suggested_size) // (recv)申请buffer
}

fn on_recv(handle mut libuv.UdpHandle, nrecv int, recv_buf mut libuv.UvBuf, addr voidptr, flags u32) {
    defer {
        recv_buf.free() // (recv)释放buffer
    }

    if nrecv < 0 {
        panic('Receive error ${handle.uv.err_name(nrecv)}')
    }

    if nrecv == 0 { // 读取结束
        return
    }

    // 回复消息
    s := recv_buf.get_str(nrecv)
    println('Recieved $s')
    send_buf := handle.uv.new_buf_str('Server echoed: ' + s) // (send)申请buffer
    mut send_req := handle.uv.new_udp_send_request(send_buf)
    handle.udp_send(mut send_req, addr, on_send)
}

fn main() {
    mut uv := libuv.new_uv(0)

    ip := '127.0.0.1'
    addr := C.sockaddr_in{}
    C.uv_ip4_addr(ip.str, 9999, &addr)

    mut handle := uv.new_udp_handle()
    handle.udp_bind(&addr, u32(0))
    handle.udp_recv_start(alloc_buffer, on_recv)

    uv.run_loop()
}
