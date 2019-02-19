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
        layout = awful.layout.suit.max,
        name = " \u{f120} ",
        init = true, -- Load the tag on startup
        exclusive = false, -- Refuse any other type of clients (by classes)
        screen = { 1, 2, 3 },
        class = { "xterm", "urxvt", "aterm", "URxvt", "XTerm", "Alacritty" }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f0ac} ",
        init = true,
        exclusive = true,
        screen = screen.count() > 1 and 2 or 1,
        class = { "Opera", "Firefox", "Chromium" }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f121} ",
        init = true,
        exclusive = false,
        screen = 1,
        class = {
            "jetbrains-idea",
            "sun-awt-X11-XDialogPeer",
            "sun-awt-X11-XFramePeer",
            "sun-awt-X11-XWindowPeer",
            "insomnia", "Insomnia",
            "code-oss"
        }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f23e} ",
        init = false,
        exclusive = false,
        screen = 1,
        class = { "keepassxc" }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f198} ",
        init = false,
        exclusive = false,
        screen = 1,
        instance = { "messenger.com", "bilderlings-pay.slack.com" },
        class = { "Slack", "slack" }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f07c} ",
        init = false,
        exclusive = false,
        screen = { 1, 2, 3 },
        class = {
            "Thunar", "pcmanfm", "Pcmanfm", 
            "qdirstat", "QDirStat"
        }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f03d} ",
        init = false,
        exclusive = false,
        screen = 1,
        class = { "smplayer" }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f025} ",
        init = false,
        exclusive = false,
        screen = { 1, 2, 3 },
        instance = {
            "Your Library - Playlists"
        }
        class = {
            "deadbeef", "gmpc",
            "spotify", "Spotify", "Pavucontrol",
            "open.spotify.com__collection_playlists"
        }
    },
    {
        layout = awful.layout.suit.max,
        name = " \u{f293} ",
        init = false,
        exclusive = false,
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

