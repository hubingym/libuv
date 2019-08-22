# libuv for v

v语言提供了多线程和线程同步的api，通过libuv我们可以尝试在v语言中使用单线程事件驱动模型  
虽然libuv在某些地方(文件操作、任务队列)也使用了多线程，但使用者不感知，我们只需要关心主线程就行  
libuv功能很多，很强大，我们仅提供idle、timer、文件操作、网络tcp/udp、任务队列等基础功能，其它功能可以通过v语言自带api实现  
[libuv官方文档](http://docs.libuv.org/en/v1.x/guide/introduction.html)  

### 使用说明

所以示例代码都在examples目录下，如何运行示例代码：

```bash
$ cd examples/timer
$ v run .
```

* extra对象

v语言不能使用全局变量，导致事件驱动模型回调函数中不方便访问其它对象，extra对象就是一个指针，可以用来指向用户自定义数据，相当于全局变量的功能  
idle/timer/file_req等对象持有uv对象，uv对象持有extra对象  

```
// 自定义全局数据
struct GloablData {
mut:
    counter i64
}

// 强制类型转换
extra := *GloablData(file.uv.extra)
```

* uv对象

创建uv对象: libuv.new_uv(extra)  
事件循环: uv.run_loop()  

```
import libuv
extra := &GloablData{}
mut uv := libuv.new_uv(extra)
uv.run_loop()
```

* timer对象

pub fn (uv mut Uv) new_timer(cb voidptr) *Timer  
pub fn (t mut Timer) start(millisec int)  
pub fn (t mut Timer) stop()  

* idle对象

pub fn (uv mut Uv) new_idle(cb voidptr) *Idle  
pub fn (idle mut Idle) start()  
pub fn (idle mut Idle) stop()  

* buf对象

buf对象用于分配内存，主要用做文件操作时的数据缓冲区  

// 分配内存  
pub fn (uv mut Uv) new_buf(len int) UvBuf  
// 释放内存  
pub fn (buf UvBuf) free()  
// 从现有内存中截取部分内存,返回对象不需要释放内存  
pub fn (buf UvBuf) get_temp_buf(len int) UvBuf  

* FileRequset对象

pub fn (uv mut Uv) new_file_request() *FileRequset  
pub fn (req mut FileRequset) get_result() int  
pub fn (req mut FileRequset) cleanup()  
pub fn (req mut FileRequset) strerror() string  
pub fn (req mut FileRequset) err_name() string  

* 文件操作

pub fn (uv mut Uv) fs_open(req mut FileRequset, path string, flags int, mod int, cb voidptr)  
pub fn (uv mut Uv) fs_read(req mut FileRequset, fd int, buf UvBuf, cb voidptr)  
pub fn (uv mut Uv) fs_write(req mut FileRequset, fd int, buf UvBuf, cb voidptr)  
pub fn (uv mut Uv) fs_close(req mut FileRequset, fd int, cb voidptr)  

* WorkRequest对象

pub fn (uv mut Uv) new_work_request(data voidptr) *WorkRequest  
pub fn (req mut WorkRequest) cancel()  

* 任务队列

pub fn (uv mut Uv) queue_work(req mut WorkRequest, cb voidptr, after_cb voidptr)  

### How to build libuv from source

依赖官方[libuv](https://github.com/libuv/libuv)静态库，下面是官方libuv的编译方法

* 下载源码

```bash
$ git clone https://github.com/libuv/libuv
```

* winodws  

```bash
$ mkdir -p out/cmake
$ cd out/cmake
$ cmake -G "Unix Makefiles" ../..
$ cmake --build .
```

* linux or macos  

```bash
$ mkdir -p out/cmake
$ cd out/cmake
$ cmake ../..
$ cmake --build .
```

* 将include、libuv_a.a拷贝到static/  

`winodws下把libuv_a.a命名为libuv_win.a`