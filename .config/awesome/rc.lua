local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget

require("awful.autofocus")

local tags = require("tags")

function dirLookup(dir)
    local arr = {}
    local p = io.popen('find "' .. dir .. '" -type d')
    for file in p:lines() do
        arr[#arr + 1] = filename
    end

    return arr
end

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
naughty.config.notify_callback = function(args)
    return args
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/nikarh/.config/awesome/material/theme.lua")


local runcmd = "rofi -show run -terminal alacritty -font"
local runapp = "rofi -combi-modi window,drun -show combi -modi combi"
local terminal = "alacritty -t Terminal -e tmux"

local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}
-- }}}


-- {{{ Wibar
local mykeyboardlayout = awful.widget.keyboardlayout()

local batmon = require("widgets/battery_indicator")
local clock = require("widgets/clock")
local separator = require("widgets/separator")
local window_rules = require("window_rules")

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end))

local tasklist_buttons = awful.util.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c.minimized = false
        if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
        end
        client.focus = c
        c:raise()
    end
end),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    for _, tag in ipairs(tags.layout) do
        tag["settings"]["screen"] = s
        awful.tag.add(tag.name, tag.settings)
    end
    --awful.tag(tags.layout, s, awful.layout.layouts[1])

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,

        -- Left widgets
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        -- Middle widget
        s.mytasklist,
        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            separator,
            {
                wibox.widget.systray(),
                top = 1,
                bottom = 1,
                widget = wibox.container.margin
            },
            separator,
            clock,
            separator,
            {
                s.mylayoutbox,
                top = 3,
                bottom = 3,
                right = 6,
                widget = wibox.container.margin
            }
        },
    }
end)
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),

    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "Left", function() awful.screen.focus_relative(1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "Right", function() awful.screen.focus_relative(-1) end,
        { description = "focus the next screen", group = "screen" }),

    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, "Control" }, "Delete", function() awful.spawn("dm-tool lock") end,
        { description = "lock session", group = "session" }),


    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),

    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            if c then
                client.focus = c
                c:raise()
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.spawn(runcmd) end,
        { description = "run prompt", group = "launcher" }),
    -- Run .desktop file or switch window
    awful.key({ modkey }, "x", function() awful.spawn(runapp) end,
        { description = "application fuzzy search", group = "launcher" }),
    -- Run file manager
    awful.key({ modkey }, "e", function() awful.spawn("thunar") end,
        { description = "file explorer", group = "launcher" }))

local clientkeys = awful.util.table.join(awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
    { description = "toggle fullscreen", group = "client" }),

    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),

    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),

    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),

    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),

    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),

    awful.key({ modkey, }, "n", function(c) c.minimized = true end,
        { description = "minimize", group = "client" }),

    awful.key({ modkey, }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
        { description = "maximize", group = "client" }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" }))
end

local clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = awful.util.table.join({
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_offscreen,
            titlebars_enabled = false,
        }
    }
}, window_rules)

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    if awesome.startup and
            not c.size_hints.user_position
            and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(awful.button({}, 1, function()
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)
    end),
        awful.button({}, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end))

    awful.titlebar(c):setup {
        {
            -- Left
            {
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            left = 5,
            right = 5,
            top = 5,
            bottom = 5,
            layout = wibox.container.margin
        },
        {
            -- Middle
            {
                -- Title
                align = "left",
                font = theme.titlebar_font,
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        {
            -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
