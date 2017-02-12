-------------------------------------
-- "Material" awesome wm theme     --
--    By https://github.com/nikarh --
-------------------------------------

---------------------------------------
-- Based on "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)           --
---------------------------------------

-- {{{ Main
theme = {}
theme.path = os.getenv("HOME") .. "/.config/awesome/material/"
theme.wallpaper = "/usr/share/wallpapers/deepin/Architect.jpg"
-- }}}

-- {{{ Styles
theme.font      = "Noto Sans UI 9"

-- {{{ Colors
theme.fg_normal  = "#90A4AE"
theme.fg_focus   = "#CFD8DC"
theme.fg_urgent  = "#ECEFF1"
theme.bg_normal  = "#263238"
theme.bg_focus   = "#37474F"
theme.bg_urgent  = "#607D8B"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width  = 1
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_focus
theme.border_marked = theme.bg_urgent
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_normal = theme.bg_normal
theme.titlebar_bg_focus  = theme.bg_focus
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ WidgetS
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 25
theme.menu_width  = 240
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = theme.path .. "taglist/squarefz.png"
theme.taglist_squares_unsel = theme.path .. "taglist/squarez.png"
theme.taglist_spacing = 5
theme.taglist_font = "FontAwesome 12"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme.path .. "awesome-icon.png"
theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = theme.path .. "layouts/tile.png"
theme.layout_tileleft   = theme.path .. "layouts/tileleft.png"
theme.layout_tilebottom = theme.path .. "layouts/tilebottom.png"
theme.layout_tiletop    = theme.path .. "layouts/tiletop.png"
theme.layout_fairv      = theme.path .. "layouts/fairv.png"
theme.layout_fairh      = theme.path .. "layouts/fairh.png"
theme.layout_spiral     = theme.path .. "layouts/spiral.png"
theme.layout_dwindle    = theme.path .. "layouts/dwindle.png"
theme.layout_max        = theme.path .. "layouts/max.png"
theme.layout_fullscreen = theme.path .. "layouts/fullscreen.png"
theme.layout_magnifier  = theme.path .. "layouts/magnifier.png"
theme.layout_floating   = theme.path .. "layouts/floating.png"
-- }}}

-- }}}

return theme
