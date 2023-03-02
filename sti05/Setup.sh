#!/bin/bash
cd ~/

check=`ls gcs.done`
expected='gcs.done'

# GCS Setup
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

check=`ls ip.done`
expected='ip.done'
# GCS Setup
if [[ $check != $expected ]]
then
    printf "What is the wifi router IP: "
    read routerip

    printf "Assign a static IP to the device: "
    read deviceip


    printf "interface eth0" | sudo tee -a /etc/dhcpcd.conf
    echo static_routers=$routerip | sudo tee -a /etc/dhcpcd.conf
    # TODO: Figure out what this does
    printf "static domain_name_servers=192.168.1.1" | sudo tee -a /etc/dhcpcd.conf
    echo static ip_address=$deviceip | sudo tee -a /etc/dhcpcd.conf
    # TODO: Figure out how to remove all of this just in case we need to reset this

    touch ip.done
fi

# Reset everything in-case it is a re-setup
sudo apt remove motion -y && sudo rm -r /etc/motion/ && sudo sudo systemctl disable motion && sudo rm /etc/systemd/system/motion.service && sudo rm -r ~/.config/autostart

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
            printf "Where is the camera connected into?\n1. Device\n2. Network\n"
            read connecttype
            
            sudo mkdir /etc/motion/LTS-$i
            sudo touch /etc/motion/LTS-$i/Camera-$camera.conf
            printf "camera_name Camera-$camera" | sudo tee -a /etc/motion/LTS-$i/Camera-$camera.conf
            
            if [ $connecttype -eq "1" ]
            then
                printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:8554/streaming/channels/${camera}02\ntarget_dir /home/sti05/backup/LTS-$i" | sudo tee -a /etc/motion/LTS-$i/Camera-$camera.conf
            fi

            if [ $connecttype -eq "2" ]
            then
                printf "Camera IP: "
                read camip

                printf "\nnetcam_url rtsp://${username}:${password}@${camip}:554/streaming/channels/102\ntarget_dir /home/sti05/backup/LTS-$i" | sudo tee -a /etc/motion/LTS-$i/Camera-$camera.conf
            fi
            
            printf "\ncamera /etc/motion/LTS-$i/Camera-$camera.conf" | sudo tee -a /etc/motion/motion.conf
        fi

        # LOREX
        if [ $vrtype -eq "2" ]
        then
            sudo mkdir /etc/motion/LOREX-$i
            sudo touch /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "camera_name Camera-$camera" | sudo tee -a /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "\nnetcam_url rtsp://${username}:${password}@${vrip}:554/cam/realmonitor?channel=${camera}&subtype=0\ntarget_dir /home/sti05/backup/LOREX-$i" | sudo tee -a /etc/motion/LOREX-$i/Camera-$camera.conf
            printf "\ncamera /etc/motion/LOREX-$i/Camera-$camera.conf" | sudo tee -a /etc/motion/motion.conf
        fi

        printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        
        ((j++))
    done

    ((i++))
done

sudo systemctl enable motion
sudo service motion start

mkdir ~/.config/autostart
touch ~/.config/autostart/open-backup-directory.desktop

# Adds directory to open on startup
printf "[Desktop Entry]\nExec=xdg-open /backup\nName=open-backup-directory\nType=Application\nVersion=1.0" | tee -a ~/.config/autostart/open-backup-directory.desktop
printf "[Desktop Entry]\nExec=rclone mount gcs:st-lin-vm-1 /home/sti05/backup --vfs-cache-mode writes --config=/home/sti05/rclone.conf\nName=rclone\nType=Application\nVersion=1.0" | tee -a ~/.config/autostart/rclone.desktop
reboot
