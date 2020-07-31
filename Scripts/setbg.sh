
# Script for setting up wallpaper and theme using wal

bg="$(shuf -n1 -e ~/Stuff/wallpaper/*)"
wal -i $bg

nitrogen --set-zoom-fill $bg --head=0
nitrogen --set-zoom-fill ~/Stuff/wallpaper/wall.png --head=1
# echo 'awesome.restart()' | awesome-client
