--[[
     Awesome WM Theme
--]]

local theme      = {}
local awful      = require("awful")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local gears      = require("gears")
local lain       = require("lain")
local naughty    = require("naughty")
local markup     = lain.util.markup
local helpers    = require("lain.helpers")
local xresources = require("beautiful.xresources")
local xrdb       = xresources.get_current_theme()
local os         = { getenv = os.getenv }
local my_table   = awful.util.table or gears.table -- 4.{0,1} compatibility
local terminal   = "st -f 'Mono-14'"


-- Scripts and Cmds
cmd_ip4       = 'bash -c "curl ifconfig.me 2>/dev/null"'
cmd_ssid      = 'bash -c "LANG=C nmcli -t -f active,ssid dev wifi | grep ^yes | cut -d: -f2-"'

cmd_cpu_temp  = 'bash -c "cat /sys/class/hwmon/hwmon1/temp2_input"'
cmd_temps     = 'bash -c "sensors -A"'

cmd_gpu_temp  = 'bash -c "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"'
cmd_gpu       = 'bash -c "nvidia-smi"'

cmd_proc_cpu  = 'bash -c "ps -Ao pcpu,comm,user,pid, --sort=-pcpu | head -n 30"'
cmd_proc_mem  = 'bash -c "ps -Ao pmem,comm,user,pid --sort=-pmem | head -n 30"'

cmd_net_info  = 'bash -c "~/.config/awesome/Scripts/net_info.sh"'
cmd_net_total = 'bash -c "~/.config/awesome/Scripts/net_totals.sh"'
cmd_mail_ims  = 'bash -c "~/.config/awesome/Scripts/Hidden/checkmail_ims.sh"'
cmd_mail      = 'bash -c "~/.config/awesome/Scripts/Hidden/checkmail_uni.sh"'

-- Colors
local black        = "#000000"
local white        = "#FFFFFF"
local red          = "#e54c62"

local color_default    = xrdb.color6
local color_moderate   = xrdb.color7
local color_stress     = xrdb.color8
local color_critical   = red
local accent_color     = xrdb.color2
local main_color       = xrdb.color3
local background_color = xrdb.background

-- local std_font = "Terminus (TTF) 15"
-- local std_font = "Mono 13"
local std_font = "Sans 13"

theme.font                  = std_font
theme.fg_normal             = xrdb.color2
theme.bg_normal             = black
theme.fg_urgent             = black
theme.bg_urgent             = xrdb.color10
theme.border_normal         = background_color
theme.border_focus          = xrdb.color5
theme.taglist_fg_focus      = xrdb.color6
theme.taglist_bg_focus      = background_color
theme.tasklist_fg_focus     = xrdb.color6
theme.tasklist_fg_normal    = xrdb.color2
theme.tasklist_bg_focus     = background_color
theme.tasklist_bg_normal    = background_color
theme.border_width          = 0
theme.tasklist_disable_icon = true
theme.useless_gap           = 8
-- theme.tasklist_plain_task_name = true

local notification = nil

function notification_hide()
    if not notification then return end
    naughty.destroy(notification)
    notification = nil
end

function notification_show(str)
    notification_hide()
    notification = naughty.notify {
        preset = {
            font = "Terminus (TTF) 18",
            fg = main_color,
            bg = black
          },
        --title  = "Warning",
        text   = str
    }
end

-- Textclock
local textclock = wibox.widget.textclock(" %H%M ")
textclock.font = theme.font

--Calendar
lain.widget.cal({
    icons = '',
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
    if not stdout then
        widget:set_markup(markup.fontfg(std_font, accent_color, 'no ip4'))
    else
        widget:set_markup(markup.fontfg(std_font, accent_color, stdout))
    end
    widget:connect_signal("button::press", net_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    return
end)

-- Show ssid
ssid = awful.widget.watch(cmd_ssid, 600, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, accent_color, stdout))
    widget:connect_signal("button::press", net_notification_show)
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
    widget:set_markup(markup.fontfg(std_font, color, value .. '°C '))
    widget:connect_signal("button::press", temps_notification_show)
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
    widget:set_markup(markup.fontfg(std_font, color, value .. '°C '))
    -- widget:connect_signal("mouse::enter", gpu_notification_show)
    widget:connect_signal("mouse::leave", notification_hide)
    widget:connect_signal("button::press", gpu_notification_show)
    return
end)

--CPU
function cpu_notification_show(str)
    helpers.async(cmd_proc_cpu, function(f)
        notification_show(f)
    end)
