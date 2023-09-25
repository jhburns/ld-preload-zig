# LD_PRELOAD Trick With Zig

This tutorial covers how to use the `LD_PRELOAD` trick using with Zig on Linux. `mimalloc` is used as an example, but any C allocator is possible to use with this trick.

## Prerequisites

1. [Zig v0.12.0](https://ziglang.org/learn/getting-started/)
1. [mimalloc](https://github.com/microsoft/mimalloc)

    If mimalloc was successfully installed you can check like so:

    ```shell
    $ ls /usr/local/lib/libmimalloc.so
    /usr/local/lib/libmimalloc.so
    ```

## Tutorial

1. Make and initialize a Zig project.

    ```shell
    $ mkdir ld-preload-zig
    $ cd ld-preload-zig/
    $ zig init-exe
    info: Created build.zig
    info: Created src/main.zig
    info: Next, try `zig build --help` or `zig build run`
    ```

1. Replace the contents of `src/main.zig`. The C allocator is required for the `LD_PRELOAD` trick.

    ```zig
    const std = @import("std");
    const c_allocator = std.heap.c_allocator;

    pub fn main() !void {
        var x = try c_allocator.create(i64);
        defer c_allocator.destroy(x);

        x.* = 100;

        std.debug.print("LD_PRELOAD is {}!!\n", .{x.*});
    }
    ```

1. Add a line to `build.zig` which will enable `libc`.

    ```zig
    (snip)
    const exe = b.addExecutable(.{
        .name = "ld-preload-zig",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Lets us use the C Allocator during build
    exe.linkLibC();
    (snip)
    ```

1. Build the project.

    ```shell
    $ zig build
    ```

1. Navigate to the executable and test that the trick works.

    ```shell
    $ cd zig-out/bin
    $ MIMALLOC_VERBOSE=1 LD_PRELOAD=/usr/local/lib/libmimalloc.so ./ld-preload-zig
    mimalloc: option 'show_errors': 0
    mimalloc: option 'show_stats': 0
    mimalloc: option 'verbose': 1
    (snip)
    ```

    If the trick is working, there should be verbose output from `mimalloc` like above.

1. Here is the final result without the verbose output, neat!:

    ```shell
    $ LD_PRELOAD=/usr/local/lib/libmimalloc.so ./ld-preload-zig
    LD_PRELOAD is 100!!
    ```
