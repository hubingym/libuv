# vlibuv
[libuv](https://github.com/libuv/libuv) for v  

### How to build libuv from source

* 下载源码

```bash
git clone https://github.com/libuv/libuv
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

* 将include、libuv_a.a拷贝到vlibuv/libuv  

`winodws下把libuv_a.a命名为libuv_win.a`