#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

if ls /usr/bin/git; then
  echo "Git found"
else
  echo "Git not installed, exiting"
  exit
fi
if ls /usr/bin/wget; then
  echo "Wget found"
else
  echo "Wget not installed, exiting"
  exit
fi
if ls /usr/bin/notify-send; then
  echo "Notify-send found"
else
  echo "Notify-send not installed, we strongly recommend installing it for GUI systems"
fi

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

#Add startup app
if ls /etc/xdg/autostart/kernel-notify.desktop; then
  sudo rm /etc/xdg/autostart/kernel-notify.desktop
  sudo rm /usr/share/kernel-notify/kernel-notify.desktop
fi
sudo cp autostart.sh /usr/share/kernel-notify/autostart.sh
sudo cp autostart.sh /etc/profile.d/autostart.sh

echo "Added autostart file"

sudo cp updater /usr/share/kernel-notify/updater
echo "Added updater"

sudo rm -rf $DIR
