#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR
#Move kernel-notify to /usr/bin/kernel-notify
sudo mv kernel-notify /usr/bin/kernel-notify

#Make /usr/share/kernel-notify and move icon.png to /usr/share/kernel-notify/icon.png
sudo mkdir /usr/share/kernel-notify
sudo mv icon.png /usr/share/kernel-notify/icon.png

#Move kernel-notify.desktop to ~/.config/autostart/kernel-notify.desktop
cp kernel-notify.desktop ~/.config/autostart/kernel-notify.desktop
sudo cp kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop
sudo rm kernel-notify.desktop
