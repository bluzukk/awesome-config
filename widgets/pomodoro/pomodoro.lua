-------------------------------------------------
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require "gears"

local cmd_start = 'bash -c ". ~/.config/awesome/pomo/pomo.sh start"'
local cmd_pause = 'bash -c ". ~/.config/awesome/pomo/pomo.sh pause"'
local cmd_stop = 'bash -c ". ~/.config/awesome/pomo/pomo.sh stop"'
local cmd_get = 'bash -c ". ~/.config/awesome/pomo/pomo.sh clock"'

local work_time  = 25*60
local pause_time = 5*60

local pomodoro = wibox.widget {
    max_value        = work_time,
    value            = 0.33,
    forced_height    = 5,
    forced_width     = 20,
    border_width     = 2,
    color            = "#4169E1",
    opacity          = 0.33,
    background_color = "#000000",
    -- border_color     = "#123456",
    widget           = wibox.widget.progressbar,
    -- direction        = 'east',
}

local notification_present = {
    font = "Terminus (TTF) 20",
    fg = "#00CC66",
    bg = "#000000"
}

local min
local sec
local pomostatus
local status
local workbreak

local update_bar = function(widget, stdout)
    pomostatus = string.match(stdout, "  (%D?%D?):%D?%D?")
    if pomostatus == "--" then
        widget.color = "#000000"
      widget.value = 0
      widget.forced_width = 20
    else
      widget.forced_width = 100
      min = string.match(stdout, "(%d?%d?):%d?%d?")
      sec = string.match(stdout, "%d?%d?:(%d?%d?)")

      status = string.match(stdout, "([ P]?)[BW]")
      workbreak = string.match(stdout, "[ P]?([BW])")
      widget.value = tonumber(min*60+sec)

      if status == " " then -- clock ticking
        if workbreak == "W" then
          widget.max_value = work_time
          if tonumber(min) < 5 then -- last 5 min of pomo
            widget.color = "#800080"
            if tonumber(min) < 1 then
              if tonumber(sec) < 10 then
                naughty.notify {
                  text = 'Time for a break!',
                  timeout = 10,
                  hover_timeout = 0.5,
                  -- width = 200,
                  preset = notification_present
                }
              end
            end
          else
            widget.color = "#4169E1"
          end

        elseif workbreak == "B" then -- color during pause
          widget.color = "#00CC66"
          widget.max_value = pause_time
          if tonumber(min) < 1 then
            if tonumber(sec) < 10 then
              naughty.notify {
                text = 'Time for some work!',
                timeout = 10,
                hover_timeout = 0.5,
                -- width = 200,
                preset = notification_present
              }
            end
          end
        end
      elseif status == "P" then -- paused
        widget.color = "#00CC66"
      end
    end
end

pomodoro:connect_signal("button::press", function(_, _, _, button)
    if (button == 2) then awful.spawn(cmd_pause, false)
    elseif (button == 1) then awful.spawn(cmd_start, false)
    elseif (button == 3) then awful.spawn(cmd_stop, false)
    end

    awful.spawn.easy_async(cmd_get, function(stdout)
        update_bar(pomodoro, stdout)
    end)
end)

local notification
function show_status()
    if pomostatus == '--' then
        ztext = 'Pomodoro not running'
    elseif status == "P" then
        ztext = 'Have a nice break!'
    elseif workbreak == "W" then
        ztext = 'You have still some work to do! (' .. min .. 'min)'
    elseif workbreak == "B" then
        ztext = 'Have a nice break! (' .. min .. 'min)'
    end
    notification = naughty.notify {
        text = ztext,
        timeout = 10,
        preset = notification_present
    }
end

pomodoro:connect_signal("mouse::enter", function() show_status() end)
pomodoro:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
awful.widget.watch(cmd_get, 10, update_bar, pomodoro)
return pomodoro
