const std = @import("std");
const Window = @import("window.zig");
const lag = @import("lag.zig");
const Vec3 = lag.Vec3(f32);
const Vec2 = lag.Vec2(f32);
const Mat4 = lag.Mat4;

const Camera = @This();
win: *Window,
target: Vec3,
tolerance: Vec2,
width: f32,
height: f32,

pub fn init(win: *Window, target: Vec3, tolerance: Vec2, width: u32, height: u32) Camera {
    return Camera{
        .win = win,
        .target = target,
        .tolerance = tolerance,
        .width = @intToFloat(f32, width),
        .height = @intToFloat(f32, height),
    };
}

// TODO (etate): There's definitely a more elegant way to compute these
// new target positions
pub fn setTarget(self: *Camera, target: Vec3) void {
    var diff = self.target.sub(target);
    var intolerant_diff = Vec2.init(@fabs(diff.x), @fabs(diff.y));

    intolerant_diff = intolerant_diff.sub(self.tolerance);
    if (intolerant_diff.x > 0) {
        if (self.target.x > target.x) {
            self.target.x -= intolerant_diff.x;
        } else {
            self.target.x += intolerant_diff.x;
        }
    }

    if (intolerant_diff.y > 0) {
        if (self.target.y > target.y) {
            self.target.y -= intolerant_diff.y;
        } else {
            self.target.y += intolerant_diff.y;
        }
    }
}

pub fn projection(self: Camera) Mat4 {
    const viewport_width = @intToFloat(f32, self.win.width);
    const viewport_height = @intToFloat(f32, self.win.height);
    const half_width = self.width / 2;
    const half_height = self.height / 2;

    std.debug.print("width: {d}, height: {d}, viewport_w: {d}, viewport_h: {d}\n", .{ self.width, self.height, viewport_width, viewport_height });
    const top = -(((self.target.y - half_height) / viewport_height) * 2 - 1);
    const bottom = -(((self.target.y + half_height) / viewport_height) * 2 - 1);
    const left = ((self.target.x - half_width) / viewport_width) * 2 - 1;
    const right = ((self.target.x + half_width) / viewport_width) * 2 - 1;

    return Mat4.orthographic(top, left, bottom, right);
}
