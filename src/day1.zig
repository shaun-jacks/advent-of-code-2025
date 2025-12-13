const std = @import("std");

pub fn solve() !void {
    // Your logic for problem 1
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        // Defer deinitialization and check for leaks in debug builds.
        const leak_detected = gpa.deinit() == .leak;
        if (leak_detected) {
            std.log.err("Memory leak detected!", .{});
            // Depending on requirements, you might want to handle this more strictly.
        }
    }
    const filename = "./src/day1-input.txt";
    const file_contents = try std.fs.cwd().readFileAlloc(allocator, filename, std.math.maxInt(usize));
    defer allocator.free(file_contents);

    var lines_array = try std.ArrayList([]const u8).initCapacity(allocator, 4700);
    defer lines_array.deinit(allocator);

    var split_iterator = std.mem.splitScalar(u8, file_contents, '\n');

    while (split_iterator.next()) |line| {
        try lines_array.append(allocator, line);
    }

    var absolute_pos: i64 = 50;
    var total_zeros: i64 = 0;
    for (lines_array.items) |line| {
        if (line.len == 0) {
            continue;
        }
        const first_char = line[0];
        if (first_char != 'R' and first_char != 'L') {
            continue;
        }
        const number_part = line[1..];
        const parsed_number: i64 = std.fmt.parseInt(i64, number_part, 10) catch |err| {
            std.debug.print("Skipping invalid number format: {s} (Error: {any})\n", .{ line, err });
            continue;
        };
        var zeros_in_step: i64 = 0;
        var next_absolute_pos: i64 = 0;

        if (first_char == 'R') {
            next_absolute_pos = absolute_pos + parsed_number;

            // Formula for (Start, End]: floor(End/100) - floor(Start/100)
            const start_cycle = @divFloor(absolute_pos, 100);
            const end_cycle = @divFloor(next_absolute_pos, 100);
            zeros_in_step = end_cycle - start_cycle;
        } else {
            next_absolute_pos = absolute_pos - parsed_number;

            // Formula for [End, Start): floor((Start-1)/100) - floor((End-1)/100)
            // We shift both back by 1 to make the math exclusive of Start and inclusive of End
            const start_cycle = @divFloor(absolute_pos - 1, 100);
            const end_cycle = @divFloor(next_absolute_pos - 1, 100);
            zeros_in_step = start_cycle - end_cycle;
        }
        total_zeros += zeros_in_step;

        std.debug.print("{s}: {d} -> {d} (Hits: {d})\n", .{ line, absolute_pos, next_absolute_pos, zeros_in_step });

        absolute_pos = next_absolute_pos;
    }
    std.debug.print("Part 2 Password: {d}\n", .{total_zeros});
    std.debug.print("Total lines read: {d}\n", .{lines_array.items.len});
}
