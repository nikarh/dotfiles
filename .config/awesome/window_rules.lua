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
        rule_any = { class = { "insomnia", "Insomnia" } },
        properties = { tag = tags.names.web }
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
        rule = { instance = "agile-stacks.slack.com", class = "Chromium"},
        properties = { tag = tags.names.chat, floating = false }
    },
    {
        rule = { instance = "parisiancafe.slack.com", class = "Chromium" },
        properties = { tag = tags.names.chat, floating = false }
    },
    {
        rule = { instance = "messenger.com", class = "Chromium" },
        properties = { tag = tags.names.chat, floating = false }
    },
    {
        rule_any = { class = { "Thunar", "pcmanfm", "Pcmanfm" } },
        properties = { tag = tags.names.file }
    },
    {
        rule = { class = "gsimplecal" },
        properties = { floating = true }
    },
    {
        rule = { class = "zoom" },
        properties = { tag = tags.names.video }
    },
};
