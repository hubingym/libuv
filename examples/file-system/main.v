module main

import os
import libuv

struct GloablData {
mut:
    buf libuv.UvBuf
    input_file *libuv.File
}

fn on_close(file mut libuv.File) {
    if file.result < 0 {
        panic('Close error: ${file.strerror()}')
    }
}

fn on_write(file mut libuv.File) {
    if file.result < 0 {
        panic('Write error: ${file.strerror()}')
    } else {
        extra := *GloablData(file.uv.extra)
        fd := extra.input_file.result
        file.uv.fs_read(fd, extra.buf, on_read)
    }
}

fn on_read(file mut libuv.File) {
    if file.result < 0 {
        panic('Read error: ${file.strerror()}')
    } else if file.result == 0 {
        extra := *GloablData(file.uv.extra)
        fd := extra.input_file.result
        // 文件读取完成,关闭文件
        file.uv.fs_close(fd, on_close)
        // 回调可以为空函数指针
        // file.uv.fs_close(fd, 0)
    } else {
        extra := *GloablData(file.uv.extra)
        // 将缓冲区里面读取的数据写到标准输出
        fd := 1
        len := file.result
        buf := extra.buf.get_temp_buf(len)
        file.uv.fs_write(fd, buf, on_write)
    }
}

fn on_open(file mut libuv.File) {
    if file.result >= 0 {
        extra := *GloablData(file.uv.extra)
        fd := file.result
        file.uv.fs_read(fd, extra.buf, on_read)
    } else {
        panic('Open error: ${file.strerror()}')
    }
}

fn main() {
    mut extra := &GloablData{}
    mut uv := libuv.new_uv(extra)

    // 创建一个buffer用于存放读取文件的数据,该调用会分配内存
    extra.buf = uv.new_buf(1024)

    mut path := './test.txt'
    if !os.file_exists(path) {
        path = './file-system/test.txt'
    }
    mut input_file := uv.fs_open(path, C.O_RDONLY, 0, on_open)
    extra.input_file = input_file
 
    uv.run_loop()

    // 释放buffer
    extra.buf.free()
    // 清理文件操作相关请求信息
    input_file.cleanup()
}
