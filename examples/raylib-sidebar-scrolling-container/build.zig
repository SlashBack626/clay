const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "example",
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFile(.{
        .file = b.path("main.c"),
        .flags = &[_][]const u8{
            "-std=gnu99",
        },
    });

    // fetch the dependecy and pass relevant arguments like target and optimizations down to raylib
    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    // link our program to the raylib library
    exe.linkLibrary(raylib.artifact("raylib"));

    // use the target triplet as output directory (e.g. x86_64-windows, x86_64-linux)
    const outDir = try target.query.zigTriple(b.allocator);
    const resources = b.addInstallDirectory(.{
        .install_dir = .{ .custom = outDir },
        .install_subdir = "resources",
        .source_dir = b.path("resources"),
    });

    const output = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = outDir } },
    });

    // add our program and resources to the dependencies of this build
    const all = b.getInstallStep();
    all.dependOn(&output.step);
    all.dependOn(&resources.step);
}
