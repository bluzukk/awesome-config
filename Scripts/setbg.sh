
# Script for setting up wallpaper and theme using wal
bg=~/Rice/wallpaper/nice/1024096.jpg
wal -i $bg
nitrogen --set-zoom-fill $bg --head=0

sleep 1
# nitrogen --set-zoom-fill ~/Rice/wallpaper/QHD/astro.jpg --head=1
sleep 1
nitrogen --restore
# echo 'awesome.restart()' | awesome-client
