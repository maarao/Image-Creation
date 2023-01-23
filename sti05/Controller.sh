#!/bin/bash

# TODO: Change directories to the place where everything is stored
cd ~/

check=`ls *.done`
expected='setup.done'

# Setup
if [[ $check != $expected ]]
then
    mkdir .record && cd .record
    # Delete all subdirectories if setting up again
    rm -R -- */

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

        print "How many cameras are going to be backed up: "
        read nocams
        touch $nocams.nocams

        # Create different directories for all cameras
        nocamsint=$((nocams))
        j=1
        while [ $j -le $nocamsint ]
        do
            mkdir Camera-$j && cd Camera-$j

            printf "Camera Number: "
            read camera
            touch $camera.camera
            
            mkdir ~/backup/System-$i/Camera-$camera

            cd ..
            
            ((j++))
        done

        cd ..

        ((i++))
    done
    
    cd ~/
    touch setup.done

fi

cd .record

novrsraw=`ls *.novrs`
novrs="${novrsraw%.*}"
novrsint=$((novrs))
i=1

# Iterate over all cameras and call their respective record scripts.
while [ $i -le $novrsint ]
do
    cd System-$i
    
    nocamsraw=`ls *.nocams`
    nocams="${nocamsraw%.*}"
    nocamsint=$((nocams))
    j=1
    
    while [ $j -le $nocamsint ]
    do
        cd Camera-$j

        bash -c "$(curl -fsSL https://raw.githubusercontent.com/maarao/Image-Creation/main/sti05/Record.sh)" &
        #bash <(curl -fsSL https://raw.githubusercontent.com/maarao/Image-Creation/main/sti05/Record.sh) &

        ((j++))
        cd ..
    done
    
    cd ..

done