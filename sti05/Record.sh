#!/bin/bash

move_vid () {
    dur=`ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1`
    
    if (( $(echo "$dur > 10.00" |bc -l) ))
    then
        # Must have this directory created during setup
        mv $1 ~/backup/System-$vr/Camera-$camera/$1
    fi
    
    # Garbage collection happening on disk right now. Change directory if you want it on gcp.
    rm *.mkv
}

work_dir="`pwd`"

cd ..
vrtyperaw=`ls *.vrtype`
vrtype="${vrtyperaw%.*}"

vrraw=`ls *.vr`
vr="${vrraw%.*}"

vripraw=`ls *.vrip`
vrip="${vripraw%.*}"

usernameraw=`ls *.username`
username="${usernameraw%.*}"

passwordraw=`ls *.password`
password="${passwordraw%.*}"

cd $work_dir

cameraraw=`ls *.camera`
camera="${cameraraw%.*}"

# Call the move function on anything that's already there
# in case it couldn't move it before a reboot.
move_vid `ls *.mkv`

if [ $vrtype = "LOREX" ]
then
    while :
    do
        ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time 900 -segment_format mkv -segment_atclocktime 1 -strftime 1 %Y-%m-%d-%H-%M-%S.mkv
        #ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://admin:a1234567@192.168.1.11:554/cam/realmonitor?channel=2&subtype=0" -vcodec copy -acodec copy -strftime 1 %Y-%m-%dT-%H-%M-%S.mkv
        move_vid `ls *.mkv`
    done
fi

if [ $vrtype = "LTS" ]
then
    while :
    do
        # Edit this:  ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time 900 -segment_format mkv -segment_atclocktime 1 -strftime 1 %Y-%m-%dT-%H-%M-%S.mkv
    done
fi