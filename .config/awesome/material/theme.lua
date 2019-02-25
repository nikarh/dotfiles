----------------------------------
-- "Material" awesome wm theme  --
-- By https://github.com/nikarh --
----------------------------------

local fonts = {
    sans = "Noto Sans 9",
    sans_bold = "Noto Sans Bold 9",
    mono = "Noto Mono 9",
    fa = "FontAwesome 12"
}

-- {{{ Main
theme = {}
theme.path = os.getenv("HOME") .. "/.config/awesome/material/"
theme.wallpaper = os.getenv("HOME") .. "/.dotfiles/wallpaper.png"
-- }}}

-- {{{ Styles
theme.font = fonts.mono

-- {{{ Colors
theme.fg_normal = "#90A4AE"
theme.fg_focus = "#CFD8DC"
theme.fg_urgent = "#ECEFF1"
theme.bg_normal = "#263238"
theme.bg_focus = "#37474F"
theme.bg_urgent = "#607D8B"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width = 1
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.border_marked = theme.bg_urgent
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = theme.bg_normal
theme.titlebar_bg_normal = theme.bg_focus
theme.titlebar_font = fonts.sans_bold

theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/zenburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/zenburn/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = "/usr/share/awesome/themes/default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "/usr/share/awesome/themes/default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_inactive.png"

-- }}}

-- {{{ Taglist
theme.taglist_squares_sel = theme.path .. "taglist/squarefz.png"
theme.taglist_squares_unsel = theme.path .. "taglist/squarez.png"
theme.taglist_spacing = 5
theme.taglist_font = fonts.fa
-- }}}

-- {{{ Tasklist
theme.tasklist_font = fonts.sans
-- }}}

theme.tooltip_font = fonts.sans
theme.tooltip_bg = theme.bg_normal
theme.tooltip_border_width = 0
theme.tooltip_align = "bottom"

-- {{{ Layout
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
-- }}}

-- {{{ Naughty
theme.notification_width = 550
theme.notification_font =  "Noto Sans UI 11"
-- }}}


return theme
