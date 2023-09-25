const std = @import("std");
const c_allocator = std.heap.c_allocator;

pub fn main() !void {
    var x = try c_allocator.create(i64);
    defer c_allocator.destroy(x);

    x.* = 100;

    std.debug.print("LD_PRELOAD is {}!!\n", .{x.*});
}