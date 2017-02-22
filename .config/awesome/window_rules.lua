local tags = require("tags")

return {
    {
        rule_any = {
            class = {
                "insync.py",
                "jetbrains-toolbox",
            },
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },
    {
        rule_any = { class = { "chromium", "Chromium", "Firefox" } },
        properties = { tag = tags.names.web }
    },
    {
        rule_any = { class = { "mail", "Thunderbird" } },
        properties = { tag = tags.names.mail }
    },
    {
        rule = { class = "st-256color", name = "Main Terminal" },
        properties = { tag = tags.names.term }
    },
    {
        rule = { class = "jetbrains-idea" },
        properties = { tag = tags.names.dev }
    },
    {
        rule = { class = "keepassxc" },
        properties = { tag = tags.names.pass }
    },
    {
        rule_any = { class = { "Slack", "slack" } },
        properties = { tag = tags.names.chat }
    },
    {
        rule_any = { class = { "Thunar", "pcmanfm" } },
        properties = { tag = tags.names.file }
    },
    {
        rule = { class = "gsimplecal" },
        properties = { floating = true }
    },
};