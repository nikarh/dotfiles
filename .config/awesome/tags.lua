local awful = require("awful")
local tyrannical = require("tyrannical")
local naughty = require("naughty")

tyrannical.tags = {
    {
        name = " \u{f120} ",
        init = true, -- Load the tag on startup
        exclusive = true, -- Refuse any other type of clients (by classes)
        screen = { 1, 2 }, -- Create this tag on screen 1 and screen 2
        class = { "xterm", "urxvt", "aterm", "URxvt", "XTerm", "Alacritty" }
    },
    {
        name = " \u{f0ac} ",
        init = true,
        exclusive = true,
        screen = screen.count() > 1 and 2 or 1,
        class = { "Opera", "Firefox", "Chromium" }
    },
    {
        name = " \u{f121} ",
        init = true,
        exclusive = false,
        screen = 1,
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
        init = false,
        exclusive = true,
        screen = 1,
        class = { "keepassxc" }
    },
    {
        name = " \u{f198} ",
        init = false,
        exclusive = true,
        screen = 1,
        instance = { "messenger.com" },
        class = { "Slack", "slack" }
    },
    {
        name = " \u{f07c} ",
        init = false,
        exclusive = true,
        screen = 1,
        class = {
            "Thunar", "pcmanfm", "Pcmanfm", "qdirstat", "QDirStat"
        }
    },
    {
        name = " \u{f03d} ",
        init = false,
        exclusive = true,
        screen = 1,
        class = { "smplayer" }
    },
    {
        name = " \u{f025} ",
        init = false,
        exclusive = true,
        screen = 1,
        class = {
            "deadbeef", "gmpc",
            "spotify", "Spotify", "Pavucontrol"
        }
    },
    {
        name = " \u{f293} ",
        init = false,
        exclusive = true,
        screen = 1,
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

tyrannical.default_layout = awful.layout.suit.max
tyrannical.settings.block_children_focus_stealing = false
tyrannical.settings.group_children = true
tyrannical.settings.force_odd_as_intrusive = true
tyrannical.settings.favor_focused = true
tyrannical.settings.no_focus_stealing_out = true
tyrannical.settings.favor_focused = true
