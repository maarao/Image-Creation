#!/bin/bash

# TODO: Change directories to the place where everything is stored
cd ~/

check=`ls *.done`
expected='setup.done'

# Setup
if [[ $check != $expected ]]
then
    # Motion configuration
    sudo apt install motion

    # TODO Add as a service to run as root
    
    
    mkdir .record && cd .record

    printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    
    # Ask for number of NVRs/DVRs
    printf "How many NVRs/DVRs are present: "
    read novrs
    touch $novrs.novrs
    
    # Create diffreent directories for all systems
    novrsint=$((novrs))
    i=1
    while [ $i -le $novrsint ]
    do
        mkdir System-$i && cd System-$i
        mkdir ~/backup/System-$i

        touch $i.vr

        printf "Brand of DVR / NVR:\n1.Lorex\n2.LTS\n"
        read vrtype
        if [ $vrtype -eq "1" ]
        then
            touch LOREX.vrtype
        fi
        if [ $vrtype -eq "2" ]
        then
            touch LTS.vrtype
        fi

        printf "NVR/DVR IP: "
        read vrip
        touch $vrip.vrip

        printf "NVR/DVR Username: "
        read username
        touch $username.username

        printf "NVR/DVR Password: "
        read password
        touch $password.password

        printf "How many cameras are going to be backed up: "
        read nocams
        touch $nocams.nocams

        # Create directory for motion config files
        sudo mkdir /etc/motion/$vr

        # Create different directories for all cameras
        nocamsint=$((nocams))
        j=1
        while [ $j -le $nocamsint ]
        do
            touch /etc/motion/$vr/camera$j.conf
            echo netcam | sudo tee -a /etc/fstab
            
            ((j++))
        done

        cd ..

        ((i++))
    done
    
    cd ~/
    touch setup.done

fi