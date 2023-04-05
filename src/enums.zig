const std = @import("std");

const c = @cImport({
    @cInclude("cfl.h");
});

// TODO: rename enums to snake_case to match Zig style guide
// <https://github.com/ziglang/zig/issues/2101>

// DO NOT add more elements to this stuct.
// Using 4 `u8`s in a packed struct makes an identical memory layout to a u32
// (the color format FLTK uses) so this trick can be used to make Colors both
// efficient and easy to use
pub const Color = packed struct {
    // Arranged like so because a vast majority of systems are little-endian
    i: u8 = 0,
    b: u8 = 0,
    g: u8 = 0,
    r: u8 = 0,

    pub const Names = enum(u8) {
        foreground = 0,
        background2 = 7,
        inactive = 8,
        selection = 15,
        gray0 = 32,
        dark3 = 39,
        dark2 = 45,
        dark1 = 47,
        background = 49,
        light1 = 50,
        light2 = 52,
        light3 = 54,
        black = 56,
        red = 88,
        green = 63,
        yellow = 95,
        blue = 216,
        magenta = 248,
        cyan = 223,
        dark_red = 72,
        dark_green = 60,
        dark_yellow = 76,
        dark_blue = 136,
        dark_magenta = 152,
        dark_cyan = 140,
        white = 255,
    };

    pub fn fromName(name: Names) Color {
        return Color.fromIndex(@enumToInt(name));
    }

    pub fn fromIndex(idx: u8) Color {
        var col = Color{
            .r = undefined,
            .g = undefined,
            .b = undefined,
            .i = idx,
        };

        c.Fl_get_color_rgb(idx, &col.r, &col.g, &col.b);

        return col;
    }

    pub fn fromRgb(r: u8, g: u8, b: u8) Color {
        // This is a special exception as FLTK's `0` index is the
        // foreground for some reason. Eg: if you override the foreground
        // color then try to set another color to black, it would set it to
        // the new foreground color
        if (r | g | b == 0) {
            return Color.fromName(.black);
        }

        return Color{
            .r = r,
            .g = g,
            .b = b,
            .i = 0,
        };
    }

    pub fn toRgbi(col: Color) u32 {
        // Drop the RGB bytes if color is indexed
        // This is because colors where both the index byte and color u24 are
        // non-0 are reserved
        if (col.i != 0) {
            return col.i;
        }

        return std.mem.littleToNative(u32, @bitCast(u32, col));
    }

    pub fn fromRgbi(val: u32) Color {
        var col = @bitCast(Color, std.mem.nativeToLittle(u32, val));

        // If the color is indexed, set find out what the R, G and B values
        // are and set the struct's fields
        if (col.i != 0) {
            c.Fl_get_color_rgb(col.i, &col.r, &col.g, &col.b);
        }

        return col;
    }

    pub fn toHex(col: Color) u24 {
        return @truncate(u24, @bitCast(u32, col) >> 8);
    }

    pub fn fromHex(val: u24) Color {
        if (val == 0) {
            return Color.fromName(.black);
        }

        return @bitCast(Color, std.mem.nativeToLittle(u32, @intCast(u32, val) << 8));
    }

    // Seems really redundant and the FLTK docs don't even appear to document
    // how much a color gets darkened/lightened
    //    pub fn darker(col: Color) Color {
    //        return Color.fromRgbi(c.Fl_darker(col.toRgbi()));
    //    }

    pub fn darken(col: Color, val: u8) Color {
        var new_col = col;

        new_col.r -|= val;
        new_col.g -|= val;
        new_col.b -|= val;

        return new_col;
    }

    pub fn lighten(col: Color, val: u8) Color {
        var new_col = col;

        new_col.r +|= val;
        new_col.g +|= val;
        new_col.b +|= val;

        return new_col;
    }
};

pub const Align = struct {
    pub const Center = 0;
    pub const Top = 1;
    pub const Bottom = 2;
    pub const Left = 4;
    pub const Right = 8;
    pub const Inside = 16;
    pub const TextOverImage = 20;
    pub const Clip = 40;
    pub const Wrap = 80;
    pub const ImageNextToText = 100;
    pub const TextNextToImage = 120;
    pub const ImageBackdrop = 200;
    pub const TopLeft = 1 | 4;
    pub const TopRight = 1 | 8;
    pub const BottomLeft = 2 | 4;
    pub const BottomRight = 2 | 8;
    pub const LeftTop = 7;
    pub const RightTop = 11;
    pub const LeftBottom = 13;
    pub const RightBottom = 14;
    pub const PositionMask = 15;
    pub const ImageMask = 320;
};

pub const LabelType = enum(i32) {
    Normal = 0,
    None,
    Shadow,
    Engraved,
    Embossed,
    Multi,
    Icon,
    Image,
    FreeType,
};

