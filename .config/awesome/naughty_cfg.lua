local naughty = require("naughty")

naughty.config.defaults.icon_size = 48
naughty.config.icon_dirs = {
    os.getenv("HOME") .. "/.icons/Flat-Remix/status/",
    "/usr/share/icons/Flat-Remix/",
    "/usr/share/icons/Flat-Remix/base/",
    "/usr/share/icons/Flat-Remix/symbolic/",
    "/usr/share/icons/Flat-Remix/apps/scalable/",
    "/usr/share/icons/Flat-Remix/status/",
    "/usr/share/icons/hicolor/",
    "/usr/share/icons/",
    "/usr/share/pixmaps/",
}

naughty.config.icon_formats = { "svgz", "svg", "png", "gif" }
naughty.config.width = 600
naughty.config.notify_callback = function(args) return args end
