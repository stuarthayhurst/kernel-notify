#!/bin/bash

#Move kernel-notify to /usr/bin/kernel-notify
sudo mv kernel-notify /usr/bin/kernel-notify

#Make /usr/share/kernel-notify and move icon.png to /usr/share/kernel-notify/icon.png
sudo mkdir /usr/share/kernel-notify
sudo mv icon.png /usr/share/kernel-notify/icon.png

#Move kernel-notify.desktop to ~/.config/autostart/kernel-notify.desktop
mv kernel-notify.desktop ~/.config/autostart/kernel-notify.desktop
