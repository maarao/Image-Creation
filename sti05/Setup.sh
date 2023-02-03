#!/bin/bash
cd ~/

check=`ls *.done`
expected='gcs.done'

# Setup
if [[ $check != $expected ]]
then
    firefox mail.google.com

    cd ~/Downloads
    filename=`ls *.json`
    user="${filename%.*}"

    mv ~/Downloads/$user.json ~/.$user.json

    sudo sed -i '$d' /etc/fstab
    echo st-$user /backup/ gcsfuse rw,_netdev,allow_other,uid=1000,key_file=/home/sti05/.$user.json | sudo tee -a /etc/fstab

    rm -R ~/snap/firefox/

    touch gcs.done
fi

# Reset everything in-case it is a re-setup
sudo apt remove motion -y && sudo rm -r /etc/motion/ && sudo sudo systemctl disable motion && sudo rm /etc/systemd/system/motion.service

# Motion configuration
sudo apt install motion -y

# Add as a service to run as root
sudo service motion start
sudo touch /etc/systemd/system/motion.service
printf "[Unit]\nDescription=Motion service\n\n[Service]\nExecStart=/usr/bin/motion\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/motion.service

# Setup base motion.conf
sudo rm /etc/motion/motion.conf
sudo touch /etc/motion/motion.conf
printf "daemon off\nsetup_mode off\nlog_level 6\nemulate_motion off\nthreshold 1500\ndespeckle_filter EedDl\nminimum_motion_frames 1\nevent_gap 60\npre_capture 3\npost_capture 0\npicture_output off\nmovie_output on\nmovie_max_time 900\nmovie_passthrough on\nwebcontrol_parms 0\nstream_port 0\nwidth 1280\nheight 720\nframerate 15\nmovie_filename %%\$/%%Y-%%m-%%d/%%T" | sudo tee -a /etc/motion/motion.conf

printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

# Ask for number of NVRs/DVRs
printf "How many NVRs/DVRs are present: "
read novrs

novrsint=$((novrs))
i=1
while [ $i -le $novrsint ]
do

    printf "Brand of DVR / NVR Number $i :\n1.LTS\n2.Lorex\n"
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

        
        
        # LTS - Note the port change
        if [ $vrtype -eq "1" ]
        then
            sudo mkdir /etc/motion/LTS-$i
            sudo touch /etc/motion/LTS-$i/Camera-$camera.conf
            printf "camera_name Camera-$camera" | sudo tee -a /etc/motion/LTS-$i/Camera-$camera.conf
            printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:8554/streaming/channels/${camera}02\ntarget_dir /backup/LTS-$i" | sudo tee -a /etc/motion/LTS-$i/Camera-$camera.conf
            printf "\ncamera /etc/motion/LTS-$i/Camera-$camera.conf" | sudo tee -a /etc/motion/motion.conf
        fi

        # LOREX
        if [ $vrtype -eq "2" ]
        then
            sudo mkdir /etc/motion/LOREX-$i
            sudo touch /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "camera_name Camera-$camera" | sudo tee -a /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0\ntarget_dir /backup/LOREX-$i" | sudo tee -a /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "\ncamera /etc/motion/LOREX-$i/Camera-$camera.conf" | sudo tee -a /etc/motion/motion.conf
        fi

        printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        
        ((j++))
    done

    ((i++))
done

sudo systemctl enable motion
sudo service motion start

reboot