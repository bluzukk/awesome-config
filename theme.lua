--[[
     Awesome WM Theme
--]]

local theme     = {}
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")
local naughty   = require ("naughty")
local markup    = lain.util.markup
local helpers   = require("lain.helpers")
local os        = { getenv = os.getenv }
local my_table  = awful.util.table or gears.table -- 4.{0,1} compatibility

-- Colors
local black        = "#000000"
local white        = "#FFFFFF"
local gray         = "#94928F"

local blue         = "#4169E1"
local green        = "#00CC66"
local light_green  = "#46FF9B"
local green_orange = "#87af5f"
local yellow       = "#FFFF00"
local orange       = "#FFA500"
local red          = "#e54c62"
local reds         = "#FF5555"
local pink         = "#FF45A8"
local purple       = "#800080"
local purple_dark  = "#461B7E"
local purple_wall  = "#774A86"

local color_default  = green
local color_moderate = green_orange
local color_stress   = yellow
local color_critical = red
local accent_color   = blue
local main_color     = green

-- local std_font = "Terminus (TTF) 15"
-- local std_font = "Mono 13"
local std_font = "Sans 13"

theme.font                  = std_font
theme.fg_normal             = white
theme.fg_focus              = black
theme.bg_normal             = black
theme.bg_focus              = green
theme.fg_urgent             = black
theme.bg_urgent             = green
theme.border_normal         = black
theme.border_focus          = green
theme.taglist_fg_focus      = main_color
theme.taglist_bg_focus      = black
theme.tasklist_fg_focus     = main_color
theme.tasklist_fg_normal    = white
theme.tasklist_bg_focus     = black
theme.tasklist_bg_normal    = black
theme.border_width          = 0
theme.tasklist_disable_icon = true
theme.useless_gap           = 8
-- theme.tasklist_plain_task_name = true

-- Textclock
local mytextclock = wibox.widget.textclock(" %H%M ")
mytextclock.font = theme.font

--Calendar
lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus (TTF) 20",
        fg   = main_color,
        bg   = black,
        icon = ""
    }
})

-- Show ip4
ip4 = awful.widget.watch('bash -c "curl ifconfig.me 2>/dev/null"', 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, blue, stdout))
    -- widget:connect_signal("mouse::enter", showWifi2)
    return
end)

-- Show ssid
ssid = awful.widget.watch('bash -c "LANG=C nmcli -t -f active,ssid dev wifi | grep ^yes | cut -d: -f2-"', 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, blue, stdout))
    return
end)

-- Mail Widget
mail_ims = awful.widget.watch('bash -c "~/.config/awesome/Scripts/checkmail_ims.sh"', 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, red, stdout))
    return
end)

-- Mail Widget
mail = awful.widget.watch('bash -c "~/.config/awesome/Scripts/checkmail_uni.sh"', 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, red, stdout))
    return
end)

-- CPU Temperature
cpu_temp = awful.widget.watch('bash -c "cat /sys/class/hwmon/hwmon1/temp2_input"', 10, function(widget, stdout)
    local value = tonumber(stdout/1000)
    if value > 65 then
        color = color_critical
    elseif value > 62 then
        color = color_stress
    elseif value > 58 then
        color = color_moderate
    else
        color = color_default
    end
    value = string.format("%02.0f", value)
    widget:set_markup(markup.fontfg(std_font, color, value .. '°C'))
    return
end)

-- -- GPU Temperature
-- gpu_temp = awful.widget.watch('bash -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"', 10, function(widget, stdout)
--     local value = tonumber(stdout)
--     if value > 65 then
--         color = color_critical
--     elseif value > 62 then
--         color = color_stress
--     elseif value > 58 then
--         color = color_moderate
--     else
--         color = color_default
--     end
--     value = string.format("%02.0f", value)
--     widget:set_markup(markup.fontfg(std_font, color, value .. '°C'))
--     return
-- end)

--GPU
local gpu_temp = lain.widget.gpu({
    settings = function()
        local gpu_temp = gpu_temp_now
        if gpu_temp > 65 then
            color = color_critical
        elseif gpu_temp > 47 then
            color = color_stress
        elseif gpu_temp > 40 then
            color = color_moderate
        elseif gpu_temp > 0 then
            color = color_default
        end
        widget:set_markup(markup.font(std_font, markup(color, gpu_temp .. "°C")))
    end
})

--CPU
local cpu_util = lain.widget.cpu({
    settings = function()
        local value = cpu_now.usage
        if value > 65 then
            color = color_critical
        elseif value > 47 then
            color = color_stress
        elseif value > 27 then
            color = color_moderate
        elseif value > 0 then
            color = color_default
        end
        widget:set_markup(markup.font(std_font, markup(color, cpu_now.usage .. "%")))
    end
})

-- MEM
local mem = lain.widget.mem({
    settings = function()
        local value = mem_now.used
        if value > 13000 then
            color = color_critical
        elseif value > 9000 then
            color = color_stress
        elseif value > 6000 then
            color = color_moderate
        elseif value > 0 then
            color = color_default
        end
        widget:set_markup(markup.font(std_font, markup(color, value .. "mb")))
    end
})

-- fs
theme.fs = lain.widget.fs({
    notification_preset = { font = "Terminus (TTF) 14", fg = theme.fg_normal },
    settings  = function()
        widget:set_markup(markup.fontfg(std_font, blue, string.format("%.2f", fs_now["/"].free) .. "gb"))
    end
})

--Net checker
local net = lain.widget.net({
    settings = function()
        value = tonumber(net_now.received)
        if value > 3200 then
            color = color_critical
        elseif value > 1800 then
            color = color_stress
        elseif value > 400 then
            color = color_moderate
        else
            color = color_default
        end
        value = string.format("%04.0f", value)
        widget:set_markup(
            markup.fontfg(std_font, color, " " .. value .. "kb/s ") ..
            markup.fontfg(std_font, accent_color, net_now.total .. "mb")
          )
    end
})

-- Battery
local bat = lain.widget.bat({
    timeout = 1,
    settings = function()
        value = tonumber(bat_now.perc)
        if value then
            if value > 59 then
              color = color_default
            elseif value > 46 then
              color = color_moderate
            elseif value > 24 then
              color = color_stress
            else
              color = color_critical
            end
            widget:set_markup(markup.font(std_font, markup(color, value .. "%")))
        end
    end
})

--Weather
theme.weather = lain.widget.weather({
    city_id = 2836320,
    settings = function()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(std_font, accent_color, units .. "°C"))
    end
})

local spr   = wibox.widget.textbox('   ')

function theme.at_screen_connect(s)
    -- Quake application
    -- s.quake = lain.util.quake({ app = awful.util.terminal })
    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)
    -- Create the wibox
    -- s.mywibox = awful.wibar({ position = "top", screen = s, bg = beautiful.bg_normal .. "0", height = 20  })
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 20 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mytxtlayoutbox,
            spr,
            net.widget,
            spr,
            ip4,
            spr,
            ssid,
            spr,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- spr,
            --todo_widget,
            cpu_util,
            spr,
            cpu_temp,
            spr,
            gpu_temp,
            spr,
            mem.widget,
            mail,
            mail_ims,
            bat.widget,
            spr,
            theme.weather.widget,
            spr,
            theme.fs.widget,
            spr,
            wibox.widget.systray(),
            spr,
            mytextclock
        },
    }
end

return theme

-- -- CPU Utilization
-- cpu_util = awful.widget.watch('bash -c "~/.config/awesome/Scripts/cpu_util.sh"', 2, function(widget, stdout)
--     widget:set_markup(markup.fontfg(std_font, blue, stdout))
--     return
-- end)
