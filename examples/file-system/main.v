module main

import os
import libuv

struct GloablData {
mut:
    buf libuv.UvBuf
    open_req *libuv.FileRequset
    read_req *libuv.FileRequset
    write_req *libuv.FileRequset
    close_req *libuv.FileRequset
}

fn on_close(req mut libuv.FileRequset) {
    result := req.get_result()
    if result < 0 {
        panic('Close error: ${req.strerror()}')
    }
}

fn on_write(req mut libuv.FileRequset) {
    result := req.get_result()
    if result < 0 {
        panic('Write error: ${req.strerror()}')
    } else {
        mut extra := *GloablData(req.uv.extra)
        fd := extra.open_req.get_result()
        req.uv.fs_read(mut extra.read_req, fd, extra.buf, on_read)
    }
}

fn on_read(req mut libuv.FileRequset) {
    result := req.get_result()
    if result < 0 {
        panic('Read error: ${req.strerror()}')
    } else if result == 0 { // 文件读取完成,关闭文件
        mut extra := *GloablData(req.uv.extra)
        fd := extra.open_req.get_result()
        req.uv.fs_close(mut extra.close_req, fd, on_close)
        // req.uv.fs_close(mut extra.close_req, fd, 0) // 回调可以为空函数指针
    } else { // 将缓冲区里面读取的数据写到标准输出
        mut extra := *GloablData(req.uv.extra)
        fd := 1 // 标准输出
        len := result
        buf := extra.buf.get_temp_buf(len)
        req.uv.fs_write(mut extra.write_req, fd, buf, on_write)
    }
}

fn on_open(req mut libuv.FileRequset) {
    result := req.get_result()
    if result >= 0 {
        mut extra := *GloablData(req.uv.extra)
        fd := result
        req.uv.fs_read(mut extra.read_req, fd, extra.buf, on_read)
    } else {
        panic('Open error: ${req.strerror()}')
    }
}

fn main() {
    mut extra := &GloablData{}
    mut uv := libuv.new_uv(extra)

    // 创建一个buffer用于存放读取文件的数据,该调用会分配内存
    extra.buf = uv.new_buf(1024)
    // 创建文件请求对象
    extra.open_req = uv.new_file_request()
    extra.read_req = uv.new_file_request()
    extra.write_req = uv.new_file_request()
    extra.close_req = uv.new_file_request()

    mut path := './test.txt'
    if !os.file_exists(path) {
        path = './file-system/test.txt'
    }
    uv.fs_open(mut extra.open_req, path, C.O_RDONLY, 0, on_open)
 
    uv.run_loop()

    // 释放buffer
    extra.buf.free()
    // 清理文件操作相关请求信息
    extra.open_req.cleanup()
    extra.read_req.cleanup()
    extra.write_req.cleanup()
    extra.close_req.cleanup()
}
