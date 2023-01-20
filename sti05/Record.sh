#!/bin/bash

check=`ls *.done`
expected= 'setup.done'

if [ $check != $expected ]
then
    printf '\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'
    
    printf 'NVR/DVR IP: '
    read vrip
    touch $vrip.vrip

    printf 'NVR/DVR Username: '
    read username
    touch $username.username

    printf 'NVR/DVR Password: '
    read password
    touch $password.password

    printf 'Camera Number: '
    read camera
    touch $camera.camera

    touch setup.done
fi

vripraw=`ls *.vrip`
vrip="${vripraw%.*}"

usernameraw=`ls *.username`
username="${usernameraw%.*}"

passwordraw=`ls *.password`
password="${passwordraw%.*}"

cameraraw=`ls *.camera`
camera="${cameraraw%.*}"

while :
do
    ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time 900 -segment_format mkv -segment_atclocktime 1 -strftime 1 %Y%m%dT%H%M%S.mkv
done