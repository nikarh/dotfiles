local awful = require("awful")
local tyrannical = require("tyrannical")
local naughty = require("naughty")

tyrannical.settings.default_layout = awful.layout.suit.max
tyrannical.settings.block_children_focus_stealing = false
tyrannical.settings.group_children = true
tyrannical.settings.force_odd_as_intrusive = true
tyrannical.settings.favor_focused = true
tyrannical.settings.no_focus_stealing_out = true

tyrannical.tags = {
    {
        name = " \u{f120} ",
        init = true, -- Load the tag on startup
        exclusive = true, -- Refuse any other type of clients (by classes)
        screen = { 1, 2, 3 },
        class = { "xterm", "urxvt", "aterm", "URxvt", "XTerm", "Alacritty" }
    },
    {
        name = " \u{f0ac} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = { "Opera", "Firefox", "Chromium" }
    },
    {
        name = " \u{f121} ",
        init = true,
        exclusive = false,
        screen = { 1, 2, 3 },
        class = {
            "jetbrains-idea",
            "sun-awt-X11-XDialogPeer",
            "sun-awt-X11-XFramePeer",
            "sun-awt-X11-XWindowPeer",
            "insomnia", "Insomnia"
        }
    },
    {
        name = " \u{f23e} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = { "keepassxc" }
    },
    {
        name = " \u{f198} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        instance = { "messenger.com" },
        class = { "Slack", "slack" }
    },
    {
        name = " \u{f07c} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = {
            "Thunar", "pcmanfm", "Pcmanfm", "qdirstat", "QDirStat"
        }
    },
    {
        name = " \u{f03d} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = { "smplayer" }
    },
    {
        name = " \u{f025} ",
        init = true,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = {
            "deadbeef", "gmpc",
            "spotify", "Spotify", "Pavucontrol"
        }
    },
    {
        name = " \u{f293} ",
        init = false,
        exclusive = true,
        screen = { 1, 2, 3 },
        class = { "blueman-manager", "blueman-applet" }
    },
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "gtksu", "Paste Special", "Background color",
    "Xephyr", "sun-awt-X11-XWindowPeer", "gsimplecal",
    "insync.py", "jetbrains-toolbox",
    "jetbrains-idea:dialog",
    "sun-awt-X11-XWindowPeer",
    "sun-awt-X11-XDialogPeer",
    "sun-awt-X11-XFramePeer",
    "NM-connection-editor"
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "gtksu", "Select Color$", "Paste Special",
    "New Form", "Insert Picture", "insync.py",
    "About Mozilla Firefox", "jetbrains-toolbox",
    "NM-connection-editor"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr"
}

tyrannical.properties.skip_taskbar = {
    ["insync.py"] = true,
    ["jetbrains-toolbox"] = true,
    ["NM-connection-editor"] = true
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.placement = {
    kcalc = awful.placement.centered,
    ["insync.py"] = awful.placement.top_right
}

