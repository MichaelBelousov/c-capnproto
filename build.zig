const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const capnp_mod = b.addModule("capnp", .{
        .target = target,
        .link_libc = true, // FIXME: try to remove?
    });

    capnp_mod.addCSourceFiles(.{
        .files = &.{
            "./lib/capn.c",
            "./lib/capn-malloc.c", // TODO: can I use a zig allocator?
            "./lib/capn-stream.c",
        },
        .language = .c,
    });
    capnp_mod.addIncludePath(b.path("./lib"));
    capnp_mod.addIncludePath(b.path("./compiler"));

    const capnpc_mod = b.addModule("capnpc", .{
        .target = target,
        .link_libc = true, // FIXME: try to remove?
    });

    capnpc_mod.addCSourceFiles(.{
        .files = &.{
            "compiler/capnpc-c.c",
            "compiler/schema.capnp.c",
            "compiler/str.c"
        },
        .language = .c,
    });
    capnpc_mod.addIncludePath(b.path("./lib/"));

    const libcapnpc = b.addLibrary(.{
        .linkage = .static,
        .name = "capnp",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "capnpc", .module = capnpc_mod },
            },
        }),
    });

    const test_src = &.{
        "tests/capn-test.cpp",
        "tests/capn-stream-test.cpp",
        "tests/example-test.cpp",
        "tests/addressbook.capnp.c",
        "compiler/test.capnp.c",
        "compiler/schema-test.cpp",
        "compiler/schema.capnp.c"
    };
    _ = test_src;

    b.installArtifact(libcapnpc);
}
