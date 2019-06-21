local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local widget = wibox.widget {
    markup = '',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local cityMap = {
    ["89.201.64.127"] = "Riga"
}

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
 end

local function reload()
    awful.spawn.easy_async(
        {"curl", "-fsL", "ifconfig.me"},
        function(ip)
            city = cityMap[trim(ip)] or ""
            awful.spawn.easy_async(
                {"curl", "-fsL", "--retry", "3", "--retry-connrefused", "https://wttr.in/" .. city .. "?format=3"},
                function(out)
                    widget:set_markup_silently(out)
                end
            )
        end
    )
end

widget:buttons(
    awful.button({}, 1, nil, reload)
)

gears.timer {
    timeout   = 60 * 60,
    call_now  = true,
    autostart = true,
    callback  = reload
}

return widget