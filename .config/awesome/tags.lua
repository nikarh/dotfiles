local awful = require("awful")

local t = {
    term = " \u{f120} ",
    web = " \u{f0ac} ",
    dev = " \u{f121} ",
    pass = " \u{f23e} ",
    chat = " \u{f198} ",
    file = " \u{f07c} ",
    music = " \u{f025} "
}

local layouts = {}
layouts[t.term] = {
    name = t.term,
    settings = {
        layout = awful.layout.suit.max,
        selected = true
    }
}
layouts[t.web] = {
    name = t.web,
    settings = {
        layout = awful.layout.suit.max
    }
}
layouts[t.dev] = {
    name = t.dev,
    settings = {
        layout = awful.layout.suit.max
    }
}
layouts[t.pass] = {
    name = t.pass,
    settings = {
        layout = awful.layout.suit.max
    }
}

layouts[t.chat] = {
    name = t.chat,
    settings = {
        layout = awful.layout.suit.max
    }
}

layouts[t.file] = {
    name = t.file,
    settings = {
        layout = awful.layout.suit.tile
    }
}

layouts[t.music] = {
    name = t.music,
    settings = {
        layout = awful.layout.suit.max
    }
}

local layout = {
    layouts[t.term],
    layouts[t.web],
    layouts[t.dev],
    layouts[t.pass],
    layouts[t.chat],
    layouts[t.file],
    layouts[t.music]
}

return {
    names = t,
    layout = layout
}
