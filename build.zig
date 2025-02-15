const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Modules
    const tcp_server = b.addModule("tcp_server", .{
        .root_source_file = b.path("src/tcp_server/main.zig"),
        .optimize = optimize,
        .target = target,
    });

    const network = b.addModule("network", .{
        .root_source_file = b.path("src/network/main.zig"),
        .optimize = optimize,
        .target = target,
    });

    const packets = b.addModule("packets", .{
        .root_source_file = b.path("src/packets/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    packets.addImport("network", network);

    // Exe
    const exe = b.addExecutable(.{
        .name = "server",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("network", network);
    exe.root_module.addImport("packets", packets);
    exe.root_module.addImport("tcp_server", tcp_server);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests
    {
        const network_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/network/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_network_unit_tests = b.addRunArtifact(network_unit_tests);

        const packets_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/packets/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        packets_unit_tests.root_module.addImport("network", network);
        const run_packets_unit_tests = b.addRunArtifact(packets_unit_tests);

        const exe_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

        // Test suite
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_network_unit_tests.step);
        test_step.dependOn(&run_packets_unit_tests.step);
        test_step.dependOn(&run_exe_unit_tests.step);
    }
}
