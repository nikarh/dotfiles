local awful = require("awful")

local t = {
    term  = " \u{f120} ",
    web   = " \u{f0ac} ",
    dev   = " \u{f121} ",
    mail  = " \u{f0e0} ",
    pass  = " \u{f23e} ",
    chat  = " \u{f198} ",
    video = " \u{f03d} ",
    file  = " \u{f07c} ",
    music = " \u{f025} "
}

local layout = {
    {name = t.term, settings = {
        layout   = awful.layout.suit.tile,
        selected = true
    }},
    {name = t.web, settings = {
        layout = awful.layout.suit.max
    }},
    {name = t.dev, settings = {
        layout = awful.layout.suit.max
    }},
    {name = t.mail, settings = {
        layout = awful.layout.suit.max
    }},
    {name = t.pass, settings = {
        layout = awful.layout.suit.max
    }},
    {name = t.chat, settings = {
        layout = awful.layout.suit.max
    }},
    {name = t.file, settings = {
        layout = awful.layout.suit.tile
    }},
    {name = t.music, settings = {
        layout = awful.layout.suit.max
    }},
}

return {
    names = t,
    layout = layout
}
