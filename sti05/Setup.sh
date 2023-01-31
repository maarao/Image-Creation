#!/bin/bash

# Motion configuration
sudo apt install motion

# Add as a service to run as root
sudo service motion start
sudo touch /etc/systemd/system/motion.service
printf "[Unit]\nDescription=Motion service\n\n[Service]\nExecStart=/usr/bin/motion\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/motion.service

# Setup base motion.conf
sudo rm /etc/motion/motion.conf
sudo touch /etc/motion/motion.conf
printf "daemon off\nsetup_mode off\nlog_level 6\nemulate_motion off\nthreshold 1500\ndespeckle_filter EedDl\nminimum_motion_frames 1\nevent_gap 60\npre_capture 3\npost_capture 0\npicture_output off\nmovie_output on\nmovie_max_time 900\nmovie_quality 0\nmovie_codec mkv\nwebcontrol_parms 0\nstream_port 0\nwidth 1280\nheight 720\nframerate 15\ntarget_dir /backup/\nmovie_filename %%\$/%%Y-%%m-%%d/%%T" | sudo tee -a /etc/motion/motion.conf

printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

# Ask for number of NVRs/DVRs
printf "How many NVRs/DVRs are present: "
read novrs

# Create diffreent directories for all systems
novrsint=$((novrs))
i=1
while [ $i -le $novrsint ]
do

    printf "Brand of DVR / NVR:\n1.LTS\n2.Lorex\n"
    read vrtype

    printf "NVR/DVR IP: "
    read vrip

    printf "NVR/DVR Username: "
    read username

    printf "NVR/DVR Password: "
    read password

    printf "How many cameras are going to be backed up: "
    read nocams

    nocamsint=$((nocams))
    j=1
    while [ $j -le $nocamsint ]
    do
        printf "Camera Number: "
        read camera

        sudo mkdir /etc/motion/System-$i
        sudo touch /etc/motion/System-$i/Camera-$camera.conf
        printf "camera_name Camera-$camera" | sudo tee -a /etc/motion/System-$i/Camera-$camera.conf
        
        # LTS - Note the port change
        if [ $vrtype -eq "1" ]
        then
            printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:8544/streaming/channels/${camera}02" | sudo tee -a /etc/motion/System-$i/Camera-$camera.conf
        fi

        # LOREX
        if [ $vrtype -eq "2" ]
        then
            printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0" | sudo tee -a /etc/motion/System-$i/Camera-$camera.conf
        fi
                
        printf "\ncamera /etc/motion/System-$i/Camera-$camera.conf" | sudo tee -a /etc/motion/motion.conf
        
        ((j++))
    done

    ((i++))
done

sudo systemctl enable motion
sudo service motion start

reboot