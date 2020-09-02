
# Script for setting up wallpaper and theme using wal

bg="$(shuf -n1 -e ~/Rice/wallpaper/*)"
# wal -i ~/xStuff/wallpaper/QHD/wall.png
# wal -i ~/Rice/wallpaper/sombra.png
wal -i $bg

echo $bg

# nitrogen --set-zoom-fill ~/xStuff/wallpaper/QHD/wall.png --head=0
# nitrogen --set-zoom-fill ~/Rice/wallpaper/new/black.jpg --head=0
nitrogen --set-zoom-fill $bg --head=0
nitrogen --set-zoom-fill ~/Rice/wallpaper/QHD/astro.jpg --head=1
sleep 1
# echo 'awesome.restart()' | awesome-client
