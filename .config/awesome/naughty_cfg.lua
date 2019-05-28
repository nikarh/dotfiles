local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")

awful.spawn.easy_async_with_shell(
    "cat ~/.config/gtk-3.0/settings.ini"
        .. "| awk -F'=' '$1==\"gtk-icon-theme-name\"{print $2}'"
        .. "| xargs -I'{}' find /usr/share/icons/{} -type d"
        .. "| sort | sed -e 's/$/\\//'", 
    function(out)
        naughty.config.icon_dirs = gears.table.merge(
            gears.string.split(out, "\n"),
            {
                "/usr/share/icons/hicolor/",
                "/usr/share/icons/",
                "/usr/share/pixmaps/",
            }
        )
    end
)

naughty.config.defaults.icon_size = 64
naughty.config.icon_formats = { "svgz", "svg", "png", "gif" }
naughty.config.width = 600
naughty.config.notify_callback = function(args) return args end
