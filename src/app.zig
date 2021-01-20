const c = @cImport({
    @cInclude("cfl.h");
    @cInclude("cfl_image.h");
});
const widget = @import("widget.zig");

const Scheme = enum {
    Base,
    Gtk,
    Plastic,
    Gleam,
};

// fltk initizialization of optional functionalities
pub fn init() !void {
    c.Fl_init_all(); // inits all styles, if needed
    c.Fl_register_images(); // register image types supported by fltk, if needed
    const ret = c.Fl_lock(); // enable multithreading, if needed
    if (ret != 0)
        unreachable;
}

pub fn run() !void {
    const ret = c.Fl_run();
    if (ret != 0)
        unreachable;
}

pub fn setScheme(scheme: Scheme) void {
    var temp = switch (scheme) {
        .Base => "base",
        .Gtk => "gtk+",
        .Plastic => "plastic",
        .Gleam => "gleam",
    };
    c.Fl_set_scheme(temp);
}

pub fn event() enums.Event {
    return @intToEnum(enums.Event, c.Fl_event());
}

pub const WidgetTracker = struct {
    inner: ?*c.Fl_Widget_Tracker,
    pub fn new(w: widget.Widget) WidgetTracker {
        const ptr = c.Fl_Widget_Tracker_new(@ptrCast(*c.Fl_Widget, w.inner));
        if (ptr == null) unreachable;
        return WidgetTracker{
            .inner = ptr,
        };
    }
    pub fn deleted() bool {
        return c.Fl_Widget_Tracker_deleted() != 0;
    }
    pub fn delete(self: WidgetTracker) void {
        c.Fl_Widget_Tracker_delete(self.inner);
    }
};