end
-- local runonce = 0
-- function cpu_on_click()
--     awful.spawn(terminal .. ' htop -s PERCENT_CPU')
--     -- TODO Fix
--     helpers.async('sleep 1', function(f)
--         runonce = 0
--     end)
-- end
local cpu_util = lain.widget.cpu({
    settings = function()
        local value = cpu_now.usage
        if     value > 65 then color = color_critical
        elseif value > 47 then color = color_stress
        elseif value > 27 then color = color_moderate
        else                   color = color_default
        end
        widget:set_markup(markup.font(std_font, markup(color, cpu_now.usage .. "% ")))
        widget:connect_signal("mouse::enter", cpu_notification_show)
        widget:connect_signal("mouse::leave", notification_hide)
        -- widget:connect_signal("button::press", function(_, _, _, button)
        --     if (button == 3) then cpu_notification_show()
        --     elseif (button == 1) then cpu_notification_show()
        --     elseif (button == 2) then
        --       if (runonce == 0) then
        --         runonce = 1
        --         cpu_on_click()
        --       end
        --     end
        -- end)
    end
})

-- MEM
function mem_notification_show(str)
    helpers.async(cmd_proc_mem, function(f)
        notification_show(f)
    end)
end
-- local runonce = 0
-- function mem_on_click()
--     awful.spawn(terminal .. ' htop -s PERCENT_MEM')
--     -- TODO Fix
--     helpers.async('sleep 1', function(f)
--         runonce = 0
--     end)
-- end
local mem = lain.widget.mem({
    settings = function()
        local value = mem_now.used
        if     value > 13000 then color = color_critical
        elseif value > 9000  then color = color_stress
        elseif value > 6000  then color = color_moderate
        else                      color = color_default
        end
        widget:set_markup(markup.font(std_font, markup(color, value .. "mb")))
        widget:connect_signal("mouse::enter", mem_notification_show)
        widget:connect_signal("mouse::leave", notification_hide)
        -- widget:connect_signal("button::press", function(_, _, _, button)
        --     if     (button == 3) then mem_notification_show()
        --     elseif (button == 1) then mem_notification_show()
        --     elseif (button == 2) then
        --       if (runonce == 0) then
        --         runonce = 1
        --         mem_on_click()
        --       end
        --     end
        -- end)
    end
})

-- fs
theme.fs = lain.widget.fs({
    notification_preset = { font = "Terminus (TTF) 18", fg = main_color},
    settings  = function()
        widget:set_markup(markup.fontfg(std_font, accent_color, string.format("%.2f", fs_now["/"].free) .. "gb"))
    end
})

total_net = awful.widget.watch(cmd_net_total, 10, function(widget, stdout)
    widget:set_markup(markup.fontfg(std_font, accent_color, tonumber(stdout) .. 'mb'))
    return
end)

--Net checker
local net = lain.widget.net({
    settings = function()
        value = tonumber(net_now.received)
        if     value > 3200 then color = color_critical
        elseif value > 1800 then color = color_stress
        elseif value > 400  then color = color_moderate
        else                     color = color_default end
        value = string.format("%04.0f", value)
        widget:set_markup(markup.fontfg(std_font, color, " " .. value .. "kb/s "))
    end
})

-- Battery
local bat = lain.widget.bat({
    timeout = 1,
    settings = function()
        value = tonumber(bat_now.perc)
        if value then
            if     value > 59 then color = color_default
            elseif value > 46 then color = color_moderate
            elseif value > 24 then color = color_stress
            else                   color = color_critical end
            widget:set_markup(
                markup.font(std_font, markup(color," " .. value .. "%"))
            )
        end
end
})

--Weather
theme.weather = lain.widget.weather({
    notification_preset = { font = "Terminus (TTF) 18", fg = main_color},
    city_id = 2836320, icons_path = '',
    settings = function()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup.fontfg(std_font, accent_color, units .. "°C"))
    end
})

-- local pomodoro = require("widgets.pomodoro.pomodoro")
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
    s.mywibox = awful.wibar({ position = "top", screen = s, bg = background_color, height = 20 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist, s.mytxtlayoutbox, spr,
            net.widget,
            total_net, spr,
            ip4, spr,
            ssid, spr,
            s.mypromptbox, spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            --todo_widget, spr,
            cpu_util,
            cpu_temp,
            gpu_temp,
            mem.widget,
            mail, mail_ims,
            bat.widget, spr,
            theme.weather.widget,spr,
            theme.fs.widget, spr,
            --pomodoro, spr,
            wibox.widget.systray(), spr,
            textclock,
        },
    }
end

return theme
