local wibox = require("wibox")
local beautiful = require("beautiful")

local batmon = wibox.widget {
    widget        = wibox.widget.progressbar,
    color            = beautiful.fg_focus,
    background_color = "#616161",
    shape = function(cr, width, height)
        local pin_offset = height / 4;
        local offset = 0
        local h = 2;
        local r = 2;

        cr:move_to(offset + r, r)
        cr:arc(offset + r, r, r, 1*math.pi, 1.5*math.pi)
        cr:line_to(offset + width - h - r, 0)
        cr:arc(offset + width - h - r, r, r, 1.5*math.pi, 2*math.pi)
        cr:line_to(offset + width - h, pin_offset)
        cr:line_to(offset + width, pin_offset)
        cr:line_to(offset + width, pin_offset * 2)
        cr:line_to(offset + width, pin_offset * 3)
        cr:line_to(offset + width - h, pin_offset * 3)
        cr:line_to(offset + width - h, height)
        cr:arc(offset + width - h - r, height -r, r, 0*math.pi, 0.5*math.pi)
        cr:line_to(offset + r, height)
        cr:arc(offset + r, height - r, r, 0.5*math.pi, 1*math.pi)
        cr:line_to(offset, r)
        cr:close_path()
    end,
    max_value     = 1,
    value         = 0.5,
    margins = {
        left = 5,
        right = 5,
        top = 8,
        bottom = 8,
    },
}

batmon.timer = timer({ timeout = 10 })
batmon.timer:connect_signal("timeout", function()
    batmon:set_value(4)
end)
batmon.timer:start()

local rot = wibox.widget {
    batmon,
    forced_height = 10,
    forced_width  = 35,
    layout = wibox.container.rotate,
}

return rot;