----------------------------------
-- "Material" awesome wm theme  --
-- By https://github.com/nikarh --
----------------------------------

local fonts = {
    sans = "Noto Sans 14",
    sans_bold = "Noto Sans Bold 14",
    mono = "Noto Mono 14",
}

-- Main
theme = {}
theme.path = os.getenv("HOME") .. "/.config/awesome/material/"
theme.wallpaper = os.getenv("HOME") .. "/.dotfiles/wallpaper.png"
theme.font = fonts.mono

-- Colors
theme.fg_normal = "#90A4AE"
theme.fg_focus = "#CFD8DC"
theme.fg_urgent = "#ECEFF1"
theme.bg_normal = "#263238"
theme.bg_focus = "#37474F"
theme.bg_urgent = "#607D8B"
theme.bg_systray = theme.bg_normal

-- Window borders
theme.border_width = 1
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.border_marked = theme.bg_urgent

-- Taglist
theme.taglist_squares_sel = theme.path .. "taglist/squarefz.png"
theme.taglist_squares_unsel = theme.path .. "taglist/squarez.png"
theme.taglist_spacing = 5
theme.taglist_font = fonts.mono

-- Tasklist
theme.tasklist_font = fonts.sans

-- Tooltip
theme.tooltip_font = fonts.sans
theme.tooltip_bg = theme.bg_normal
theme.tooltip_border_width = 0
theme.tooltip_align = "bottom"

-- Layout images
theme.layout_tile = theme.path .. "layouts/tile.png"
theme.layout_tileleft = theme.path .. "layouts/tileleft.png"
theme.layout_tilebottom = theme.path .. "layouts/tilebottom.png"
theme.layout_tiletop = theme.path .. "layouts/tiletop.png"
theme.layout_fairv = theme.path .. "layouts/fairv.png"
theme.layout_fairh = theme.path .. "layouts/fairh.png"
theme.layout_spiral = theme.path .. "layouts/spiral.png"
theme.layout_dwindle = theme.path .. "layouts/dwindle.png"
theme.layout_max = theme.path .. "layouts/max.png"
theme.layout_fullscreen = theme.path .. "layouts/fullscreen.png"
theme.layout_magnifier = theme.path .. "layouts/magnifier.png"
theme.layout_floating = theme.path .. "layouts/floating.png"

-- Notifications
theme.notification_width = 550
theme.notification_font = fonts.sans
theme.notification_icon_size = 64

return theme
