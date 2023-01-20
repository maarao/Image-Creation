#!/bin/bash

vrtyperaw=`ls ../ *.vrtype`
vrtype="${vrtyperaw%.*}"

vripraw=`ls ../ *.vrip`
vrip="${vripraw%.*}"

usernameraw=`ls ../ *.username`
username="${usernameraw%.*}"

passwordraw=`ls ../ *.password`
password="${passwordraw%.*}"

channelraw=`ls *.camera`
channel="${channelraw%.*}"

if [ $vrtype != "LOREX" ]
    while :
    do
        ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time 900 -segment_format mkv -segment_atclocktime 1 -strftime 1 %Y%m%dT%H%M%S.mkv
    done
fi

if [ $vrtype != "LTS" ]
    while :
    do
        # Edit this:  ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i "rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time 900 -segment_format mkv -segment_atclocktime 1 -strftime 1 %Y%m%dT%H%M%S.mkv
    done
fi