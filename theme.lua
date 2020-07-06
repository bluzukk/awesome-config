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
local terminal  = "st -f 'Mono-14'"


-- Scripts and Cmds
cmd_ip4       = 'bash -c "curl ifconfig.me 2>/dev/null"'
cmd_ssid      = 'bash -c "LANG=C nmcli -t -f active,ssid dev wifi | grep ^yes | cut -d: -f2-"'

cmd_cpu_temp  = 'bash -c "cat /sys/class/hwmon/hwmon1/temp2_input"'
cmd_temps     = 'bash -c "sensors -A"'

cmd_gpu_temp  = 'bash -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"'
cmd_gpu       = 'bash -c "nvidia-smi"'

cmd_proc_cpu  = 'bash -c "ps -Ao comm,user,pid,pcpu,pmem --sort=-pcpu | head -n 30"'
cmd_proc_mem  = 'bash -c "ps -Ao comm,user,pid,pmem,pcpu --sort=-pmem | head -n 30"'

cmd_wttr      = 'bash -c "curl wttr.in"'

cmd_net_info  = 'bash -c "~/.config/awesome/Scripts/net_info.sh"'
cmd_net_total = 'bash -c "~/.config/awesome/Scripts/net_total.sh"'
cmd_mail_ims  = 'bash -c "~/.config/awesome/Scripts/checkmail_ims.sh"'
cmd_mail      = 'bash -c "~/.config/awesome/Scripts/checkmail_uni.sh"'


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

function notification_hide()
    if not notification then return end
    naughty.destroy(notification)
    notification = nil
end

function notification_show(str)
    notification_hide()
    notification = naughty.notify {
        preset = { font = "Terminus (TTF) 18", fg = main_color},
        -- title  = "Warning",
        text   = str
    }
end

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
function net_notification_show(str)
    helpers.async(cmd_net_info, function(f)
        notification_show(f)
    end)
end
ip4 = awful.widget.watch(cmd_ip4, 600, function(widget, stdout)
    if (stdout == "") then
        widget:set_markup(markup.fontfg(std_font, blue, 'no ip4'))
    else
        widget:set_markup(markup.fontfg(std_font, blue, stdout))
    end
    widget:connect_signal("mouse::enter", net_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    return
end)

-- Show ssid
ssid = awful.widget.watch(cmd_ssid, 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, blue, stdout))
    widget:connect_signal("mouse::enter", net_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    return
end)

-- Mail Widget
mail_ims = awful.widget.watch(cmd_mail_ims, 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, red, stdout))
    return
end)

-- Mail Widget
mail = awful.widget.watch(cmd_mail, 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, red, stdout))
    return
end)

-- CPU Temperature
function temps_notification_show(str)
    helpers.async(cmd_temps, function(f)
        notification_show(f)
    end)
end
cpu_temp = awful.widget.watch(cmd_cpu_temp, 10, function(widget, stdout)
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
    widget:connect_signal("mouse::enter", temps_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    return
end)

-- GPU Temperature
function gpu_notification_show(str)
    helpers.async(cmd_gpu, function(f)
        notification_show(f)
    end)
end
gpu_temp = awful.widget.watch(cmd_gpu_temp, 10, function(widget, stdout)
    local value = tonumber(stdout)
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
    widget:connect_signal("mouse::enter", gpu_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    -- widget:connect_signal("button::press", )
    return
end)

--CPU
function cpu_notification_show(str)
    helpers.async(cmd_proc_cpu, function(f)
        notification_show(f)
    end)
end
function cpu_on_click()
    awful.spawn(terminal .. ' htop -s PERCENT_CPU')
end
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
        widget:connect_signal("mouse::enter", cpu_notification_show)
        widget:connect_signal("mouse::leave", notification_hide)
        widget:connect_signal("button::press", cpu_on_click)
    end
})

-- MEM
function mem_notification_show(str)
    helpers.async(cmd_proc_mem, function(f)
        notification_show(f)
    end)
end
function mem_on_click()
    awful.spawn(terminal .. ' htop -s PERCENT_MEM')
end
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
        widget:connect_signal("mouse::enter", mem_notification_show)
        widget:connect_signal("mouse::leave", notification_hide)
        widget:connect_signal("button::press", mem_on_click)
    end
})

-- fs
theme.fs = lain.widget.fs({
    notification_preset = { font = "Terminus (TTF) 18", fg = main_color},
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
function weather_on_click()
    awful.spawn(terminal .. ' curl && wttr.in')
end
theme.weather = lain.widget.weather({
    notification_preset = { font = "Terminus (TTF) 18", fg = main_color},
    city_id = 2836320,
    settings = function()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(std_font, accent_color, units .. "°C"))
        widget:connect_signal("button::press", weather_on_click)
    end
})

local spr = wibox.widget.textbox('   ')

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
