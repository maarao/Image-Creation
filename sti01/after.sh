#!bin/bash
sudo apt update -y && sudo apt upgrade -y

cd ~/Downloads
filename=`ls *.json`
user="${filename%.*}"

mv ~/Downloads/$user.json ~/.$user.json

sudo sed -i '$d' /etc/fstab
echo st-$user /home/sti01/backup/ gcsfuse rw,_netdev,allow_other,uid=1000,key_file=/home/sti01/.$user.json | sudo tee -a /etc/fstab

rm -R ~/snap/firefox/

echo
echo Installation complete. Rebooting in 10 seconds.
sleep 10 && reboot
