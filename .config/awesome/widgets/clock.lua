local wibox = require("wibox")
local awful = require("awful")

local clock = wibox.widget.textclock("%a %d %b %R %:::z", 60)
clock:buttons(
    awful.button({}, 1, nil, function ()
        awful.spawn.with_shell("GTK_THEME=Adapta:dark gsimplecal")
    end))

return clock

