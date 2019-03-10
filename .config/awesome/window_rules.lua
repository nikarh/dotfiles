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
        rule = { class = "REAPER"  },
        except = { name = ".*REAPER.*" },
        properties = { tag = tags.names.music }
    },
    {
        rule_any = { class = { "chromium", "Chromium", "Firefox" } },
        properties = { tag = tags.names.web }
    },
    {
        rule_any = { class = { "REAPER", "deadbeef", "gmpc", "spotify", "Spotify", "Deadbeef", "Gmpc", "Pavucontrol", "pavucontrol", "spotify", "open.spotify.com__collection_playlists" } },
        properties = { tag = tags.names.music, floating = false }
    },
    {
        rule = { instance = "Your Library - Playlists", class = "Chromium" },
        properties = { tag = tags.names.music }
    },
    {
        rule = { instance = "Browse - Featured", class = "Chromium" },
        properties = { tag = tags.names.music, floating = false }
    },
    {
        rule = { class = "st-256color", name = "Main Terminal" },
        properties = { tag = tags.names.term }
    },
    {
        rule_any = { class = { "jetbrains-studio", "jetbrains-idea", "code-oss", "insomnia", "Insomnia", "sun-awt-X11-XDialogPeer", "sun-awt-X11-XFramePeer", "sun-awt-X11-XWindowPeer" } },
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
        rule = { instance = "bilderlings-pay.slack.com", class = "Chromium" },
        properties = { tag = tags.names.chat, floating = false }
    },
    {
        rule = { instance = "messenger.com", class = "Chromium" },
        properties = { tag = tags.names.chat, floating = false }
    },
    {
        rule_any = { class = { "Thunar", "pcmanfm", "Pcmanfm", "qdirstat", "QDirStat" } },
        properties = { tag = tags.names.file }
    },
    {
        rule = { class = "gsimplecal" },
        properties = { floating = true }
    },
};