pub const BoxType = enum(i32) {
    NoBox = 0,
    FlatBox,
    UpBox,
    DownBox,
    UpFrame,
    DownFrame,
    ThinUpBox,
    ThinDownBox,
    ThinUpFrame,
    ThinDownFrame,
    EngraveBox,
    EmbossedBox,
    EngravedFrame,
    EmbossedFrame,
    BorderBox,
    ShadowBox,
    BorderFrame,
    ShadowFrame,
    RoundedBox,
    RShadowBox,
    RoundedFrame,
    RFlatBox,
    RoundUpBox,
    RoundDownBox,
    DiamondUpBox,
    DiamondDownBox,
    OvalBox,
    OShadowBox,
    OvalFrame,
    OFlatFrame,
    PlasticUpBox,
    PlasticDownBox,
    PlasticUpFrame,
    PlasticDownFrame,
    PlasticThinUpBox,
    PlasticThinDownBox,
    PlasticRoundUpBox,
    PlasticRoundDownBox,
    GtkUpBox,
    GtkDownBox,
    GtkUpFrame,
    GtkDownFrame,
    GtkThinUpBox,
    GtkThinDownBox,
    GtkThinUpFrame,
    GtkThinDownFrame,
    GtkRoundUpFrame,
    GtkRoundDownFrame,
    GleamUpBox,
    GleamDownBox,
    GleamUpFrame,
    GleamDownFrame,
    GleamThinUpBox,
    GleamThinDownBox,
    GleamRoundUpBox,
    GleamRoundDownBox,
    FreeBoxType,
};

pub const BrowserScrollbar = enum(i32) {
    BrowserScrollbarNone = 0,
    BrowserScrollbarHorizontal = 1,
    BrowserScrollbarVertical = 2,
    BrowserScrollbarBoth = 3,
    BrowserScrollbarAlwaysOn = 4,
    BrowserScrollbarHorizontalAlways = 5,
    BrowserScrollbarVerticalAlways = 6,
    BrowserScrollbarBothAlways = 7,
};

pub const Event = enum(i32) {
    NoEvent = 0,
    Push,
    Released,
    Enter,
    Leave,
    Drag,
    Focus,
    Unfocus,
    KeyDown,
    KeyUp,
    Close,
    Move,
    Shortcut,
    Deactivate,
    Activate,
    Hide,
    Show,
    Paste,
    SelectionClear,
    MouseWheel,
    DndEnter,
    DndDrag,
    DndLeave,
    DndRelease,
    ScreenConfigChanged,
    Fullscreen,
    ZoomGesture,
    ZoomEvent,
    FILLER, // FLTK sends `28` as an event occasionally and this doesn't appear
    // to be documented anywhere. This is only included to keep
    // programs from crashing from a non-existent enum
};

pub const Font = enum(i32) {
    Helvetica = 0,
    HelveticaBold = 1,
    HelveticaItalic = 2,
    HelveticaBoldItalic = 3,
    Courier = 4,
    CourierBold = 5,
    CourierItalic = 6,
    CourierBoldItalic = 7,
    Times = 8,
    TimesBold = 9,
    TimesItalic = 10,
    TimesBoldItalic = 11,
    Symbol = 12,
    Screen = 13,
    ScreenBold = 14,
    Zapfdingbats = 15,
};

pub const Key = struct {
    pub const None = 0;
    pub const Button = 0xfee8;
    pub const BackSpace = 0xff08;
    pub const Tab = 0xff09;
    pub const IsoKey = 0xff0c;
    pub const Enter = 0xff0d;
    pub const Pause = 0xff13;
    pub const ScrollLock = 0xff14;
    pub const Escape = 0xff1b;
    pub const Kana = 0xff2e;
    pub const Eisu = 0xff2f;
    pub const Yen = 0xff30;
    pub const JISUnderscore = 0xff31;
    pub const Home = 0xff50;
    pub const Left = 0xff51;
    pub const Up = 0xff52;
    pub const Right = 0xff53;
    pub const Down = 0xff54;
    pub const PageUp = 0xff55;
    pub const PageDown = 0xff56;
    pub const End = 0xff57;
    pub const Print = 0xff61;
    pub const Insert = 0xff63;
    pub const Menu = 0xff67;
    pub const Help = 0xff68;
    pub const NumLock = 0xff7f;
    pub const KP = 0xff80;
    pub const KPEnter = 0xff8d;
    pub const KPLast = 0xffbd;
    pub const FLast = 0xffe0;
    pub const ShiftL = 0xffe1;
    pub const ShiftR = 0xffe2;
    pub const ControlL = 0xffe3;
    pub const ControlR = 0xffe4;
    pub const CapsLock = 0xffe5;
    pub const MetaL = 0xffe7;
    pub const MetaR = 0xffe8;
    pub const AltL = 0xffe9;
    pub const AltR = 0xffea;
    pub const Delete = 0xffff;

    // TODO: add `fromName` and related methods
};

pub const Shortcut = struct {
    pub const None = 0;
    pub const Shift = 0x00010000;
    pub const CapsLock = 0x00020000;
    pub const Ctrl = 0x00040000;
    pub const Alt = 0x00080000;
};

pub const CallbackTrigger = struct {
    pub const Never = 0;
    pub const Changed = 1;
    pub const NotChanged = 2;
    pub const Release = 4;
    pub const ReleaseAlways = 6;
    pub const EnterKey = 8;
    pub const EnterKeyAlways = 10;
    pub const EnterKeyChanged = 11;
};

pub const Cursor = enum(i32) {
    Default = 0,
    Arrow = 35,
    Cross = 66,
    Wait = 76,
    Insert = 77,
    Hand = 31,
    Help = 47,
    Move = 27,
    NS = 78,
    WE = 79,
    NWSE = 80,
    NESW = 81,
    N = 70,
    NE = 69,
    E = 49,
    SE = 8,
    S = 9,
    SW = 7,
    W = 36,
    NW = 68,
    None = 255,
};

pub const TextCursor = enum(u8) {
    Normal,
    Caret,
    Dim,
    Block,
    Heavy,
    Simple,
};

test "all" {
    @import("std").testing.refAllDecls(@This());
}
