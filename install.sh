#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR
sudo apt install git -y

#Move kernel-notify to /usr/bin/kernel-notify
sudo cp kernel-notify /usr/bin/kernel-notify

#Make /usr/share/kernel-notify and move icon.png to /usr/share/kernel-notify/icon.png
if [ -d "/usr/share/kernel-notify" ]; then
  echo "/usr/share/kernel-notify was found, not creating it"
else
  echo "/usr/share/kernel-notify not found, creating it"
  sudo mkdir /usr/share/kernel-notify
  echo "Created directory"
fi

sudo cp icon.png /usr/share/kernel-notify/icon.png
echo "Added icon"

#Add start starup app
sudo cp kernel-notify.desktop /etc/xdg/autostart/kernel-notify.desktop
sudo cp kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop
echo "Added autostart file"

cd /usr/share/kernel-notify
if [ -d "/usr/share/kernel-notify" ]; then
  echo "Git repo already cloned"
else
  sudo git clone https://github.com/Dragon8oy/kernel-notify.git
  echo "Clone git repo"
fi

sudo rm -rf $DIR
cd ../
