if [ -z "$1" ]
  then
    echo "INFO: Using random wallpaper"
    bg="$(shuf -n1 -e ~/Rice/wallpaper/nice/*)"
  else
    bg=$1
fi

wal -i $bg
#echo $bg

nitrogen --set-zoom-fill $bg --head=0
nitrogen --set-zoom-fill ~/Rice/wallpaper/QHD/astro.jpg --head=1
sleep 1
