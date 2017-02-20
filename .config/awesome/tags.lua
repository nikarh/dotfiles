local t = {
    term = " \u{f120} ",
    web  = " \u{f0ac} ",
    dev  = " \u{f121} ",
    mail = " \u{f0e0} ",
    pass = " \u{f23e} ",
    chat = " \u{f198} ",
    file = " \u{f07c} ",
}

return {
    names = t,
    layout = { t.term, t.web, t.dev, t.mail, t.pass, t.chat, t.file }
}