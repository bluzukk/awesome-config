
# Script for setting up wallpaper and theme using wal

bg="$(shuf -n1 -e ~/xStuff/wallpaper/QHD/*)"
wal -i $bg
# wal -i ~/xStuff/wallpaper/flowera.jpg
echo $bg
nitrogen --set-zoom-fill $bg --head=0
sleep 1
nitrogen --set-zoom-fill ~/xStuff/wallpaper/QHD/astro.jpg --head=1

sleep 1

# echo 'awesome.restart()' | awesome-client
