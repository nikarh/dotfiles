local wibox = require("wibox")
local beautiful = require("beautiful")

return wibox.widget {
    wibox.widget {
        wibox.widget {
            markup = '&#xE0B3;',
            font = 'Hack 16',
            widget = wibox.widget.textbox
        },
        fg = beautiful.bg_focus,
        widget = wibox.container.background
    },
    left = 5,
    right = 5,
    widget = wibox.container.margin
}